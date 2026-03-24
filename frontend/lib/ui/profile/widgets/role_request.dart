import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/profile_model.dart';

class RoleRequestItem extends StatelessWidget {
  final ProfileRoleRequestModel request;

  const RoleRequestItem({
    super.key,
    required this.request,
  });

  Color _getStatusColor() {
    switch (request.state.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
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
    return DateFormat('yyyy-MM-dd HH:mm').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusLabel();
    final statusColor = _getStatusColor();
    final showResponseInfo = request.state == 'APPROVED' || request.state == 'REJECTED';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _roleIconColor().withValues(alpha: 0.14),
          child: Icon(_roleIcon(), color: _roleIconColor()),
        ),
        title: Text(
          _roleLabel(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Requested at: ${_formatDateTime(request.createdAt)}'),
            if (showResponseInfo)
              Text(
                'Responded at: ${request.responsedAt != null ? _formatDateTime(request.responsedAt!) : '-'}',
              ),
            if (showResponseInfo)
              Text('Note: ${request.note?.trim().isNotEmpty == true ? request.note!.trim() : 'No note'}'),
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
    );
  }
}
