import 'dart:typed_data';

import '../models/authority/authority_profile.dart';
import '../models/authority/announcement.dart';
import '../models/authority/role_request.dart';
import '../models/authority/profile_update_request.dart';
import '../../domain/models/charity_campaign.dart';

class AuthorityRoleRequestPage {
  const AuthorityRoleRequestPage({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });

  final List<RoleRequest> items;
  final bool hasMore;
  final String? nextCursor;
}

class AuthorityCampaignRequestPage {
  const AuthorityCampaignRequestPage({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });

  final List<CharityCampaign> items;
  final bool hasMore;
  final String? nextCursor;
}

class AuthorityProfileUpdateRequestPage {
  const AuthorityProfileUpdateRequestPage({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });

  final List<AuthorityProfileUpdateRequest> items;
  final bool hasMore;
  final String? nextCursor;
}

abstract class AuthorityRepository {
  Future<AuthorityProfile?> fetchProfileFromSession();

  Future<AuthorityRoleRequestPage> fetchRoleRequests({
    String? beforeCreatedAt,
  });

  Future<RoleRequest> approveRoleRequest(String requestId, {String? note});

  Future<RoleRequest> rejectRoleRequest(String requestId, {String? note});

  Future<AuthorityProfileUpdateRequestPage> fetchProfileUpdateRequests({
    String? beforeCreatedAt,
    RoleRequestType? roleFilter,
    RoleRequestStatus? statusFilter,
  });

  Future<void> approveProfileUpdateRequest(String requestId, {String? note});

  Future<void> rejectProfileUpdateRequest(String requestId, {String? note});

  Future<AuthorityCampaignRequestPage> fetchCharityCampaignRequests({
    String? beforeRequestedAt,
    CampaignStatus? status,
  });

  Future<CharityCampaign> fetchCharityCampaignDetail(String campaignId);

  Future<CharityCampaign> approveCharityCampaign(
    String campaignId, {
    String? noteForResponse,
  });

  Future<CharityCampaign> rejectCharityCampaign(
    String campaignId, {
    String? noteForResponse,
  });

  Future<CharityCampaign> suspendCharityCampaign(
    String campaignId, {
    String? noteForSuspension,
  });

  Future<AuthorityAnnouncementPage> fetchAuthorityAnnouncements({
    String? beforeCreatedAt,
    int limit,
  });

  Future<AuthorityAnnouncement> fetchAuthorityAnnouncementDetail(
    String announcementId,
  );

  Future<AuthorityAnnouncement> publishAuthorityAnnouncement({
    required String title,
    required String caption,
    Uint8List? bytes,
    String? fileName,
    String? mimeType,
    void Function(int sent, int total)? onSendProgress,
  });

  Future<AuthorityAnnouncement> deleteAuthorityAnnouncement(
    String announcementId,
  );
}
