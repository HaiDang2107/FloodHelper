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
  final String? dateOfIssue;
  final String? dateOfExpire;
  final String? citizenId;
  final String? jobPosition;
  final String avatarUrl;
}
