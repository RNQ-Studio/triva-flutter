import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  /// Updates the canonical profile owned by the authenticated user.
  Future<void> call(Profile profile) => _repository.updateProfile(profile);
}
