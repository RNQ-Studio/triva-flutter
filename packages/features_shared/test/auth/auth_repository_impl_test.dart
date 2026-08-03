import 'dart:async';
import 'dart:convert';

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
  late _MockGoogleSignInClient googleSignIn;
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
    googleSignIn = _MockGoogleSignInClient();
    repository = AuthRepositoryImpl(
      remote: remote,
      local: local,
      googleSignInClient: googleSignIn,
    );
  });

  test(
      'offline logout locks persisted session before hanging cleanup and restart',
      () async {
    final storage = _MemoryStorage();
    final realLocal = AuthLocalDataSource(storage);
    final remoteCleanup = Completer<void>();
    final googleCleanup = Completer<void>();
    await realLocal.saveUser(cached);
    await storage.write('triva.device_id', 'device-1');
    when(
      () => remote.logout(
        deviceId: any(named: 'deviceId'),
        accessToken: any(named: 'accessToken'),
      ),
    ).thenAnswer((_) => remoteCleanup.future);
    when(() => googleSignIn.signOut()).thenAnswer((_) => googleCleanup.future);
    final realRepository = AuthRepositoryImpl(
      remote: remote,
      local: realLocal,
      googleSignInClient: googleSignIn,
      storage: storage,
    );

    await realRepository.logout().timeout(const Duration(milliseconds: 200));

    final restartedLocal = AuthLocalDataSource(storage);
    expect(await restartedLocal.getUser(), isNull);
    expect(await storage.read(AppConstants.keyAuthToken), isNull);
    expect(await storage.read(AppConstants.keyRefreshToken), isNull);
    verify(
      () => remote.logout(
        deviceId: 'device-1',
        accessToken: 'expired-access',
      ),
    ).called(1);
    verify(() => googleSignIn.signOut()).called(1);

    remoteCleanup.complete();
    googleCleanup.complete();
  });

  test('legacy profile JSON cannot resurrect deleted secure tokens', () async {
    final storage = _MemoryStorage();
    await storage.write('auth_user', jsonEncode(cached.toJson()));

    final restored = await AuthLocalDataSource(storage).getUser();

    expect(restored, isNull);
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

  test('offline restore strips cached admin capabilities', () async {
    const cachedAdmin = UserModel(
      id: '2',
      name: 'Cached Admin',
      email: 'admin@example.com',
      token: 'access',
      refreshToken: 'refresh',
      roles: ['admin'],
      permissions: [
        'service_bookings.viewAny',
        'service_bookings.update',
      ],
    );
    when(() => local.getUser()).thenAnswer((_) async => cachedAdmin);
    when(() => remote.getMe()).thenThrow(const NetworkException('offline'));

    final user = await repository.getCurrentUser();

    expect(user?.roles, isEmpty);
    expect(user?.permissions, isEmpty);
    expect(user?.canAccessAdminPanel, isFalse);
  });
}

class _MemoryStorage implements StorageService {
  final Map<String, String> _values = {};

  @override
  Future<void> clear() async => _values.clear();

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> init() async {}

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }
}
