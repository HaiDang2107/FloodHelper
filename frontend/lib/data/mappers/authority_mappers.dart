import '../models/authority/authority_profile.dart';
import '../models/authority/announcement.dart';
import '../models/authority/role_request.dart';
import '../../domain/models/announcement.dart';

class AuthorityMappers {
  static AuthorityProfile profileFromSession(Map<String, dynamic> userData) {
    final roles =
        (userData['role'] as List<dynamic>?)
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
      placeOfOrigin:
          _formatLocation(
            wardName: _asNullableString(userData['originWardName']),
            provinceName: _asNullableString(userData['originProvinceName']),
          ) ??
          _asNullableString(userData['placeOfOrigin']),
      placeOfResidence:
          _formatLocation(
            wardName: _asNullableString(userData['residenceWardName']),
            provinceName: _asNullableString(userData['residenceProvinceName']),
          ) ??
          _asNullableString(userData['placeOfResidence']),
      originProvinceCode: _asNullableInt(userData['originProvinceCode']),
      originProvinceName: _asNullableString(userData['originProvinceName']),
      originWardCode: _asNullableInt(userData['originWardCode']),
      originWardName: _asNullableString(userData['originWardName']),
      residenceProvinceCode: _asNullableInt(userData['residenceProvinceCode']),
      residenceProvinceName: _asNullableString(
        userData['residenceProvinceName'],
      ),
      residenceWardCode: _asNullableInt(userData['residenceWardCode']),
      residenceWardName: _asNullableString(userData['residenceWardName']),
      dateOfIssue: _asNullableString(userData['dateOfIssue']),
      dateOfExpire: _asNullableString(userData['dateOfExpire']),
      citizenId: _asNullableString(userData['citizenId']),
      occupation: _asNullableString(
        userData['occupation'] ?? userData['occupation'],
      ),
      avatarUrl: _asString(userData['avatarUrl']),
    );
  }

  static RoleRequest roleRequestFromApi(Map<String, dynamic> json) {
    final profile = _asMap(json['profile']) ?? _asMap(json['user']) ?? const {};
    final user = _asMap(profile['user']) ?? const {};
    final account =
        _asMap(user['account']) ?? _asMap(profile['account']) ?? const {};
    final originProvince = _asMap(profile['originProvince']) ?? const {};
    final originWard = _asMap(profile['originWard']) ?? const {};
    final residenceProvince = _asMap(profile['residenceProvince']) ?? const {};
    final residenceWard = _asMap(profile['residenceWard']) ?? const {};

    final type = _asString(json['type']).toUpperCase();
    final state = _asString(json['state']).toUpperCase();
    final createdAt = DateTime.tryParse(_asString(json['createdAt']))?.toLocal();
    final respondedAt = DateTime.tryParse(_asString(json['responsedAt']))?.toLocal();

    final requesterName = _asString(profile['fullname']);
    final requesterEmail = _asString(account['username']);
    final legacyCitizenIdCardImg = _asNullableString(
      profile['citizenIdCardImg'],
    );
    final frontImageUrl =
        _asNullableString(profile['frontCitizenIdCardImageUrl']) ??
        legacyCitizenIdCardImg;
    final backImageUrl =
        _asNullableString(profile['backCitizenIdCardImageUrl']) ??
        legacyCitizenIdCardImg;
    final originProvinceCode = _asNullableInt(
      profile['originProvinceCode'] ?? originProvince['code'],
    );
    final originProvinceName = _asNullableString(
      profile['originProvinceName'] ?? originProvince['name'],
    );
    final originWardCode = _asNullableInt(
      profile['originWardCode'] ?? originWard['code'],
    );
    final originWardName = _asNullableString(
      profile['originWardName'] ?? originWard['name'],
    );
    final residenceProvinceCode = _asNullableInt(
      profile['residenceProvinceCode'] ?? residenceProvince['code'],
    );
    final residenceProvinceName = _asNullableString(
      profile['residenceProvinceName'] ?? residenceProvince['name'],
    );
    final residenceWardCode = _asNullableInt(
      profile['residenceWardCode'] ?? residenceWard['code'],
    );
    final residenceWardName = _asNullableString(
      profile['residenceWardName'] ?? residenceWard['name'],
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
      requestedRole: type == 'RESCUER'
          ? RoleRequestType.rescuer
          : RoleRequestType.benefactor,
      status: _mapApiStateToStatus(state),
      submittedAt: createdAt ?? DateTime.now(),
      phone: _asString(profile['phoneNumber']),
      address: placeOfResidence ?? _asString(profile['placeOfOrigin']),
      idNumber: _asString(profile['citizenId']),
      nickname: _asNullableString(profile['nickname']),
      gender: _asNullableString(profile['gender']),
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
      dob: _normalizeDateText(profile['dob']),
      dateOfIssue: _normalizeDateText(profile['dateOfIssue']),
      dateOfExpire: _normalizeDateText(profile['dateOfExpire']),
      occupation: _asNullableString(
        profile['occupation'] ?? profile['occupation'],
      ),
      avatarUrl: _asNullableString(profile['avatarUrl']),
      frontImageUrl: frontImageUrl,
      backImageUrl: backImageUrl,
      notes: _asString(json['note']),
      respondedAt: respondedAt,
    );
  }

  static AuthorityAnnouncementPage announcementPageFromApi(
    Map<String, dynamic> json,
  ) {
    final payload = _asMap(json['data']) ?? json;
    final items = (payload['items'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(announcementFromApi)
        .toList(growable: false);
    final pagination = _asMap(payload['pagination']) ?? const {};

    return AuthorityAnnouncementPage(
      items: items,
      hasMore: pagination['hasMore'] == true,
      nextCursor: pagination['nextCursor']?.toString(),
    );
  }

  static AuthorityAnnouncement announcementFromApi(Map<String, dynamic> json) {
    final payload = _asMap(json['data']) ?? json;
    return AuthorityAnnouncement(
      id: _asString(payload['announcementId'] ?? payload['id']),
      title: _asString(payload['title']),
      caption: _asNullableString(
        payload['caption'] ?? payload['textContent'] ?? payload['content'],
      ),
      documentUrl: _asNullableString(payload['documentUrl']),
      type: AnnouncementType.fromString(_asString(payload['type'])),
      createdAt: _asLocalDateTime(payload['createdAt']) ?? DateTime.now(),
      publishedBy: _asString(payload['publishedBy'] ?? payload['publisherId']),
    );
  }

  static RoleRequestStatus _mapApiStateToStatus(String state) {
    switch (state) {
      case 'APPROVED':
        return RoleRequestStatus.approved;
      case 'REJECTED':
        return RoleRequestStatus.rejected;
      case 'REVOKED':
        return RoleRequestStatus.revoked;
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

  static Map<String, dynamic>? _asMap(dynamic value) {
    return value is Map<String, dynamic> ? value : null;
  }

  static DateTime? _asLocalDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value.toLocal();
    }

    final parsed = DateTime.tryParse(value.toString());
    return parsed?.toLocal();
  }

  static String? _formatLocation({String? wardName, String? provinceName}) {
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
