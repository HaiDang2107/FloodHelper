enum RoleRequestStatus {
  pending,
  approved,
  rejected,
}

enum RoleRequestType {
  rescuer,
  benefactor,
}

extension RoleRequestStatusLabel on RoleRequestStatus {
  String get label {
    switch (this) {
      case RoleRequestStatus.pending:
        return 'Pending review';
      case RoleRequestStatus.approved:
        return 'Approved';
      case RoleRequestStatus.rejected:
        return 'Rejected';
    }
  }
}

extension RoleRequestTypeLabel on RoleRequestType {
  String get label {
    switch (this) {
      case RoleRequestType.rescuer:
        return 'Rescuer';
      case RoleRequestType.benefactor:
        return 'Benefactor';
    }
  }
}

class RoleRequest {
  const RoleRequest({
    required this.id,
    required this.requesterName,
    required this.requesterEmail,
    required this.requestedRole,
    required this.status,
    required this.submittedAt,
    required this.phone,
    required this.address,
    required this.idNumber,
    this.nickname,
    this.gender,
    this.dob,
    this.placeOfOrigin,
    this.placeOfResidence,
    this.dateOfIssue,
    this.dateOfExpire,
    this.jobPosition,
    this.avatarUrl,
    required this.frontImageUrl,
    required this.backImageUrl,
    required this.notes,
    this.respondedAt,
  });

  final String id;
  final String requesterName;
  final String requesterEmail;
  final RoleRequestType requestedRole;
  final RoleRequestStatus status;
  final DateTime submittedAt;
  final String phone;
  final String address;
  final String idNumber;
  final String? nickname;
  final String? gender;
  final String? dob;
  final String? placeOfOrigin;
  final String? placeOfResidence;
  final String? dateOfIssue;
  final String? dateOfExpire;
  final String? jobPosition;
  final String? avatarUrl;
  final String frontImageUrl;
  final String backImageUrl;
  final String notes;
  final DateTime? respondedAt;

  RoleRequest copyWith({
    RoleRequestStatus? status,
    String? notes,
    DateTime? respondedAt,
  }) {
    return RoleRequest(
      id: id,
      requesterName: requesterName,
      requesterEmail: requesterEmail,
      requestedRole: requestedRole,
      status: status ?? this.status,
      submittedAt: submittedAt,
      phone: phone,
      address: address,
      idNumber: idNumber,
      nickname: nickname,
      gender: gender,
      dob: dob,
      placeOfOrigin: placeOfOrigin,
      placeOfResidence: placeOfResidence,
      dateOfIssue: dateOfIssue,
      dateOfExpire: dateOfExpire,
      jobPosition: jobPosition,
      avatarUrl: avatarUrl,
      frontImageUrl: frontImageUrl,
      backImageUrl: backImageUrl,
      notes: notes ?? this.notes,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}
