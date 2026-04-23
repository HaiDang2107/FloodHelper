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
    final originProvince = (user['originProvince'] as Map<String, dynamic>?) ??
      const {};
    final originWard = (user['originWard'] as Map<String, dynamic>?) ?? const {};
    final residenceProvince =
      (user['residenceProvince'] as Map<String, dynamic>?) ?? const {};
    final residenceWard =
      (user['residenceWard'] as Map<String, dynamic>?) ?? const {};

    final type = _asString(json['type']).toUpperCase();
    final state = _asString(json['state']).toUpperCase();
    final createdAt = DateTime.tryParse(_asString(json['createdAt']));
    final respondedAt = DateTime.tryParse(_asString(json['responsedAt']));

    final requesterName = _asString(user['fullname']);
    final requesterEmail = _asString(account['username']);
    final citizenIdCardImg = _asString(user['citizenIdCardImg']);
    final originProvinceCode = _asNullableInt(
      user['originProvinceCode'] ?? originProvince['code'],
    );
    final originProvinceName = _asNullableString(
      user['originProvinceName'] ?? originProvince['name'],
    );
    final originWardCode = _asNullableInt(user['originWardCode'] ?? originWard['code']);
    final originWardName = _asNullableString(
      user['originWardName'] ?? originWard['name'],
    );
    final residenceProvinceCode = _asNullableInt(
      user['residenceProvinceCode'] ?? residenceProvince['code'],
    );
    final residenceProvinceName = _asNullableString(
      user['residenceProvinceName'] ?? residenceProvince['name'],
    );
    final residenceWardCode = _asNullableInt(
      user['residenceWardCode'] ?? residenceWard['code'],
    );
    final residenceWardName = _asNullableString(
      user['residenceWardName'] ?? residenceWard['name'],
    );

    final placeOfOrigin = _formatLocation(
      wardName: originWardName,
      provinceName: originProvinceName,
    );
    final placeOfResidence = _formatLocation(
      wardName: residenceWardName,
      provinceName: residenceProvinceName,
    );

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
      placeOfOrigin: placeOfOrigin,
      placeOfResidence: placeOfResidence,
      originProvinceCode: originProvinceCode,
      originProvinceName: originProvinceName,
      originWardCode: originWardCode,
      originWardName: originWardName,
      residenceProvinceCode: residenceProvinceCode,
      residenceProvinceName: residenceProvinceName,
      residenceWardCode: residenceWardCode,
      residenceWardName: residenceWardName,
      dob: _normalizeDateText(user['dob']),
      dateOfIssue: _normalizeDateText(user['dateOfIssue']),
      dateOfExpire: _normalizeDateText(user['dateOfExpire']),
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

  static int? _asNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  static String? _formatLocation({
    String? wardName,
    String? provinceName,
  }) {
    final parts = [wardName, provinceName]
        .where((part) => part != null && part.trim().isNotEmpty)
        .map((part) => part!.trim())
        .toList(growable: false);

    if (parts.isEmpty) {
      return null;
    }

    return parts.join(', ');
  }

  static String? _normalizeDateText(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return _formatDateOnly(value);
    }

    final text = value.toString().trim();
    if (text.isEmpty) {
      return null;
    }

    final parsed = DateTime.tryParse(text);
    if (parsed != null) {
      return _formatDateOnly(parsed);
    }

    final dateOnly = text.split('T').first;
    return dateOnly.isEmpty ? null : dateOnly;
  }

  static String _formatDateOnly(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}