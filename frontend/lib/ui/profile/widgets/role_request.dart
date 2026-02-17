import 'package:flutter/material.dart';

class RoleRequestItem extends StatelessWidget {
  final String roleName;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final String date;

  const RoleRequestItem({
    super.key,
    required this.roleName,
    required this.status,
    required this.date,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: Icon(Icons.security, color: Colors.blue),
        ),
        title: Text(
          roleName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Requested on: $date'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _getStatusColor()),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: _getStatusColor(),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
