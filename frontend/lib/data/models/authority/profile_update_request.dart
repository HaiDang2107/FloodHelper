import '../profile_model.dart';
import 'role_request.dart';

class AuthorityProfileUpdateRequest {
  const AuthorityProfileUpdateRequest({
    required this.id,
    required this.requesterName,
    required this.requesterEmail,
    required this.requesterRole,
    required this.status,
    required this.submittedAt,
    required this.changedFields,
    required this.notes,
    this.respondedAt,
  });

  final String id;
  final String requesterName;
  final String requesterEmail;
  final RoleRequestType requesterRole;
  final RoleRequestStatus status;
  final DateTime submittedAt;
  final List<ProfileFieldChange> changedFields;
  final String notes;
  final DateTime? respondedAt;

  AuthorityProfileUpdateRequest copyWith({
    RoleRequestStatus? status,
    String? notes,
    DateTime? respondedAt,
  }) {
    return AuthorityProfileUpdateRequest(
      id: id,
      requesterName: requesterName,
      requesterEmail: requesterEmail,
      requesterRole: requesterRole,
      status: status ?? this.status,
      submittedAt: submittedAt,
      changedFields: changedFields,
      notes: notes ?? this.notes,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}
