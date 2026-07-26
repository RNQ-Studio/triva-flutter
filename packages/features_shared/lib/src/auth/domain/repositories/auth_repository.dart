import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<User> loginWithGoogle();
  Future<void> logout();
  Future<User> register({
    required String name,
    required String email,
    required String password,
  });
  Future<User?> getCurrentUser();
  Future<User> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? city,
    bool? serviceConsent,
    bool? marketingConsent,
  });
  Future<User> uploadAvatar(String filePath);
}
