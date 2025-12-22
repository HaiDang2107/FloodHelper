import 'package:flutter/material.dart';
import 'role_request.dart';

class ProfileRole extends StatelessWidget {
  const ProfileRole({super.key});

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
              leading: const Icon(Icons.volunteer_activism, color: Colors.orange),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request for Benefactor sent!')),
                );
              },
            ),
            ListTile(
              title: const Text('Rescuer'),
              leading: const Icon(Icons.medical_services, color: Colors.green),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request for Rescuer sent!')),
                );
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sent Requests',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    RoleRequestItem(
                      roleName: 'Benefactor',
                      status: 'Pending',
                      date: '2023-10-25',
                    ),
                    RoleRequestItem(
                      roleName: 'Rescuer',
                      status: 'Rejected',
                      date: '2023-10-20',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Role Management'),
        const SizedBox(height: 16),
        const Text(
          'Current Role: Normal User',
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black87),
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
