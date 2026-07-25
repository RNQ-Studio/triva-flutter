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
            err.type == DioExceptionType.sendTimeout) {
          handler.reject(
            err.copyWith(
              error: NetworkException('Connection timeout',
                  statusCode: statusCode),
            ),
          );
          return;
        }
        handler.reject(
          err.copyWith(
            error: ServerException(
              err.response?.data?['message']?.toString() ??
                  err.message ??
                  'Server error',
            ),
          ),
        );
      },
    );
  }
}
