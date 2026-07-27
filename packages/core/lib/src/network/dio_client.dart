import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../errors/app_exception.dart';
import '../storage/storage_service.dart';
import 'auth_interceptor.dart';
import 'token_refresh_interceptor.dart';

class DioClient {
  DioClient(
    StorageService storage, {
    Future<void> Function()? onLogout,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.instance.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(storage),
      TokenRefreshInterceptor(
        dio: _dio,
        storage: storage,
        onLogout: onLogout,
      ),
      _errorInterceptor(),
    ]);
  }

  late final Dio _dio;

  Dio get dio => _dio;

  Interceptor _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (err, handler) {
        final statusCode = err.response?.statusCode;
        // 401 is already handled by TokenRefreshInterceptor.
        // If we still get here with 401, it means refresh also failed.
        if (statusCode == 401) {
          handler.reject(
            err.copyWith(error: const UnauthorizedException()),
          );
          return;
        }
        if (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.sendTimeout ||
            err.type == DioExceptionType.connectionError ||
            (err.type == DioExceptionType.unknown && err.response == null)) {
          handler.reject(
            err.copyWith(
              error: NetworkException('Connection timeout',
                  statusCode: statusCode),
            ),
          );
          return;
        }
        final responseData = err.response?.data;
        final body = responseData is Map<String, dynamic>
            ? responseData
            : const <String, dynamic>{};
        final rawErrors = body['errors'];
        final validationErrors = <String, List<String>>{
          if (rawErrors is Map)
            for (final entry in rawErrors.entries)
              entry.key.toString(): entry.value is List
                  ? (entry.value as List)
                      .map((item) => item.toString())
                      .toList(growable: false)
                  : [entry.value.toString()],
        };
        handler.reject(
          err.copyWith(
            error: ServerException(
              body['message']?.toString() ?? err.message ?? 'Server error',
              code: body['code']?.toString(),
              statusCode: statusCode,
              validationErrors: validationErrors,
            ),
          ),
        );
      },
    );
  }
}
