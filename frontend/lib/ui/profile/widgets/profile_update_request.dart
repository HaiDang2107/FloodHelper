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
    return DateFormat('dd/MM/yyyy HH:mm').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusLabel();
    final statusColor = _getStatusColor();
    final isPending = request.state.toUpperCase() == 'PENDING';
    final hasChanges = request.changedFields.isNotEmpty;

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
                Text(
                  'Requested at: ${_formatDateTime(request.createdAt)}',
                  style: const TextStyle(color: Colors.black87),
                ),
                if (request.respondedAt != null)
                  Text(
                    'Responded at: ${_formatDateTime(request.respondedAt!)}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                if (request.authorityName != null)
                  Text(
                    'Reviewer: ${request.authorityName}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                if (request.note?.trim().isNotEmpty == true)
                  Text(
                    'Note: ${request.note!.trim()}',
                    style: const TextStyle(color: Colors.black87),
                  ),
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

          // Changed fields diff table
          if (hasChanges) ...[
            Divider(height: 1, color: Colors.grey[200]),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Text(
                'Changed fields',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Table(
                columnWidths: const {
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(),
                  2: FlexColumnWidth(),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    children: [
                      _headerCell('Field'),
                      _headerCell('Current'),
                      _headerCell('Requested'),
                    ],
                  ),
                  for (final f in request.changedFields)
                    TableRow(
                      children: [
                        _dataCell(f.label, bold: true),
                        _dataCell(f.oldValue, color: Colors.red[700]),
                        _dataCell(f.newValue, color: Colors.green[700]),
                      ],
                    ),
                ],
              ),
            ),
          ],

          if (isPending && onRevoke != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onRevoke,
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
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

  Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _dataCell(String text, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          color: color ?? Colors.black87,
        ),
      ),
    );
  }
}
