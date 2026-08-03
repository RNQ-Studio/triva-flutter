import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../storage/storage_service.dart';

/// Intercepts 401 responses and transparently refreshes the access token.
///
/// Uses [QueuedInterceptor] so concurrent 401 handling and token writes are
/// serialized.
class TokenRefreshInterceptor extends QueuedInterceptor {
  TokenRefreshInterceptor({
    required Dio dio,
    required StorageService storage,
    this.refreshEndpoint = 'v1/auth/refresh',
    this.onLogout,
  })  : _dio = dio,
        _storage = storage;

  final Dio _dio;
  final StorageService _storage;
  final String refreshEndpoint;
  final Future<void> Function()? onLogout;

  static const _retriedAfterRefreshKey = 'triva.retried_after_refresh';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401 ||
        err.requestOptions.path == refreshEndpoint) {
      return handler.next(err);
    }

    if (err.requestOptions.extra[_retriedAfterRefreshKey] == true) {
      await _forceLogout();
      return handler.reject(err);
    }

    String? refreshToken;
    try {
      // 1. Read the refresh token from secure storage.
      refreshToken = await _storage.read(AppConstants.keyRefreshToken);
    } on Object catch (error) {
      return handler.reject(_nonAuthoritativeFailure(err, error));
    }
    if (refreshToken == null || refreshToken.isEmpty) {
      await _forceLogout();
      return handler.reject(err);
    }

    try {
      // 2. Use a separate Dio instance (no interceptors) to avoid loops.
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: _dio.options.baseUrl,
          connectTimeout: _dio.options.connectTimeout,
          sendTimeout: _dio.options.sendTimeout,
          receiveTimeout: _dio.options.receiveTimeout,
          headers: {'Content-Type': 'application/json'},
        ),
      );
      final response = await refreshDio.post(
        refreshEndpoint,
        data: {'refresh_token': refreshToken},
      );

      // 3. Persist the new tokens.
      final responseData = response.data as Map<String, dynamic>;
      final tokenData = responseData['data'] as Map<String, dynamic>;
      final newAccessToken = tokenData['access_token'] as String;
      final newRefreshToken = tokenData['refresh_token'] as String?;
      if (newAccessToken.isEmpty) {
        throw const FormatException('Refresh response has an empty token.');
      }

      // A logout or a new login may have happened while refresh was in
      // flight. Never resurrect or overwrite that newer local session.
      final currentRefreshToken =
          await _storage.read(AppConstants.keyRefreshToken);
      if (currentRefreshToken != refreshToken) {
        return handler.reject(
          _nonAuthoritativeFailure(
            err,
            StateError('Auth session changed during token refresh.'),
          ),
        );
      }

      await _storage.write(AppConstants.keyAuthToken, newAccessToken);
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await _storage.write(AppConstants.keyRefreshToken, newRefreshToken);
      }

      // 4. Retry the original request with the new access token.
      final opts = err.requestOptions;
      opts.extra[_retriedAfterRefreshKey] = true;
      opts.headers['Authorization'] = 'Bearer $newAccessToken';
      final retryResponse = await _dio.fetch(opts);
      return handler.resolve(retryResponse);
    } on DioException catch (refreshError) {
      if (_isAuthoritativeRejection(refreshError)) {
        debugPrint('Refresh token was rejected; clearing local session.');
        await _forceLogout();
        return handler.reject(err);
      }

      debugPrint('Token refresh failed temporarily; preserving session.');
      return handler.reject(refreshError);
    } on Object catch (error) {
      debugPrint('Token refresh response was unusable; preserving session.');
      return handler.reject(_nonAuthoritativeFailure(err, error));
    }
  }

  bool _isAuthoritativeRejection(DioException error) {
    return error.response?.statusCode == 401;
  }

  DioException _nonAuthoritativeFailure(
    DioException originalError,
    Object error,
  ) {
    return DioException(
      requestOptions: originalError.requestOptions,
      type: DioExceptionType.unknown,
      error: error,
      message: 'Token refresh could not be completed.',
    );
  }

  Future<void> _forceLogout() async {
    await _deleteToken(AppConstants.keyAuthToken);
    await _deleteToken(AppConstants.keyRefreshToken);

    try {
      await onLogout?.call();
    } on Object {
      debugPrint('Session expiry callback failed');
    }
  }

  Future<void> _deleteToken(String key) async {
    try {
      await _storage.delete(key);
    } on Object {
      debugPrint('Failed to clear expired session token');
    }
  }
}
