import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../storage/storage_service.dart';

/// Intercepts 401 responses and transparently refreshes the access token.
///
/// Uses [QueuedInterceptor] so that concurrent 401 errors are queued and only
/// a single refresh request is issued. Subsequent queued requests are retried
/// with the new token.
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

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    try {
      // 1. Read the refresh token from secure storage.
      final refreshToken = await _storage.read(AppConstants.keyRefreshToken);
      if (refreshToken == null) {
        await _forceLogout();
        return handler.reject(err);
      }

      // 2. Use a separate Dio instance (no interceptors) to avoid loops.
      final refreshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
      final response = await refreshDio.post(
        refreshEndpoint,
        data: {'refresh_token': refreshToken},
      );

      // 3. Persist the new tokens.
      final responseData = response.data as Map<String, dynamic>;
      final tokenData = responseData['data'] as Map<String, dynamic>;
      final newAccessToken = tokenData['access_token'] as String;
      final newRefreshToken = tokenData['refresh_token'] as String?;

      await _storage.write(AppConstants.keyAuthToken, newAccessToken);
      if (newRefreshToken != null) {
        await _storage.write(AppConstants.keyRefreshToken, newRefreshToken);
      }

      // 4. Retry the original request with the new access token.
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newAccessToken';
      final retryResponse = await _dio.fetch(opts);
      return handler.resolve(retryResponse);
    } on Object {
      debugPrint('Token refresh failed');
      await _forceLogout();
      return handler.reject(err);
    }
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
