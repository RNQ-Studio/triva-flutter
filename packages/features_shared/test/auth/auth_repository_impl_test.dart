import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class _MockLocalDataSource extends Mock implements AuthLocalDataSource {}

class _MockGoogleSignInClient extends Mock implements GoogleSignInClient {}

void main() {
  late _MockRemoteDataSource remote;
  late _MockLocalDataSource local;
  late AuthRepositoryImpl repository;

  const cached = UserModel(
    id: '1',
    name: 'Cached User',
    email: 'cached@example.com',
    token: 'expired-access',
    refreshToken: 'valid-refresh',
  );
  const rotatedSession = UserModel(
    id: '1',
    name: 'Cached User',
    email: 'cached@example.com',
    token: 'rotated-access',
    refreshToken: 'rotated-refresh',
  );
  const freshProfile = UserModel(
    id: '1',
    name: 'Fresh User',
    email: 'cached@example.com',
    profileCompleted: true,
  );

  setUpAll(() {
    registerFallbackValue(cached);
  });

  setUp(() {
    remote = _MockRemoteDataSource();
    local = _MockLocalDataSource();
    repository = AuthRepositoryImpl(
      remote: remote,
      local: local,
      googleSignInClient: _MockGoogleSignInClient(),
    );
  });

  test('session restore keeps tokens rotated during getMe', () async {
    var localReadCount = 0;
    when(() => local.getUser()).thenAnswer((_) async {
      localReadCount++;
      return localReadCount == 1 ? cached : rotatedSession;
    });
    when(() => remote.getMe()).thenAnswer((_) async => freshProfile);
    when(() => local.saveUser(any())).thenAnswer((_) async {});

    final user = await repository.getCurrentUser();

    expect(user?.name, 'Fresh User');
    final saved =
        verify(() => local.saveUser(captureAny())).captured.single as UserModel;
    expect(saved.token, 'rotated-access');
    expect(saved.refreshToken, 'rotated-refresh');
  });

  test('unauthorized session restore clears cache and returns signed out',
      () async {
    when(() => local.getUser()).thenAnswer((_) async => cached);
    when(() => remote.getMe()).thenThrow(const UnauthorizedException());
    when(() => local.clearUser()).thenAnswer((_) async {});

    final user = await repository.getCurrentUser();

    expect(user, isNull);
    verify(() => local.clearUser()).called(1);
  });

  test('offline session restore preserves cached user', () async {
    when(() => local.getUser()).thenAnswer((_) async => cached);
    when(() => remote.getMe()).thenThrow(const NetworkException('offline'));

    final user = await repository.getCurrentUser();

    expect(user, same(cached));
    verifyNever(() => local.clearUser());
  });
}
