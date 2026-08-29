import 'package:core/core.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/user.dart';
import '../models/user_model.dart';
import '../../domain/entities/region_option.dart';
import '../models/region_option_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Post to login endpoint
      final response = await _dio.post(
        'v1/auth/login',
        data: {'email': email, 'password': password},
      );

      final responseData = response.data as Map<String, dynamic>;
      final tokensData = responseData['data'] as Map<String, dynamic>;
      final token = tokensData['access_token'] as String;
      final refreshToken = tokensData['refresh_token'] as String;

      // 2. Fetch the user profile from /v1/auth/me using this token manually
      final profileResponse = await _dio.get(
        'v1/auth/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final profileData = profileResponse.data as Map<String, dynamic>;
      final userJson = profileData['data'] as Map<String, dynamic>;

      return UserModel.fromJson({
        ...userJson,
        'token': token,
        'refresh_token': refreshToken,
      });
    } on DioException catch (e) {
      throw e.error ?? ServerException(e.message ?? 'Login failed');
    }
  }

  Future<UserModel> loginWithGoogle({required String idToken}) async {
    try {
      final response = await _dio.post(
        'v1/auth/google',
        data: {'id_token': idToken},
      );

      final responseData = response.data as Map<String, dynamic>;
      final tokensData = responseData['data'] as Map<String, dynamic>;
      final token = tokensData['access_token'] as String;
      final refreshToken = tokensData['refresh_token'] as String;

      final profileResponse = await _dio.get(
        'v1/auth/me',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      final profileData = profileResponse.data as Map<String, dynamic>;
      final userJson = profileData['data'] as Map<String, dynamic>;

      return UserModel.fromJson({
        ...userJson,
        'token': token,
        'refresh_token': refreshToken,
      });
    } on DioException catch (error) {
      throw error.error ??
          ServerException(error.message ?? 'Google sign-in failed');
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Post to register endpoint
      final response = await _dio.post(
        'v1/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      final responseData = response.data as Map<String, dynamic>;
      final tokensData = responseData['data'] as Map<String, dynamic>;
      final token = tokensData['access_token'] as String;
      final refreshToken = tokensData['refresh_token'] as String;

      // 2. Fetch the user profile from /v1/auth/me using this token manually
      final profileResponse = await _dio.get(
        'v1/auth/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final profileData = profileResponse.data as Map<String, dynamic>;
      final userJson = profileData['data'] as Map<String, dynamic>;

      return UserModel.fromJson({
        ...userJson,
        'token': token,
        'refresh_token': refreshToken,
      });
    } on DioException catch (e) {
      throw e.error ?? ServerException(e.message ?? 'Register failed');
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get('v1/auth/me');
      final responseData = response.data as Map<String, dynamic>;
      final userJson = responseData['data'] as Map<String, dynamic>;

      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      throw e.error ?? ServerException(e.message ?? 'Failed to fetch profile');
    }
  }

  Future<List<ProvinceOption>> getIndonesianProvinces() async {
    try {
      final response = await _dio.get('v1/regions/provinces');
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as List<dynamic>? ?? const [];

      return data
          .whereType<Map<String, dynamic>>()
          .map(RegionOptionModel.provinceFromJson)
          .toList(growable: false);
    } on DioException catch (error) {
      throw error.error ??
          ServerException(error.message ?? 'Failed to load regions');
    }
  }

  Future<UserModel> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? city,
    int? provinceId,
    int? cityId,
    Gender? gender,
    DateTime? birthDate,
    bool? serviceConsent,
    bool? marketingConsent,
  }) async {
    try {
      final response = await _dio.put(
        'v1/auth/me',
        data: {
          'name': name,
          'email': email,
          if (phone != null) 'phone': phone,
          if (city != null) 'city': city,
          if (gender != null) 'gender': gender.apiValue,
          if (birthDate != null) 'birth_date': _formatDate(birthDate),
          if (provinceId != null) 'province_id': provinceId,
          if (cityId != null) 'city_id': cityId,
          if (serviceConsent != null) 'service_consent': serviceConsent,
          if (marketingConsent != null) 'marketing_consent': marketingConsent,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final userJson = responseData['data'] as Map<String, dynamic>;

      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      throw e.error ?? ServerException(e.message ?? 'Update profile failed');
    }
  }

  Future<UserModel> uploadAvatar(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.post(
        'v1/auth/avatar',
        data: formData,
      );

      final responseData = response.data as Map<String, dynamic>;
      final userJson = responseData['data'] as Map<String, dynamic>;

      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      throw e.error ?? ServerException(e.message ?? 'Upload avatar failed');
    }
  }

  Future<void> logout({String? deviceId, String? accessToken}) async {
    try {
      await _dio.post(
        'v1/auth/logout',
        data: {
          if (deviceId != null) 'device_id': deviceId,
        },
        options: accessToken == null
            ? null
            : Options(
                headers: {'Authorization': 'Bearer $accessToken'},
              ),
      );
    } on DioException catch (e) {
      throw e.error ?? ServerException(e.message ?? 'Logout failed');
    }
  }
}

String _formatDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year.toString().padLeft(4, '0')}-$month-$day';
}
