import '../models/profile_model.dart';

abstract class AdminRepository {
  Future<ProfileModel> getAdminProfile();

  Future<ProfileModel> searchUserByEmail(String email);

  Future<ProfileModel> getUserById(String userId);

  Future<ProfileModel> createAuthority({
    required String fullname,
    required String phoneNumber,
    required String username,
    required String password,
    required int residenceWardCode,
    String? nickname,
    String? gender,
    String? dob,
    int? originProvinceCode,
    int? originWardCode,
    int? residenceProvinceCode,
    String? dateOfIssue,
    String? dateOfExpire,
    String? citizenId,
    String? occupation,
  });

  Future<ProfileModel> updateAuthority(
    String userId, {
    String? fullname,
    String? nickname,
    String? phoneNumber,
    String? gender,
    String? dob,
    int? originProvinceCode,
    int? originWardCode,
    int? residenceProvinceCode,
    int? residenceWardCode,
    String? dateOfIssue,
    String? dateOfExpire,
    String? citizenId,
    String? occupation,
    bool? isAuthority,
  });
}
