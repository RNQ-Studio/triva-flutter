import 'dart:convert';

import 'package:core/core.dart';

import '../models/user_model.dart';

class AuthLocalDataSource {
  const AuthLocalDataSource(this._storage);

  final StorageService _storage;

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'auth_user';

  Future<void> saveUser(UserModel user) async {
    await _storage.write(_userKey, jsonEncode(user.toJson()));
    if (user.token != null) {
      await _storage.write(_tokenKey, user.token!);
    } else {
      await _storage.delete(_tokenKey);
    }
    if (user.refreshToken != null) {
      await _storage.write(_refreshTokenKey, user.refreshToken!);
    }
  }

  Future<UserModel?> getUser() async {
    final raw = await _storage.read(_userKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final token = await _storage.read(_tokenKey);
      final refreshToken = await _storage.read(_refreshTokenKey);
      return UserModel.fromJson({
        ...map,
        if (token != null) 'token': token,
        if (refreshToken != null) 'refresh_token': refreshToken,
      });
    } on Object {
      return null;
    }
  }

  Future<void> clearUser() async {
    await _storage.delete(_tokenKey);
    await _storage.delete(_refreshTokenKey);
    await _storage.delete(_userKey);
  }

  Future<String?> getToken() => _storage.read(_tokenKey);
}
