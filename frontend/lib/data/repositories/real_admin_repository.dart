import 'package:antiflood/data/services/admin_service.dart';

import '../mappers/profile_mapper.dart';
import '../models/profile_model.dart';
import 'admin_repository.dart';

class RealAdminRepository implements AdminRepository {
  final AdminService _adminService;

  RealAdminRepository({required AdminService adminService}) : _adminService = adminService;

  @override
  Future<ProfileModel> getAdminProfile() async {
    final response = await _adminService.getAdminProfile();
    return ProfileMapper.mapResponseToProfileModel(response);
  }

  @override
  Future<ProfileModel> searchUserByEmail(String email) async {
    final response = await _adminService.searchUserByEmail(email);
    return ProfileMapper.mapResponseToProfileModel(response);
  }

  @override
  Future<ProfileModel> getUserById(String userId) async {
    final response = await _adminService.getUserById(userId);
    return ProfileMapper.mapResponseToProfileModel(response);
  }

  @override
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
  }) async {
    final response = await _adminService.createAuthority(
      fullname: fullname,
      phoneNumber: phoneNumber,
      username: username,
      password: password,
      residenceWardCode: residenceWardCode,
      nickname: nickname,
      gender: gender,
      dob: dob,
      originProvinceCode: originProvinceCode,
      originWardCode: originWardCode,
      residenceProvinceCode: residenceProvinceCode,
      dateOfIssue: dateOfIssue,
      dateOfExpire: dateOfExpire,
      citizenId: citizenId,
      occupation: occupation,
    );
    return ProfileMapper.mapResponseToProfileModel(response);
  }

  @override
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
  }) async {
    final response = await _adminService.updateAuthority(
      userId,
      fullname: fullname,
      nickname: nickname,
      phoneNumber: phoneNumber,
      gender: gender,
      dob: dob,
      originProvinceCode: originProvinceCode,
      originWardCode: originWardCode,
      residenceProvinceCode: residenceProvinceCode,
      residenceWardCode: residenceWardCode,
      dateOfIssue: dateOfIssue,
      dateOfExpire: dateOfExpire,
      citizenId: citizenId,
      occupation: occupation,
      isAuthority: isAuthority,
    );
    return ProfileMapper.mapResponseToProfileModel(response);
  }
}
