import 'package:core/core.dart';

import '../../domain/entities/user.dart';
import '../../domain/entities/region_option.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../google_sign_in_client.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
    required GoogleSignInClient googleSignInClient,
    StorageService? storage,
  })  : _remote = remote,
        _local = local,
        _storage = storage,
        _googleSignInClient = googleSignInClient;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final StorageService? _storage;
  final GoogleSignInClient _googleSignInClient;

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final user = await _remote.login(email: email, password: password);
    await _local.saveUser(user);
    return user;
  }

  @override
  Future<User> loginWithGoogle() async {
    final idToken = await _googleSignInClient.signInAndGetFirebaseIdToken();
    final user = await _remote.loginWithGoogle(idToken: idToken);
    await _local.saveUser(user);
    return user;
  }

  @override
  Future<void> logout() async {
    try {
      final deviceId = await _storage?.read('triva.device_id');
      if (deviceId == null) {
        await _remote.logout();
      } else {
        await _remote.logout(deviceId);
      }
    } catch (_) {
      // Fail-safe: even if backend logout fails (e.g. offline),
      // we must still clear the local user session.
    } finally {
      try {
        await _googleSignInClient.signOut();
      } finally {
        await _local.clearUser();
      }
    }
  }

  @override
  Future<void> clearLocalSession() => _local.clearUser();

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = await _remote.register(
      name: name,
      email: email,
      password: password,
    );
    await _local.saveUser(user);
    return user;
  }

  @override
  Future<User?> getCurrentUser() async {
    final cached = await _local.getUser();
    if (cached == null) return null;

    try {
      final fresh = await _remote.getMe();
      final currentSession = await _local.getUser() ?? cached;
      final merged = UserModel(
        id: fresh.id,
        name: fresh.name,
        email: fresh.email,
        phone: fresh.phone ?? cached.phone,
        city: fresh.city ?? cached.city,
        avatarUrl: fresh.avatarUrl ?? cached.avatarUrl,
        profileCompleted: fresh.profileCompleted,
        serviceConsentAt: fresh.serviceConsentAt ?? cached.serviceConsentAt,
        marketingConsent: fresh.marketingConsent,
        roles: fresh.roles,
        permissions: fresh.permissions,
        token: currentSession.token,
        refreshToken: currentSession.refreshToken,
      );
      await _local.saveUser(merged);
      return merged;
    } on UnauthorizedException {
      await _local.clearUser();
      return null;
    } on NetworkException {
      // An offline profile may restore customer UX, but cached capabilities
      // must never unlock admin surfaces after a possible server-side revoke.
      if (cached.roles.isEmpty && cached.permissions.isEmpty) return cached;
      final offline = UserModel(
        id: cached.id,
        name: cached.name,
        email: cached.email,
        phone: cached.phone,
        city: cached.city,
        avatarUrl: cached.avatarUrl,
        profileCompleted: cached.profileCompleted,
        serviceConsentAt: cached.serviceConsentAt,
        marketingConsent: cached.marketingConsent,
        token: cached.token,
        refreshToken: cached.refreshToken,
      );
      return offline;
    }
  }

  @override
  Future<List<ProvinceOption>> getIndonesianProvinces() {
    return _remote.getIndonesianProvinces();
  }

  @override
  Future<User> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? city,
    int? provinceId,
    int? cityId,
    bool? serviceConsent,
    bool? marketingConsent,
  }) async {
    final updated = await _remote.updateProfile(
      name: name,
      email: email,
      phone: phone,
      city: city,
      provinceId: provinceId,
      cityId: cityId,
      serviceConsent: serviceConsent,
      marketingConsent: marketingConsent,
    );

    // Retrieve current user to keep the auth token!
    final currentUser = await _local.getUser();
    final merged = UserModel(
      id: updated.id,
      name: updated.name,
      email: updated.email,
      phone: updated.phone ?? currentUser?.phone,
      city: updated.city ?? currentUser?.city,
      avatarUrl: updated.avatarUrl ?? currentUser?.avatarUrl,
      profileCompleted: updated.profileCompleted,
      serviceConsentAt:
          updated.serviceConsentAt ?? currentUser?.serviceConsentAt,
      marketingConsent: updated.marketingConsent,
      roles: updated.roles,
      permissions: updated.permissions,
      token: currentUser?.token,
      refreshToken: currentUser?.refreshToken,
    );

    await _local.saveUser(merged);
    return merged;
  }

  @override
  Future<User> uploadAvatar(String filePath) async {
    final updated = await _remote.uploadAvatar(filePath);

    // Retrieve current user to keep the auth token!
    final currentUser = await _local.getUser();
    final merged = UserModel(
      id: updated.id,
      name: updated.name,
      email: updated.email,
      phone: updated.phone ?? currentUser?.phone,
      city: updated.city ?? currentUser?.city,
      avatarUrl: updated.avatarUrl ?? currentUser?.avatarUrl,
      profileCompleted: updated.profileCompleted,
      serviceConsentAt:
          updated.serviceConsentAt ?? currentUser?.serviceConsentAt,
      marketingConsent: updated.marketingConsent,
      roles: updated.roles,
      permissions: updated.permissions,
      token: currentUser?.token,
      refreshToken: currentUser?.refreshToken,
    );

    await _local.saveUser(merged);
    return merged;
  }
}
