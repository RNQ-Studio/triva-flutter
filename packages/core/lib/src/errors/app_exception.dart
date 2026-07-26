sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const NetworkException(super.message, {this.statusCode});
  final int? statusCode;
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('Unauthorized');
}

final class ServerException extends AppException {
  const ServerException(super.message);
}

final class CacheException extends AppException {
  const CacheException(super.message);
}

final class SignInCancelledException extends AppException {
  const SignInCancelledException() : super('Sign-in cancelled');
}

final class AuthConfigurationException extends AppException {
  const AuthConfigurationException(super.message);
}
