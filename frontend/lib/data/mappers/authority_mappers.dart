import '../models/authority/authority_profile.dart';
import '../models/authority/role_request.dart';

class AuthorityMappers {
  static AuthorityProfile profileFromSession(Map<String, dynamic> userData) {
    final roles = (userData['role'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];

    return AuthorityProfile(
      userId: _asString(userData['userId']),
      name: _asString(userData['fullname']),
      nickname: _asNullableString(userData['nickname']),
      roleTitle: _buildRoleTitle(roles),
      email: _asString(userData['username']),
      phoneNumber: _asNullableString(userData['phoneNumber']),
      gender: _asNullableString(userData['gender']),
      dob: _asNullableString(userData['dob']),
      placeOfOrigin: _asNullableString(userData['placeOfOrigin']),
      placeOfResidence: _asNullableString(userData['placeOfResidence']),
      dateOfIssue: _asNullableString(userData['dateOfIssue']),
      dateOfExpire: _asNullableString(userData['dateOfExpire']),
      citizenId: _asNullableString(userData['citizenId']),
      jobPosition: _asNullableString(userData['jobPosition']),
      avatarUrl: _asString(userData['avatarUrl']),
    );
  }

  static RoleRequest roleRequestFromApi(Map<String, dynamic> json) {
    final user = (json['user'] as Map<String, dynamic>?) ?? const {};
    final account = (user['account'] as Map<String, dynamic>?) ?? const {};

    final type = _asString(json['type']).toUpperCase();
    final state = _asString(json['state']).toUpperCase();
    final createdAt = DateTime.tryParse(_asString(json['createdAt']));
    final respondedAt = DateTime.tryParse(_asString(json['responsedAt']));

    final requesterName = _asString(user['fullname']);
    final requesterEmail = _asString(account['username']);
    final citizenIdCardImg = _asString(user['citizenIdCardImg']);
    final placeOfResidence = _asNullableString(user['placeOfResidence']);

    return RoleRequest(
      id: _asString(json['requestId']),
      requesterName: requesterName,
      requesterEmail: requesterEmail,
      requestedRole:
          type == 'RESCUER' ? RoleRequestType.rescuer : RoleRequestType.benefactor,
      status: _mapApiStateToStatus(state),
      submittedAt: createdAt ?? DateTime.now(),
      phone: _asString(user['phoneNumber']),
      address: placeOfResidence ?? _asString(user['placeOfOrigin']),
      idNumber: _asString(user['citizenId']),
      nickname: _asNullableString(user['nickname']),
      gender: _asNullableString(user['gender']),
      dob: _asNullableString(user['dob']),
      placeOfOrigin: _asNullableString(user['placeOfOrigin']),
      placeOfResidence: placeOfResidence,
      dateOfIssue: _asNullableString(user['dateOfIssue']),
      dateOfExpire: _asNullableString(user['dateOfExpire']),
      jobPosition: _asNullableString(user['jobPosition']),
      avatarUrl: _asNullableString(user['avatarUrl']),
      frontImageUrl: citizenIdCardImg,
      backImageUrl: citizenIdCardImg,
      notes: _asString(json['note']),
      respondedAt: respondedAt,
    );
  }

  static RoleRequestStatus _mapApiStateToStatus(String state) {
    switch (state) {
      case 'APPROVED':
        return RoleRequestStatus.approved;
      case 'REJECTED':
        return RoleRequestStatus.rejected;
      case 'PENDING':
      default:
        return RoleRequestStatus.pending;
    }
  }

  static String _buildRoleTitle(List<String> roles) {
    if (roles.isEmpty) {
      return 'Authority';
    }
    return roles.join(', ');
  }

  static String _asString(dynamic value) {
    return value?.toString() ?? '';
  }

  static String? _asNullableString(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }
}