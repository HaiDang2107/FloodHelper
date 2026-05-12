import 'package:antiflood/data/services/admin_service.dart';
import 'package:antiflood/data/mappers/profile_mapper.dart';
import 'package:antiflood/data/models/profile_model.dart';
import 'package:antiflood/data/models/admin/admin_dtos.dart';

import '../admin_repository.dart';

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
  Future<ProfileModel> createAuthority(CreateAuthorityDto dto) async {
    final response = await _adminService.createAuthority(dto);
    return ProfileMapper.mapResponseToProfileModel(response);
  }

  @override
  Future<ProfileModel> updateAuthority(
    String userId,
    UpdateAuthorityDto dto,
  ) async {
    final response = await _adminService.updateAuthority(userId, dto);
    return ProfileMapper.mapResponseToProfileModel(response);
  }

  @override
  Future<ProfileModel> banAccount(String userId) async {
    final response = await _adminService.banAccount(userId);
    return ProfileMapper.mapResponseToProfileModel(response);
  }

  @override
  Future<ProfileModel> unbanAccount(String userId) async {
    final response = await _adminService.unbanAccount(userId);
    return ProfileMapper.mapResponseToProfileModel(response);
  }
}
