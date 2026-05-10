import '../models/profile_model.dart';

class ProfileMapper {
  static ProfileModel mapResponseToProfileModel(Map<String, dynamic> response) {
    // Handle nested profile structure from backend
    // Backend may return either direct fields or nested under 'profile'
    final profile = response['profile'] != null
        ? response['profile'] as Map<String, dynamic>
        : response;

    final user = profile['user'] != null ? profile['user'] as Map<String, dynamic> : <String, dynamic>{};

    // Extract location if available
    final location =
        profile['location'] != null ? profile['location'] as Map<String, dynamic> : <String, dynamic>{};
    final account = profile['account'] != null
      ? profile['account'] as Map<String, dynamic>
      : <String, dynamic>{};

    return ProfileModel(
      userId: _getString(profile, 'userId') ?? _getString(user, 'id') ?? '',
      fullname: _getString(profile, 'fullname') ?? _getString(user, 'fullname') ?? '',
      nickname: _getString(profile, 'nickname') ?? _getString(user, 'nickname'),
      gender: _getString(profile, 'gender') ?? _getString(user, 'gender'),
      dob: _getString(profile, 'dob') ?? _getString(user, 'dob'),
      originProvinceCode:
          _getInt(profile, 'originProvinceCode') ?? _getInt(user, 'originProvinceCode'),
      originProvinceName:
          _getString(profile, 'originProvinceName') ?? _getString(user, 'originProvinceName'),
      originWardCode: _getInt(profile, 'originWardCode') ?? _getInt(user, 'originWardCode'),
      originWardName: _getString(profile, 'originWardName') ?? _getString(user, 'originWardName'),
      residenceProvinceCode: _getInt(profile, 'residenceProvinceCode') ??
          _getInt(user, 'residenceProvinceCode'),
      residenceProvinceName: _getString(profile, 'residenceProvinceName') ??
          _getString(user, 'residenceProvinceName'),
      residenceWardCode:
          _getInt(profile, 'residenceWardCode') ?? _getInt(user, 'residenceWardCode'),
      residenceWardName:
          _getString(profile, 'residenceWardName') ?? _getString(user, 'residenceWardName'),
      dateOfIssue: _getString(profile, 'dateOfIssue') ?? _getString(user, 'dateOfIssue'),
      dateOfExpire: _getString(profile, 'dateOfExpire') ?? _getString(user, 'dateOfExpire'),
      roles: _getStringList(profile, 'roles') ?? _getStringList(user, 'roles') ?? <String>[],
      longitude: _getDouble(location, 'longitude') ?? _getDouble(profile, 'longitude'),
      latitude: _getDouble(location, 'latitude') ?? _getDouble(profile, 'latitude'),
      visibilityMode:
          _getString(profile, 'visibilityMode') ?? _getString(user, 'visibilityMode') ?? 'PUBLIC',
      showCharityCampaignLocations: _getBool(profile, 'showCharityCampaignLocations') ??
          _getBool(user, 'showCharityCampaignLocations') ??
          false,
      avatarUrl: _getString(profile, 'avatarUrl') ?? _getString(user, 'avatarUrl'),
      citizenId: _getString(profile, 'citizenId') ?? _getString(user, 'citizenId'),
      phoneNumber: _getString(profile, 'phoneNumber') ?? _getString(user, 'phoneNumber') ?? '',
      citizenIdCardImg: _getString(profile, 'citizenIdCardImg'),
      frontCitizenIdCardImageUrl: _getString(profile, 'frontCitizenIdCardImageUrl'),
      backCitizenIdCardImageUrl: _getString(profile, 'backCitizenIdCardImageUrl'),
      occupation: _getString(profile, 'occupation') ?? _getString(user, 'occupation'),
      rescuerCertificateUrl: _getString(profile, 'rescuerCertificateUrl'),
      account: _mapAccountInfo(account),
    );
  }

  static AccountInfo? _mapAccountInfo(Map<String, dynamic> account) {
    if (account.isEmpty) return null;

    return AccountInfo(
      username: _getString(account, 'username') ?? '',
      state: _getString(account, 'state') ?? '',
      createdAt: _parseDate(account['createdAt']),
    );
  }

  static String? _getString(Map<String, dynamic> map, String key) {
    final value = map[key];
    return value is String ? value : null;
  }

  static int? _getInt(Map<String, dynamic> map, String key) {
    final value = map[key];
    return value is int ? value : null;
  }

  static double? _getDouble(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return null;
  }

  static bool? _getBool(Map<String, dynamic> map, String key) {
    final value = map[key];
    return value is bool ? value : null;
  }

  static List<String>? _getStringList(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}
