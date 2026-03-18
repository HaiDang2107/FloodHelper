/// Profile model for user profile data
class ProfileModel {
  final String userId;
  final String name;
  final String? displayName;
  final String? gender;
  final String? dob; // Date of birth in 'YYYY-MM-DD' format
  final String? village;
  final String? district;
  final String? country;
  final List<String> roles;
  final double? longitude;
  final double? latitude;
  final String visibilityMode; // PUBLIC | JUST_FRIEND | NO_ONE
  final String? avatarUrl;
  final String? citizenId;
  final String phoneNumber;
  final String? citizenIdCardImg;
  final String? jobPosition;
  final AccountInfo? account;

  const ProfileModel({
    required this.userId,
    required this.name,
    this.displayName,
    this.gender,
    this.dob,
    this.village,
    this.district,
    this.country,
    this.roles = const [],
    this.longitude,
    this.latitude,
    this.visibilityMode = 'PUBLIC',
    this.avatarUrl,
    this.citizenId,
    required this.phoneNumber,
    this.citizenIdCardImg,
    this.jobPosition,
    this.account,
  });

  /// Full address from village, district, country
  String get fullAddress {
    final parts = [village, district, country].where((p) => p != null && p.isNotEmpty);
    return parts.join(', ');
  }

  /// Get display name or fallback to name
  String get displayNameOrName => displayName ?? name;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'],
      gender: json['gender'],
      dob: json['dob'],
      village: json['village'],
      district: json['district'],
      country: json['country'],
      roles: List<String>.from(json['roles'] ?? []),
      longitude: json['longitude']?.toDouble(),
      latitude: json['latitude']?.toDouble(),
      visibilityMode: json['visibilityMode'] ?? 'PUBLIC',
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

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'displayName': displayName,
      'gender': gender,
      'dob': dob,
      'village': village,
      'district': district,
      'country': country,
      'roles': roles,
      'longitude': longitude,
      'latitude': latitude,
      'visibilityMode': visibilityMode,
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
    String? name,
    String? displayName,
    String? gender,
    String? dob,
    String? village,
    String? district,
    String? country,
    List<String>? roles,
    double? longitude,
    double? latitude,
    String? visibilityMode,
    String? avatarUrl,
    String? citizenId,
    String? phoneNumber,
    String? citizenIdCardImg,
    String? jobPosition,
    AccountInfo? account,
  }) {
    return ProfileModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      village: village ?? this.village,
      district: district ?? this.district,
      country: country ?? this.country,
      roles: roles ?? this.roles,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      visibilityMode: visibilityMode ?? this.visibilityMode,
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
  final String? displayName;
  final String? gender;
  final String? dob;
  final String? village;
  final String? district;
  final String? country;
  final double? curLongitude;
  final double? curLatitude;
  final String? visibilityMode;
  final String? avatarUrl;
  final String? citizenId;
  final String? citizenIdCardImg;
  final String? jobPosition;

  const UpdateProfileDto({
    this.displayName,
    this.gender,
    this.dob,
    this.village,
    this.district,
    this.country,
    this.curLongitude,
    this.curLatitude,
    this.visibilityMode,
    this.avatarUrl,
    this.citizenId,
    this.citizenIdCardImg,
    this.jobPosition,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (displayName != null) map['displayName'] = displayName;
    if (gender != null) map['gender'] = gender;
    if (dob != null) map['dob'] = dob;
    if (village != null) map['village'] = village;
    if (district != null) map['district'] = district;
    if (country != null) map['country'] = country;
    if (curLongitude != null) map['curLongitude'] = curLongitude;
    if (curLatitude != null) map['curLatitude'] = curLatitude;
    if (visibilityMode != null) map['visibilityMode'] = visibilityMode;
    if (avatarUrl != null) map['avatarUrl'] = avatarUrl;
    if (citizenId != null) map['citizenId'] = citizenId;
    if (citizenIdCardImg != null) map['citizenIdCardImg'] = citizenIdCardImg;
    if (jobPosition != null) map['jobPosition'] = jobPosition;
    return map;
  }
}
