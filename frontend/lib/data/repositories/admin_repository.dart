import '../models/profile_model.dart';
import '../models/admin/admin_dtos.dart';

abstract class AdminRepository {
  Future<ProfileModel> getAdminProfile();

  Future<ProfileModel> searchUserByEmail(String email);

  Future<ProfileModel> getUserById(String userId);

  Future<ProfileModel> createAuthority(CreateAuthorityDto dto);

  Future<ProfileModel> updateAuthority(
    String userId,
    UpdateAuthorityDto dto,
  );

  Future<ProfileModel> banAccount(String userId);

  Future<ProfileModel> unbanAccount(String userId);
}
