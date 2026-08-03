import 'dart:convert';

import 'package:core/core.dart';

import '../models/user_model.dart';

class AuthLocalDataSource {
  const AuthLocalDataSource(this._storage);

  final StorageService _storage;

  static const _tokenKey = AppConstants.keyAuthToken;
  static const _refreshTokenKey = AppConstants.keyRefreshToken;
  static const _userKey = 'auth_user';

  Future<void> saveUser(UserModel user) async {
    final profile = user.toJson()
      ..remove('token')
      ..remove('refresh_token');

    // The profile is the session commit marker. Remove it first so an
    // interrupted account switch cannot pair old tokens with a new profile,
    // then write it last only after the token pair is ready.
    await _storage.delete(_userKey);
    if (user.token != null) {
      await _storage.write(_tokenKey, user.token!);
    } else {
      await _storage.delete(_tokenKey);
    }
    if (user.refreshToken != null) {
      await _storage.write(_refreshTokenKey, user.refreshToken!);
    } else {
      await _storage.delete(_refreshTokenKey);
    }
    await _storage.write(_userKey, jsonEncode(profile));
  }

  Future<UserModel?> getUser() async {
    final raw = await _storage.read(_userKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final token = await _storage.read(_tokenKey);
      final refreshToken = await _storage.read(_refreshTokenKey);
      if (token == null || refreshToken == null) return null;

      // Never trust token fields embedded by older app versions. The
      // dedicated secure-storage entries are the only session authority.
      map
        ..remove('token')
        ..remove('refresh_token');
      return UserModel.fromJson({
        ...map,
        'token': token,
        'refresh_token': refreshToken,
      });
    } on Object {
      return null;
    }
  }

  Future<void> clearUser() async {
    // Delete the commit marker first. A restart during the remaining secure
    // storage cleanup must already observe a signed-out session.
    await _storage.delete(_userKey);
    await _storage.delete(_tokenKey);
    await _storage.delete(_refreshTokenKey);
  }

  Future<String?> getToken() => _storage.read(_tokenKey);
}
