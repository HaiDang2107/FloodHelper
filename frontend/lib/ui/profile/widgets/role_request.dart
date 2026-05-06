import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/profile_model.dart';

class RoleRequestItem extends StatelessWidget {
  final ProfileRoleRequestModel request;
  final VoidCallback? onRevoke;

  const RoleRequestItem({
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

  String _roleLabel() {
    switch (request.type.toUpperCase()) {
      case 'RESCUER':
        return 'Rescuer';
      default:
        return 'Benefactor';
    }
  }

  IconData _roleIcon() {
    switch (request.type.toUpperCase()) {
      case 'RESCUER':
        return Icons.shield;
      default:
        return Icons.volunteer_activism;
    }
  }

  Color _roleIconColor() {
    switch (request.type.toUpperCase()) {
      case 'RESCUER':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  String _formatDateTime(DateTime value) {
    return DateFormat('dd/MM/yyyy HH:mm').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusLabel();
    final statusColor = _getStatusColor();
    final showResponseInfo = request.state == 'APPROVED' || request.state == 'REJECTED';

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
              backgroundColor: _roleIconColor().withValues(alpha: 0.14),
              child: Icon(_roleIcon(), color: _roleIconColor()),
            ),
            title: Text(
              _roleLabel(),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Requested at: ${_formatDateTime(request.createdAt)}', style: const TextStyle(color: Colors.black87)),
                if (showResponseInfo)
                  Text(
                    'Responded at: ${request.responsedAt != null ? _formatDateTime(request.responsedAt!) : '-'}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                if (showResponseInfo)
                  Text('Note: ${request.note?.trim().isNotEmpty == true ? request.note!.trim() : 'No note'}', style: const TextStyle(color: Colors.black87)),
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
          if (request.state.toUpperCase() == 'PENDING' && onRevoke != null)
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
