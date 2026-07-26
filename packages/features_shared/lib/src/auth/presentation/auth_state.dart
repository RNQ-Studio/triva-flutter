import '../domain/entities/user.dart';

sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final User user;
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

enum AuthFailureKind {
  network,
  configuration,
  rejected,
  general,
}

final class AuthError extends AuthState {
  const AuthError(this.kind);
  final AuthFailureKind kind;
}
