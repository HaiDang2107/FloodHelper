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
    required this.frontImageUrl,
    required this.backImageUrl,
    required this.notes,
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
  final String frontImageUrl;
  final String backImageUrl;
  final String notes;
}
