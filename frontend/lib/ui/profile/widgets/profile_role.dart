import 'package:flutter/material.dart';
import '../../../data/models/profile_model.dart';
import '../../../domain/models/models.dart';
import 'role_request.dart';

class ProfileRole extends StatelessWidget {
  final List<UserRole> roles;
  final List<ProfileRoleRequestModel> requests;
  final bool isLoadingRequests;
  final Future<void> Function(UserRole role) onAddRole;
  final Future<void> Function() onRefreshRequests;

  const ProfileRole({
    super.key,
    this.roles = const [],
    this.requests = const [],
    this.isLoadingRequests = false,
    required this.onAddRole,
    required this.onRefreshRequests,
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
              leading: const Icon(Icons.volunteer_activism, color: Colors.green),
              onTap: () async {
                Navigator.pop(context);
                await onAddRole(UserRole.benefactor);
              },
            ),
            ListTile(
              title: const Text('Rescuer'),
              leading: const Icon(Icons.health_and_safety, color: Colors.orange),
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

  void _showSentRequestsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              children: [
                const Text(
              'Sent Requests',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
                const Spacer(),
                IconButton(
                  onPressed: () async => onRefreshRequests(),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoadingRequests)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (requests.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('No role requests submitted yet.'),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final item = requests[index];
                    return RoleRequestItem(
                      roleName: _formatRoleType(item.type),
                      status: _formatRequestState(item.state),
                      date: item.createdAt.toIso8601String().split('T')[0],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatRoleType(String type) {
    switch (type) {
      case 'RESCUER':
        return 'Rescuer';
      case 'BENEFACTOR':
      default:
        return 'Benefactor';
    }
  }

  String _formatRequestState(String state) {
    switch (state) {
      case 'APPROVED':
        return 'Approved';
      case 'REJECTED':
        return 'Rejected';
      case 'PENDING':
      default:
        return 'Pending';
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 4,
          ),
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
          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showAddRoleDialog(context),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add Role'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showSentRequestsSheet(context),
                icon: const Icon(Icons.history),
                label: const Text('Requests'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
