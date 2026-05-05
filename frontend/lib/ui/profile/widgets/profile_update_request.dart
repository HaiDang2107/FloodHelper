import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/profile_model.dart';

class ProfileUpdateRequestItem extends StatelessWidget {
  final ProfileUpdateRequestModel request;
  final VoidCallback? onRevoke;

  const ProfileUpdateRequestItem({
    super.key,
    required this.request,
    this.onRevoke,
  });

  Color _getStatusColor() {
    switch (request.state.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'REVOKED':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel() {
    switch (request.state.toUpperCase()) {
      case 'APPROVED':
        return 'Approved';
      case 'REJECTED':
        return 'Rejected';
      case 'REVOKED':
        return 'Revoked';
      default:
        return 'Pending';
    }
  }

  String _formatDateTime(DateTime value) {
    return DateFormat('yyyy-MM-dd HH:mm').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusLabel();
    final statusColor = _getStatusColor();
    final isPending = request.state.toUpperCase() == 'PENDING';

    return Card(
      color: Colors.grey[50],
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200]!, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withValues(alpha: 0.14),
              child: Icon(Icons.assignment_outlined, color: statusColor),
            ),
            title: const Text(
              'Profile update',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Requested at: ${_formatDateTime(request.createdAt)}', style: const TextStyle(color: Colors.black87)),
                if (request.respondedAt != null)
                  Text('Responded at: ${_formatDateTime(request.respondedAt!)}', style: const TextStyle(color: Colors.black87)),
                if (request.authorityName != null)
                  Text('Reviewer: ${request.authorityName}', style: const TextStyle(color: Colors.black87)),
                if (request.note?.trim().isNotEmpty == true)
                  Text('Note: ${request.note!.trim()}', style: const TextStyle(color: Colors.black87)),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          if (isPending && onRevoke != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0, bottom: 8.0, top: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onRevoke,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Revoke Request'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
