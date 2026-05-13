import 'package:flutter/material.dart';
import '../../../data/models/profile_model.dart';
import '../../../domain/models/models.dart';
import 'role_request.dart';
import 'profile_update_request.dart';

class ProfileRole extends StatelessWidget {
  final List<UserRole> roles;
  final List<ProfileRoleRequestModel> requests;
  final List<ProfileUpdateRequestModel> profileUpdateRequests;
  final bool isLoadingRequests;
  final bool isLoadingProfileUpdateRequests;
  final Future<void> Function(UserRole role) onAddRole;
  final Future<List<ProfileRoleRequestModel>> Function() onRefreshRequests;
  final Future<List<ProfileUpdateRequestModel>> Function()
  onRefreshProfileUpdateRequests;
  final Future<void> Function(String requestId) onRevokeProfileUpdateRequest;
  final bool canSubmitRoleRequest;
  final String? roleRequestBlockedReason;

  const ProfileRole({
    super.key,
    this.roles = const [],
    this.requests = const [],
    this.profileUpdateRequests = const [],
    this.isLoadingRequests = false,
    this.isLoadingProfileUpdateRequests = false,
    required this.onAddRole,
    required this.onRefreshRequests,
    required this.onRefreshProfileUpdateRequests,
    required this.onRevokeProfileUpdateRequest,
    this.canSubmitRoleRequest = true,
    this.roleRequestBlockedReason,
  });

  void _showAddRoleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request New Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a role you want to apply for:'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Benefactor'),
              leading: const Icon(
                Icons.volunteer_activism,
                color: Colors.green,
              ),
              onTap: () async {
                Navigator.pop(context);
                await onAddRole(UserRole.benefactor);
              },
            ),
            ListTile(
              title: const Text('Rescuer'),
              leading: const Icon(Icons.shield, color: Colors.orange),
              onTap: () async {
                Navigator.pop(context);
                await onAddRole(UserRole.rescuer);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: Theme.of(context).primaryColor, width: 4),
        ),
      ),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roleDisplay = roles.isEmpty
        ? 'Normal User'
        : roles.map((r) => r.displayName).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Role Management'),
        const SizedBox(height: 16),
        Text(
          'Current Role: $roleDisplay',
          style: const TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        if (!canSubmitRoleRequest)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFD7A8)),
            ),
            child: Text(
              roleRequestBlockedReason ??
                  'Please complete your profile (including avatar and CCCD images) before requesting a new role.',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8A4B00),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: canSubmitRoleRequest
                    ? () => _showAddRoleDialog(context)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add Role'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

void showSentRequestsSheet(
  BuildContext context, {
  required List<ProfileRoleRequestModel> requests,
  required List<ProfileUpdateRequestModel> profileUpdateRequests,
  required bool isLoadingRequests,
  required bool isLoadingProfileUpdateRequests,
  required Future<List<ProfileRoleRequestModel>> Function() onRefreshRequests,
  required Future<List<ProfileUpdateRequestModel>> Function()
  onRefreshProfileUpdateRequests,
  required Future<void> Function(String) onRevokeProfileUpdateRequest,
  required Future<void> Function(String) onRevokeRoleRequest,
}) {
  var sheetRequests = List<ProfileRoleRequestModel>.from(requests);
  var sheetProfileRequests = List<ProfileUpdateRequestModel>.from(
    profileUpdateRequests,
  );
  var sheetLoading = isLoadingRequests;
  var sheetProfileLoading = isLoadingProfileUpdateRequests;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => StatefulBuilder(
      builder: (context, setSheetState) => DefaultTabController(
        length: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                children: [
                  const Text(
                    'Sent Requests',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () async {
                      setSheetState(() {
                        sheetLoading = true;
                        sheetProfileLoading = true;
                      });

                      try {
                        final refreshed = await onRefreshRequests();
                        final refreshedProfiles =
                            await onRefreshProfileUpdateRequests();
                        setSheetState(() {
                          sheetRequests = refreshed;
                          sheetProfileRequests = refreshedProfiles;
                          sheetLoading = false;
                          sheetProfileLoading = false;
                        });
                      } catch (_) {
                        setSheetState(() {
                          sheetLoading = false;
                          sheetProfileLoading = false;
                        });
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const TabBar(
                labelColor: Colors.black87,
                indicatorColor: Colors.black87,
                tabs: [
                  Tab(text: 'Role requests'),
                  Tab(text: 'Profile updates'),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    if (sheetLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (sheetRequests.isEmpty)
                      const Center(
                        child: Text('No role requests submitted yet.'),
                      )
                    else
                      ListView.builder(
                        itemCount: sheetRequests.length,
                        itemBuilder: (context, index) {
                          final item = sheetRequests[index];
                          return RoleRequestItem(
                            request: item,
                            onRevoke: item.state.toUpperCase() == 'PENDING'
                                ? () async {
                                    // Optimistic UI update
                                    setSheetState(() {
                                      final idx = sheetRequests.indexOf(item);
                                      if (idx != -1) {
                                        sheetRequests[idx] =
                                            ProfileRoleRequestModel(
                                              requestId: item.requestId,
                                              type: item.type,
                                              state: 'REVOKED',
                                              createdAt: item.createdAt,
                                              responsedAt: DateTime.now(),
                                              authorityName: item.authorityName,
                                              note: item.note,
                                            );
                                      }
                                    });

                                    await onRevokeRoleRequest(item.requestId);
                                    try {
                                      final refreshed =
                                          await onRefreshRequests();
                                      setSheetState(() {
                                        sheetRequests = refreshed;
                                      });
                                    } catch (_) {}
                                  }
                                : null,
                          );
                        },
                      ),
                    if (sheetProfileLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (sheetProfileRequests.isEmpty)
                      const Center(
                        child: Text('No profile update requests yet.'),
                      )
                    else
                      ListView.builder(
                        itemCount: sheetProfileRequests.length,
                        itemBuilder: (context, index) {
                          final item = sheetProfileRequests[index];
                          return ProfileUpdateRequestItem(
                            request: item,
                            onRevoke: item.state.toUpperCase() == 'PENDING'
                                ? () async {
                                    // Optimistic UI update
                                    setSheetState(() {
                                      final idx = sheetProfileRequests.indexOf(
                                        item,
                                      );
                                      if (idx != -1) {
                                        sheetProfileRequests[idx] =
                                            ProfileUpdateRequestModel(
                                              requestId: item.requestId,
                                              state: 'REVOKED',
                                              createdAt: item.createdAt,
                                              respondedAt: DateTime.now(),
                                              authorityName: item.authorityName,
                                              note: item.note,
                                            );
                                      }
                                    });

                                    await onRevokeProfileUpdateRequest(
                                      item.requestId,
                                    );
                                    try {
                                      final refreshedProfiles =
                                          await onRefreshProfileUpdateRequests();
                                      setSheetState(() {
                                        sheetProfileRequests =
                                            refreshedProfiles;
                                      });
                                    } catch (_) {}
                                  }
                                : null,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
