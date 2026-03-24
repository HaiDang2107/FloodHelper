import '../../models/authority/authority_profile.dart';
import '../../models/authority/role_request.dart';
import '../authority_repository.dart';

class MockAuthorityRepository implements AuthorityRepository {
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
}
