import 'dart:typed_data';

import '../../models/authority/authority_profile.dart';
import '../../models/authority/announcement.dart';
import '../../models/authority/role_request.dart';
import '../../mappers/authority_mappers.dart';
import '../../mappers/charity_campaign_mappers.dart';
import '../../services/authority_service.dart';
import '../../services/auth_local_storage.dart';
import '../authority_repository.dart';
import '../../../domain/models/charity_campaign.dart';

class RealAuthorityRepository implements AuthorityRepository {
  final AuthorityService _authorityService;

  RealAuthorityRepository({required AuthorityService authorityService})
      : _authorityService = authorityService;

  @override
  Future<AuthorityProfile?> fetchProfileFromSession() async {
    final userData = await AuthLocalStorage.getUserData();
    if (userData == null) {
      return null;
    }

    return AuthorityMappers.profileFromSession(userData);
  }

  @override
  Future<AuthorityRoleRequestPage> fetchRoleRequests({
    String? beforeCreatedAt,
  }) async {
    final body = await _authorityService.getRoleRequests(
      beforeCreatedAt: beforeCreatedAt,
    );
    final list = (body['data'] as List<dynamic>? ?? const []);
    final pagination = body['pagination'] as Map<String, dynamic>? ?? {};

    final items = list
        .whereType<Map<String, dynamic>>()
        .map(AuthorityMappers.roleRequestFromApi)
        .toList();

    return AuthorityRoleRequestPage(
      items: items,
      hasMore: pagination['hasMore'] == true,
      nextCursor: pagination['nextCursor']?.toString(),
    );
  }

  @override
  Future<RoleRequest> approveRoleRequest(String requestId, {String? note}) async {
    final body = await _authorityService.approveRoleRequest(
      requestId,
      note: note,
    );
    final data = body['data'] as Map<String, dynamic>? ?? {};
    return AuthorityMappers.roleRequestFromApi(data);
  }

  @override
  Future<RoleRequest> rejectRoleRequest(String requestId, {String? note}) async {
    final body = await _authorityService.rejectRoleRequest(
      requestId,
      note: note,
    );
    final data = body['data'] as Map<String, dynamic>? ?? {};
    return AuthorityMappers.roleRequestFromApi(data);
  }

  @override
  Future<AuthorityCampaignRequestPage> fetchCharityCampaignRequests({
    String? beforeRequestedAt,
    CampaignStatus? status,
  }) async {
    final body = await _authorityService.getCharityCampaignRequests(
      beforeRequestedAt: beforeRequestedAt,
      state: status?.name.toUpperCase(),
    );
    final list = (body['data'] as List<dynamic>? ?? const []);
    final pagination = body['pagination'] as Map<String, dynamic>? ?? {};

    final items = list
        .whereType<Map<String, dynamic>>()
        .map(CharityCampaignMappers.campaignFromApi)
        .toList();

    return AuthorityCampaignRequestPage(
      items: items,
      hasMore: pagination['hasMore'] == true,
      nextCursor: pagination['nextCursor']?.toString(),
    );
  }

  @override
  Future<CharityCampaign> fetchCharityCampaignDetail(String campaignId) async {
    final body = await _authorityService.getCharityCampaignDetail(campaignId);
    final data = body['data'] as Map<String, dynamic>? ?? {};
    return CharityCampaignMappers.campaignFromApi(data);
  }

  @override
  Future<CharityCampaign> approveCharityCampaign(
    String campaignId, {
    String? noteForResponse,
  }) async {
    final body = await _authorityService.approveCharityCampaign(
      campaignId,
      noteForResponse: noteForResponse,
    );
    final data = body['data'] as Map<String, dynamic>? ?? {};
    return CharityCampaignMappers.campaignFromApi(data);
  }

  @override
  Future<CharityCampaign> rejectCharityCampaign(
    String campaignId, {
    String? noteForResponse,
  }) async {
    final body = await _authorityService.rejectCharityCampaign(
      campaignId,
      noteForResponse: noteForResponse,
    );
    final data = body['data'] as Map<String, dynamic>? ?? {};
    return CharityCampaignMappers.campaignFromApi(data);
  }

  @override
  Future<CharityCampaign> suspendCharityCampaign(
    String campaignId, {
    String? noteForSuspension,
  }) async {
    final body = await _authorityService.suspendCharityCampaign(
      campaignId,
      noteForSuspension: noteForSuspension,
    );
    final data = body['data'] as Map<String, dynamic>? ?? {};
    return CharityCampaignMappers.campaignFromApi(data);
  }

  @override
  Future<AuthorityAnnouncementPage> fetchAuthorityAnnouncements({
    String? beforeCreatedAt,
    int limit = 10,
  }) async {
    final body = await _authorityService.getAuthorityAnnouncements(
      beforeCreatedAt: beforeCreatedAt,
      limit: limit,
    );

    return AuthorityMappers.announcementPageFromApi(body);
  }

  @override
  Future<AuthorityAnnouncement> fetchAuthorityAnnouncementDetail(
    String announcementId,
  ) async {
    final body = await _authorityService.getAuthorityAnnouncementDetail(
      announcementId,
    );
    final data = body['data'] as Map<String, dynamic>? ?? {};
    return AuthorityMappers.announcementFromApi(data);
  }

  @override
  Future<AuthorityAnnouncement> publishAuthorityAnnouncement({
    required String title,
    required String caption,
    Uint8List? bytes,
    String? fileName,
    String? mimeType,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final body = await _authorityService.publishAuthorityAnnouncement(
      title: title,
      caption: caption,
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
      onSendProgress: onSendProgress,
    );
    final data = body['data'] as Map<String, dynamic>? ?? {};
    return AuthorityMappers.announcementFromApi(data);
  }

  @override
  Future<AuthorityAnnouncement> deleteAuthorityAnnouncement(
    String announcementId,
  ) async {
    final body = await _authorityService.deleteAuthorityAnnouncement(
      announcementId,
    );
    final data = body['data'] as Map<String, dynamic>? ?? {};
    return AuthorityMappers.announcementFromApi(data);
  }

}
