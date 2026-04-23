/// Profile model for user profile data
class ProfileModel {
  final String userId;
  final String fullname;
  final String? nickname;
  final String? gender;
  final String? dob; // Date of birth in 'YYYY-MM-DD' format
  // final String? placeOfOrigin;
  // final String? placeOfResidence;
  final int? originProvinceCode;
  final String? originProvinceName;
  final int? originWardCode;
  final String? originWardName;
  final int? residenceProvinceCode;
  final String? residenceProvinceName;
  final int? residenceWardCode;
  final String? residenceWardName;
  final String? dateOfIssue;
  final String? dateOfExpire;
  final List<String> roles;
  final double? longitude;
  final double? latitude;
  final String visibilityMode; // PUBLIC | JUST_FRIEND | NO_ONE
  final bool showCharityCampaignLocations;
  final String? avatarUrl;
  final String? citizenId;
  final String phoneNumber;
  final String? citizenIdCardImg;
  final String? jobPosition;
  final AccountInfo? account;

  const ProfileModel({
    required this.userId,
    required this.fullname,
    this.nickname,
    this.gender,
    this.dob,
    // this.placeOfOrigin,
    // this.placeOfResidence,
    this.originProvinceCode,
    this.originProvinceName,
    this.originWardCode,
    this.originWardName,
    this.residenceProvinceCode,
    this.residenceProvinceName,
    this.residenceWardCode,
    this.residenceWardName,
    this.dateOfIssue,
    this.dateOfExpire,
    this.roles = const [],
    this.longitude,
    this.latitude,
    this.visibilityMode = 'PUBLIC',
    this.showCharityCampaignLocations = false,
    this.avatarUrl,
    this.citizenId,
    required this.phoneNumber,
    this.citizenIdCardImg,
    this.jobPosition,
    this.account,
  });

  // /// Full address from village, ward, country
  // String get fullAddress {
  //   return placeOfResidence ?? '';
  // }

  /// Get display name or fallback to name
  String get displayNameOrName => nickname ?? fullname;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['userId'] ?? '',
      fullname: json['fullname'] ?? json['name'] ?? '',
      nickname: json['nickname'] ?? json['displayName'],
      gender: json['gender'],
      dob: json['dob'],
      // placeOfOrigin: json['placeOfOrigin'] ?? json['village'],
      // placeOfResidence: json['placeOfResidence'] ?? json['Ward'] ?? json['country'],
      originProvinceCode: _parseNullableInt(json['originProvinceCode']),
      originProvinceName: json['originProvinceName']?.toString(),
      originWardCode: _parseNullableInt(json['originWardCode']),
      originWardName: json['originWardName']?.toString(),
      residenceProvinceCode: _parseNullableInt(json['residenceProvinceCode']),
      residenceProvinceName: json['residenceProvinceName']?.toString(),
      residenceWardCode: _parseNullableInt(json['residenceWardCode']),
      residenceWardName: json['residenceWardName']?.toString(),
      dateOfIssue: json['dateOfIssue'],
      dateOfExpire: json['dateOfExpire'],
      roles: List<String>.from(json['roles'] ?? []),
      longitude: json['longitude']?.toDouble(),
      latitude: json['latitude']?.toDouble(),
      visibilityMode: json['visibilityMode'] ?? 'PUBLIC',
        showCharityCampaignLocations:
          json['showCharityCampaignLocations'] as bool? ?? false,
      avatarUrl: json['avatarUrl'],
      citizenId: json['citizenId'],
      phoneNumber: json['phoneNumber'] ?? '',
      citizenIdCardImg: json['citizenIdCardImg'],
      jobPosition: json['jobPosition'],
      account: json['account'] != null 
          ? AccountInfo.fromJson(json['account']) 
          : null,
    );
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    return int.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullname': fullname,
      'nickname': nickname,
      'gender': gender,
      'dob': dob,
      // 'placeOfOrigin': placeOfOrigin,
      // 'placeOfResidence': placeOfResidence,
      'originProvinceCode': originProvinceCode,
      'originProvinceName': originProvinceName,
      'originWardCode': originWardCode,
      'originWardName': originWardName,
      'residenceProvinceCode': residenceProvinceCode,
      'residenceProvinceName': residenceProvinceName,
      'residenceWardCode': residenceWardCode,
      'residenceWardName': residenceWardName,
      'dateOfIssue': dateOfIssue,
      'dateOfExpire': dateOfExpire,
      'roles': roles,
      'longitude': longitude,
      'latitude': latitude,
      'visibilityMode': visibilityMode,
      'showCharityCampaignLocations': showCharityCampaignLocations,
      'avatarUrl': avatarUrl,
      'citizenId': citizenId,
      'phoneNumber': phoneNumber,
      'citizenIdCardImg': citizenIdCardImg,
      'jobPosition': jobPosition,
      'account': account?.toJson(),
    };
  }

  ProfileModel copyWith({
    String? userId,
    String? fullname,
    String? nickname,
    String? gender,
    String? dob,
    // String? placeOfOrigin,
    // String? placeOfResidence,
    int? originProvinceCode,
    String? originProvinceName,
    int? originWardCode,
    String? originWardName,
    int? residenceProvinceCode,
    String? residenceProvinceName,
    int? residenceWardCode,
    String? residenceWardName,
    String? dateOfIssue,
    String? dateOfExpire,
    List<String>? roles,
    double? longitude,
    double? latitude,
    String? visibilityMode,
    bool? showCharityCampaignLocations,
    String? avatarUrl,
    String? citizenId,
    String? phoneNumber,
    String? citizenIdCardImg,
    String? jobPosition,
    AccountInfo? account,
  }) {
    return ProfileModel(
      userId: userId ?? this.userId,
      fullname: fullname ?? this.fullname,
      nickname: nickname ?? this.nickname,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      // placeOfOrigin: placeOfOrigin ?? this.placeOfOrigin,
      // placeOfResidence: placeOfResidence ?? this.placeOfResidence,
      originProvinceCode: originProvinceCode ?? this.originProvinceCode,
      originProvinceName: originProvinceName ?? this.originProvinceName,
      originWardCode: originWardCode ?? this.originWardCode,
      originWardName: originWardName ?? this.originWardName,
      residenceProvinceCode: residenceProvinceCode ?? this.residenceProvinceCode,
      residenceProvinceName: residenceProvinceName ?? this.residenceProvinceName,
      residenceWardCode: residenceWardCode ?? this.residenceWardCode,
      residenceWardName: residenceWardName ?? this.residenceWardName,
      dateOfIssue: dateOfIssue ?? this.dateOfIssue,
      dateOfExpire: dateOfExpire ?? this.dateOfExpire,
      roles: roles ?? this.roles,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      visibilityMode: visibilityMode ?? this.visibilityMode,
        showCharityCampaignLocations:
          showCharityCampaignLocations ?? this.showCharityCampaignLocations,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      citizenId: citizenId ?? this.citizenId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      citizenIdCardImg: citizenIdCardImg ?? this.citizenIdCardImg,
      jobPosition: jobPosition ?? this.jobPosition,
      account: account ?? this.account,
    );
  }
}

/// Account information nested in profile
class AccountInfo {
  final String username;
  final String state;
  final DateTime? createdAt;

  const AccountInfo({
    required this.username,
    required this.state,
    this.createdAt,
  });

  factory AccountInfo.fromJson(Map<String, dynamic> json) {
    return AccountInfo(
      username: json['username'] ?? '',
      state: json['state'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'state': state,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

/// DTO for updating profile
class UpdateProfileDto {
  final String? fullname;
  final String? nickname;
  final String? gender;
  final String? dob;
  // final String? placeOfOrigin;
  // final String? placeOfResidence;
  final int? originProvinceCode;
  final String? originProvinceName;
  final int? originWardCode;
  final String? originWardName;
  final int? residenceProvinceCode;
  final String? residenceProvinceName;
  final int? residenceWardCode;
  final String? residenceWardName;
  final String? dateOfIssue;
  final String? dateOfExpire;
  final double? curLongitude;
  final double? curLatitude;
  final String? visibilityMode;
  final bool? showCharityCampaignLocations;
  final String? avatarUrl;
  final String? citizenId;
  final String? citizenIdCardImg;
  final String? jobPosition;

  const UpdateProfileDto({
    this.fullname,
    this.nickname,
    this.gender,
    this.dob,
    // this.placeOfOrigin,
    // this.placeOfResidence,
    this.originProvinceCode,
    this.originProvinceName,
    this.originWardCode,
    this.originWardName,
    this.residenceProvinceCode,
    this.residenceProvinceName,
    this.residenceWardCode,
    this.residenceWardName,
    this.dateOfIssue,
    this.dateOfExpire,
    this.curLongitude,
    this.curLatitude,
    this.visibilityMode,
    this.showCharityCampaignLocations,
    this.avatarUrl,
    this.citizenId,
    this.citizenIdCardImg,
    this.jobPosition,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (fullname != null) map['fullname'] = fullname;
    if (nickname != null) map['nickname'] = nickname;
    if (gender != null) map['gender'] = gender;
    if (dob != null) map['dob'] = dob;
    // if (placeOfOrigin != null) map['placeOfOrigin'] = placeOfOrigin;
    // if (placeOfResidence != null) map['placeOfResidence'] = placeOfResidence;
    if (originProvinceCode != null) map['originProvinceCode'] = originProvinceCode;
    if (originProvinceName != null) map['originProvinceName'] = originProvinceName;
    if (originWardCode != null) map['originWardCode'] = originWardCode;
    if (originWardName != null) map['originWardName'] = originWardName;
    if (residenceProvinceCode != null) map['residenceProvinceCode'] = residenceProvinceCode;
    if (residenceProvinceName != null) map['residenceProvinceName'] = residenceProvinceName;
    if (residenceWardCode != null) map['residenceWardCode'] = residenceWardCode;
    if (residenceWardName != null) map['residenceWardName'] = residenceWardName;
    if (dateOfIssue != null) map['dateOfIssue'] = dateOfIssue;
    if (dateOfExpire != null) map['dateOfExpire'] = dateOfExpire;
    if (curLongitude != null) map['curLongitude'] = curLongitude;
    if (curLatitude != null) map['curLatitude'] = curLatitude;
    if (visibilityMode != null) map['visibilityMode'] = visibilityMode;
    if (showCharityCampaignLocations != null) {
      map['showCharityCampaignLocations'] = showCharityCampaignLocations;
    }
    if (avatarUrl != null) map['avatarUrl'] = avatarUrl;
    if (citizenId != null) map['citizenId'] = citizenId;
    if (citizenIdCardImg != null) map['citizenIdCardImg'] = citizenIdCardImg;
    if (jobPosition != null) map['jobPosition'] = jobPosition;
    return map;
  }
}

class ProfileRoleRequestModel {
  final String requestId;
  final String type;
  final String state;
  final String? note;
  final DateTime createdAt;
  final DateTime? responsedAt;
  final String? authorityName;

  const ProfileRoleRequestModel({
    required this.requestId,
    required this.type,
    required this.state,
    this.note,
    required this.createdAt,
    this.responsedAt,
    this.authorityName,
  });

  factory ProfileRoleRequestModel.fromJson(Map<String, dynamic> json) {
    final authority = json['authority'] as Map<String, dynamic>?;
    final authorityName = authority == null
        ? null
        : (authority['nickname'] ?? authority['fullname'])?.toString();

    return ProfileRoleRequestModel(
      requestId: json['requestId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'BENEFACTOR',
      state: json['state']?.toString() ?? 'PENDING',
      note: json['note']?.toString(),
      createdAt: DateTime.parse(
        json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      responsedAt: json['responsedAt'] != null
          ? DateTime.tryParse(json['responsedAt'].toString())
          : null,
      authorityName: authorityName,
    );
  }
}
