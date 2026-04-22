import '../models/authority/authority_profile.dart';
import '../models/authority/role_request.dart';
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

abstract class AuthorityRepository {
  Future<AuthorityProfile?> fetchProfileFromSession();

  Future<AuthorityRoleRequestPage> fetchRoleRequests({
    String? beforeCreatedAt,
  });

  Future<RoleRequest> approveRoleRequest(String requestId, {String? note});

  Future<RoleRequest> rejectRoleRequest(String requestId, {String? note});

  Future<AuthorityCampaignRequestPage> fetchCharityCampaignRequests({
    String? beforeRequestedAt,
    CampaignStatus? status,
  });

  Future<CharityCampaign> fetchCharityCampaignDetail(String campaignId);

  Future<CharityCampaign> approveCharityCampaign(
    String campaignId, {
    String? noteByAuthority,
  });

  Future<CharityCampaign> rejectCharityCampaign(
    String campaignId, {
    String? noteByAuthority,
  });

  Future<CharityCampaign> suspendCharityCampaign(
    String campaignId, {
    String? noteByAuthority,
  });
}
