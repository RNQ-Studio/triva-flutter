import '../entities/profile.dart';

abstract class ProfileRepository {
  /// Membaca profil dari sesi auth yang sedang aktif.
  /// Mengembalikan null jika user belum login.
  Future<Profile?> getProfile();

  /// Memperbarui data profil.
  Future<void> updateProfile(Profile profile);
}
