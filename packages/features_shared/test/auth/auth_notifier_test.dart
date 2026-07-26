import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:features_shared/features_shared.dart';
import 'package:core/core.dart';

import 'mock_auth_repository.dart';

void main() {
  late MockAuthRepository mockRepo;
  late ProviderContainer container;

  const tUser = User(id: '1', name: 'Test', email: 'test@test.com');

  setUp(() {
    mockRepo = MockAuthRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('initial state is AuthInitial', () {
    expect(container.read(authProvider), isA<AuthInitial>());
  });

  test('login success → AuthAuthenticated', () async {
    when(() => mockRepo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => tUser);

    await container
        .read(authProvider.notifier)
        .login(email: 'test@test.com', password: 'password');

    final state = container.read(authProvider);
    expect(state, isA<AuthAuthenticated>());
    expect((state as AuthAuthenticated).user, tUser);
  });

  test('login failure → AuthError with message', () async {
    when(() => mockRepo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(const ServerException('Invalid credentials'));

    await container
        .read(authProvider.notifier)
        .login(email: 'wrong@test.com', password: 'wrongpass');

    final state = container.read(authProvider);
    expect(state, isA<AuthError>());
    expect((state as AuthError).kind, AuthFailureKind.general);
  });

  test('Google login success becomes AuthAuthenticated', () async {
    when(() => mockRepo.loginWithGoogle()).thenAnswer((_) async => tUser);

    await container.read(authProvider.notifier).loginWithGoogle();

    final state = container.read(authProvider);
    expect(state, isA<AuthAuthenticated>());
    expect((state as AuthAuthenticated).user, tUser);
  });

  test('Google login cancellation becomes AuthUnauthenticated', () async {
    when(() => mockRepo.loginWithGoogle())
        .thenThrow(const SignInCancelledException());

    await container.read(authProvider.notifier).loginWithGoogle();

    expect(container.read(authProvider), isA<AuthUnauthenticated>());
  });

  test('Google login network failure becomes network AuthError', () async {
    when(() => mockRepo.loginWithGoogle())
        .thenThrow(const NetworkException('offline'));

    await container.read(authProvider.notifier).loginWithGoogle();

    final state = container.read(authProvider);
    expect(state, isA<AuthError>());
    expect((state as AuthError).kind, AuthFailureKind.network);
  });

  test('logout → AuthUnauthenticated', () async {
    when(() => mockRepo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => tUser);
    when(() => mockRepo.logout()).thenAnswer((_) async {});

    await container
        .read(authProvider.notifier)
        .login(email: 'test@test.com', password: 'password');
    await container.read(authProvider.notifier).logout();

    expect(container.read(authProvider), isA<AuthUnauthenticated>());
  });

  test('checkCurrentUser with cached session → AuthAuthenticated', () async {
    when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => tUser);

    await container.read(authProvider.notifier).checkCurrentUser();

    final state = container.read(authProvider);
    expect(state, isA<AuthAuthenticated>());
    expect((state as AuthAuthenticated).user, tUser);
  });

  test('checkCurrentUser with no session → AuthUnauthenticated', () async {
    when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => null);

    await container.read(authProvider.notifier).checkCurrentUser();

    expect(container.read(authProvider), isA<AuthUnauthenticated>());
  });
}
