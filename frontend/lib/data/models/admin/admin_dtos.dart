/// DTO for creating a new authority
/// Password is auto-generated on backend and sent via email
class CreateAuthorityDto {
  final String fullname;
  final String phoneNumber;
  final String username;
  final int residenceWardCode;
  final String? nickname;
  final String? gender;
  final String? dob;
  final int? originProvinceCode;
  final int? originWardCode;
  final int? residenceProvinceCode;
  final String? dateOfIssue;
  final String? dateOfExpire;
  final String? citizenId;
  final String? occupation;

  const CreateAuthorityDto({
    required this.fullname,
    required this.phoneNumber,
    required this.username,
    required this.residenceWardCode,
    this.nickname,
    this.gender,
    this.dob,
    this.originProvinceCode,
    this.originWardCode,
    this.residenceProvinceCode,
    this.dateOfIssue,
    this.dateOfExpire,
    this.citizenId,
    this.occupation,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'phoneNumber': phoneNumber,
      'username': username,
      'residenceWardCode': residenceWardCode,
      if (nickname != null && nickname!.isNotEmpty) 'nickname': nickname,
      if (gender != null && gender!.isNotEmpty) 'gender': gender,
      if (dob != null && dob!.isNotEmpty) 'dob': dob,
      if (originProvinceCode != null) 'originProvinceCode': originProvinceCode,
      if (originWardCode != null) 'originWardCode': originWardCode,
      if (residenceProvinceCode != null) 'residenceProvinceCode': residenceProvinceCode,
      if (dateOfIssue != null && dateOfIssue!.isNotEmpty) 'dateOfIssue': dateOfIssue,
      if (dateOfExpire != null && dateOfExpire!.isNotEmpty) 'dateOfExpire': dateOfExpire,
      if (citizenId != null && citizenId!.isNotEmpty) 'citizenId': citizenId,
      if (occupation != null && occupation!.isNotEmpty) 'occupation': occupation,
    };
  }
}

/// DTO for updating authority (profile + role + ward)
class UpdateAuthorityDto {
  final String? fullname;
  final String? nickname;
  final String? phoneNumber;
  final String? gender;
  final String? dob;
  final int? originProvinceCode;
  final int? originWardCode;
  final int? residenceProvinceCode;
  final int? residenceWardCode;
  final String? dateOfIssue;
  final String? dateOfExpire;
  final String? citizenId;
  final String? occupation;
  final bool? isAuthority;

  const UpdateAuthorityDto({
    this.fullname,
    this.nickname,
    this.phoneNumber,
    this.gender,
    this.dob,
    this.originProvinceCode,
    this.originWardCode,
    this.residenceProvinceCode,
    this.residenceWardCode,
    this.dateOfIssue,
    this.dateOfExpire,
    this.citizenId,
    this.occupation,
    this.isAuthority,
  });

  Map<String, dynamic> toJson() {
    return {
      if (fullname != null && fullname!.isNotEmpty) 'fullname': fullname,
      if (nickname != null && nickname!.isNotEmpty) 'nickname': nickname,
      if (phoneNumber != null && phoneNumber!.isNotEmpty) 'phoneNumber': phoneNumber,
      if (gender != null && gender!.isNotEmpty) 'gender': gender,
      if (dob != null && dob!.isNotEmpty) 'dob': dob,
      if (originProvinceCode != null) 'originProvinceCode': originProvinceCode,
      if (originWardCode != null) 'originWardCode': originWardCode,
      if (residenceProvinceCode != null) 'residenceProvinceCode': residenceProvinceCode,
      if (residenceWardCode != null) 'residenceWardCode': residenceWardCode,
      if (dateOfIssue != null && dateOfIssue!.isNotEmpty) 'dateOfIssue': dateOfIssue,
      if (dateOfExpire != null && dateOfExpire!.isNotEmpty) 'dateOfExpire': dateOfExpire,
      if (citizenId != null && citizenId!.isNotEmpty) 'citizenId': citizenId,
      if (occupation != null && occupation!.isNotEmpty) 'occupation': occupation,
      if (isAuthority != null) 'isAuthority': isAuthority,
    };
  }
}
