class AuthorityProfile {
  const AuthorityProfile({
    required this.userId,
    required this.name,
    this.nickname,
    required this.roleTitle,
    required this.email,
    this.phoneNumber,
    this.gender,
    this.dob,
    this.placeOfOrigin,
    this.placeOfResidence,
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
    this.citizenId,
    this.jobPosition,
    required this.avatarUrl,
  });

  final String userId;
  final String name;
  final String? nickname;
  final String roleTitle;
  final String email;
  final String? phoneNumber;
  final String? gender;
  final String? dob;
  final String? placeOfOrigin;
  final String? placeOfResidence;
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
  final String? citizenId;
  final String? jobPosition;
  final String avatarUrl;
}
