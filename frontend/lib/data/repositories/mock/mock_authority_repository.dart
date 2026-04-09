import '../../models/authority/authority_profile.dart';
import '../../models/authority/role_request.dart';
import '../../../domain/models/charity_campaign.dart';
import '../authority_repository.dart';

class MockAuthorityRepository implements AuthorityRepository {
  final List<CharityCampaign> _campaignRequests = [
    CharityCampaign(
      id: 'CAMP-2001',
      organizedBy: 'user-1',
      checkedBy: null,
      name: 'Central Flood Relief 2026',
      benefactorName: 'Nguyen Van A',
      purpose: 'Support households affected by flooding',
      charityObject: 'Flood-affected families',
      status: CampaignStatus.pending,
      bankInfo: const BankInfo(
        accountNumber: '1234567890',
        bankName: 'Vietcombank',
        accountHolder: 'Nguyen Van A',
      ),
      requestedAt: DateTime.now().subtract(const Duration(hours: 4)),
      startedDonationAt: DateTime.now().add(const Duration(days: 2)),
      finishedDonationAt: DateTime.now().add(const Duration(days: 10)),
      startedDistributionAt: DateTime.now().add(const Duration(days: 11)),
      finishedDistributionAt: DateTime.now().add(const Duration(days: 20)),
      reliefLocation: 'Hue, Vietnam',
      period: DateRange(
        startDate: DateTime.now().add(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 20)),
      ),
      announcements: const [],
    ),
    CharityCampaign(
      id: 'CAMP-2002',
      organizedBy: 'user-2',
      checkedBy: 'authority-mock-id',
      name: 'Emergency Food Support',
      benefactorName: 'Tran Thi B',
      purpose: 'Provide food support for 50 households',
      charityObject: 'Low-income households',
      status: CampaignStatus.approved,
      bankInfo: const BankInfo(
        accountNumber: '0987654321',
        bankName: 'Techcombank',
        accountHolder: 'Tran Thi B',
      ),
      requestedAt: DateTime.now().subtract(const Duration(days: 1)),
      respondedAt: DateTime.now().subtract(const Duration(hours: 20)),
      noteByAuthority: 'Looks good, approved for rollout.',
      startedDonationAt: DateTime.now().add(const Duration(days: 1)),
      finishedDonationAt: DateTime.now().add(const Duration(days: 8)),
      startedDistributionAt: DateTime.now().add(const Duration(days: 9)),
      finishedDistributionAt: DateTime.now().add(const Duration(days: 15)),
      reliefLocation: 'Da Nang, Vietnam',
      period: DateRange(
        startDate: DateTime.now().add(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 15)),
      ),
      announcements: const [],
    ),
    CharityCampaign(
      id: 'CAMP-2003',
      organizedBy: 'user-3',
      checkedBy: 'authority-mock-id',
      name: 'School Rebuild Fund',
      benefactorName: 'Pham Van C',
      purpose: 'Rebuild classrooms after floods',
      charityObject: 'Students and teachers',
      status: CampaignStatus.rejected,
      bankInfo: const BankInfo(
        accountNumber: '1122334455',
        bankName: 'BIDV',
        accountHolder: 'Pham Van C',
      ),
      requestedAt: DateTime.now().subtract(const Duration(days: 2)),
      respondedAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      noteByAuthority: 'Missing timeline details.',
      startedDonationAt: DateTime.now().add(const Duration(days: 3)),
      finishedDonationAt: DateTime.now().add(const Duration(days: 12)),
      startedDistributionAt: DateTime.now().add(const Duration(days: 13)),
      finishedDistributionAt: DateTime.now().add(const Duration(days: 18)),
      reliefLocation: 'Quang Tri, Vietnam',
      period: DateRange(
        startDate: DateTime.now().add(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 18)),
      ),
      announcements: const [],
    ),
  ];

  @override
  Future<AuthorityProfile?> fetchProfileFromSession() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const AuthorityProfile(
      userId: 'authority-mock-id',
      name: 'Captain Minh Tran',
      nickname: 'Minh',
      roleTitle: 'Emergency Coordination Lead',
      email: 'minh.tran@authority.local',
      phoneNumber: '+84 90 000 0000',
      placeOfResidence: 'Flood Response Command Center',
      avatarUrl:
          'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?auto=format&fit=facearea&w=300&h=300',
    );
  }

  @override
  Future<AuthorityRoleRequestPage> fetchRoleRequests({
    String? beforeCreatedAt,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final requests = <RoleRequest>[
      RoleRequest(
        id: 'REQ-1021',
        requesterName: 'Nguyen Anh Duong',
        requesterEmail: 'duong.nguyen@mail.com',
        requestedRole: RoleRequestType.rescuer,
        status: RoleRequestStatus.pending,
        submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
        phone: '+84 98 765 4321',
        address: 'District 7, Ho Chi Minh City',
        idNumber: '079203004531',
        placeOfResidence: 'District 7, Ho Chi Minh City',
        frontImageUrl:
            'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=600&q=80',
        backImageUrl:
            'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=600&q=80',
        notes: 'Has completed first aid training and owns rescue boat.',
      ),
      RoleRequest(
        id: 'REQ-1020',
        requesterName: 'Le Thao Vy',
        requesterEmail: 'thaovy.le@mail.com',
        requestedRole: RoleRequestType.benefactor,
        status: RoleRequestStatus.pending,
        submittedAt: DateTime.now().subtract(const Duration(hours: 6)),
        phone: '+84 91 234 5678',
        address: 'Thu Duc City, Ho Chi Minh City',
        idNumber: '079203004532',
        placeOfResidence: 'Thu Duc City, Ho Chi Minh City',
        frontImageUrl:
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=600&q=80',
        backImageUrl:
            'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?auto=format&fit=crop&w=600&q=80',
        notes: 'Wants to sponsor evacuation kits for 40 families.',
      ),
      RoleRequest(
        id: 'REQ-1019',
        requesterName: 'Tran Bao Long',
        requesterEmail: 'long.tran@mail.com',
        requestedRole: RoleRequestType.rescuer,
        status: RoleRequestStatus.approved,
        submittedAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        phone: '+84 90 887 1234',
        address: 'Binh Thanh District, Ho Chi Minh City',
        idNumber: '079203004533',
        placeOfResidence: 'Binh Thanh District, Ho Chi Minh City',
        frontImageUrl:
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=600&q=80',
        backImageUrl:
            'https://images.unsplash.com/photo-1520813792240-56fc4a3765a7?auto=format&fit=crop&w=600&q=80',
        notes: 'Previously volunteered in 2024 flood response.',
      ),
      RoleRequest(
        id: 'REQ-1018',
        requesterName: 'Pham Gia Han',
        requesterEmail: 'giahan.pham@mail.com',
        requestedRole: RoleRequestType.benefactor,
        status: RoleRequestStatus.rejected,
        submittedAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
        phone: '+84 93 654 0987',
        address: 'Da Nang City',
        idNumber: '079203004534',
        placeOfResidence: 'Da Nang City',
        frontImageUrl:
            'https://images.unsplash.com/photo-1500917293891-ef795e70e1f6?auto=format&fit=crop&w=600&q=80',
        backImageUrl:
            'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=600&q=80',
        notes: 'Incomplete identity document provided.',
      ),
    ];

    return AuthorityRoleRequestPage(
      items: requests,
      hasMore: false,
      nextCursor: null,
    );
  }

  @override
  Future<RoleRequest> approveRoleRequest(String requestId, {String? note}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return RoleRequest(
      id: requestId,
      requesterName: 'Mock User',
      requesterEmail: 'mock@authority.local',
      requestedRole: RoleRequestType.benefactor,
      status: RoleRequestStatus.approved,
      submittedAt: DateTime.now(),
      phone: '',
      address: '',
      idNumber: '',
      frontImageUrl: '',
      backImageUrl: '',
      notes: note ?? '',
    );
  }

  @override
  Future<RoleRequest> rejectRoleRequest(String requestId, {String? note}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return RoleRequest(
      id: requestId,
      requesterName: 'Mock User',
      requesterEmail: 'mock@authority.local',
      requestedRole: RoleRequestType.benefactor,
      status: RoleRequestStatus.rejected,
      submittedAt: DateTime.now(),
      phone: '',
      address: '',
      idNumber: '',
      frontImageUrl: '',
      backImageUrl: '',
      notes: note ?? '',
    );
  }

  @override
  Future<AuthorityCampaignRequestPage> fetchCharityCampaignRequests({
    String? beforeRequestedAt,
    CampaignStatus? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));

    final cutoff = beforeRequestedAt == null
        ? null
        : DateTime.tryParse(beforeRequestedAt);

    final filtered = _campaignRequests.where((campaign) {
      if (status != null && campaign.status != status) {
        return false;
      }

      final requestedAt = _requestOrderingDate(campaign);
      if (cutoff != null && !requestedAt.isBefore(cutoff) && requestedAt.isAtSameMomentAs(cutoff)) {
        return false;
      }

      if (cutoff != null && requestedAt.isAfter(cutoff)) {
        return false;
      }

      return status != null
          ? campaign.status == status
          : campaign.status == CampaignStatus.pending ||
              campaign.status == CampaignStatus.approved ||
              campaign.status == CampaignStatus.rejected;
    }).toList(growable: false);

    filtered.sort((a, b) {
      final aTime = _requestOrderingDate(a);
      final bTime = _requestOrderingDate(b);
      return bTime.compareTo(aTime);
    });

    return AuthorityCampaignRequestPage(
      items: filtered,
      hasMore: false,
      nextCursor: null,
    );
  }

  DateTime _requestOrderingDate(CharityCampaign campaign) {
    return campaign.requestedAt ??
        campaign.startedDonationAt ??
        campaign.startedDistributionAt ??
        campaign.finishedDonationAt ??
        campaign.finishedDistributionAt ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  Future<CharityCampaign> fetchCharityCampaignDetail(String campaignId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _campaignRequests.firstWhere((campaign) => campaign.id == campaignId);
  }

  @override
  Future<CharityCampaign> approveCharityCampaign(
    String campaignId, {
    String? noteByAuthority,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final updated = _updateCampaign(
      campaignId,
      status: CampaignStatus.approved,
      checkedBy: 'authority-mock-id',
      respondedAt: DateTime.now(),
      noteByAuthority: noteByAuthority ?? 'Approved in mock mode.',
    );
    return updated;
  }

  @override
  Future<CharityCampaign> rejectCharityCampaign(
    String campaignId, {
    String? noteByAuthority,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final updated = _updateCampaign(
      campaignId,
      status: CampaignStatus.rejected,
      checkedBy: 'authority-mock-id',
      respondedAt: DateTime.now(),
      noteByAuthority: noteByAuthority ?? 'Rejected in mock mode.',
    );
    return updated;
  }

  CharityCampaign _updateCampaign(
    String campaignId, {
    CampaignStatus? status,
    String? checkedBy,
    DateTime? respondedAt,
    String? noteByAuthority,
  }) {
    final index = _campaignRequests.indexWhere((campaign) => campaign.id == campaignId);
    if (index < 0) {
      throw Exception('Campaign not found');
    }

    final updated = _campaignRequests[index].copyWith(
      status: status,
      checkedBy: checkedBy,
      respondedAt: respondedAt,
      noteByAuthority: noteByAuthority,
    );
    _campaignRequests[index] = updated;
    return updated;
  }
}
