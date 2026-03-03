import 'package:flutter/material.dart';
import '../../widgets/_distress_signal_sheet/distress_signal_form.dart';
import '../../widgets/_distress_signal_sheet/distress_signal_view.dart';

class DistressSignalSheet extends StatefulWidget {
  final bool isBroadcasting;
  final Map<String, dynamic>? currentSignalData;
  final Function(Map<String, dynamic>) onBroadcast;
  final VoidCallback onRevoke;

  const DistressSignalSheet({
    super.key,
    required this.isBroadcasting,
    this.currentSignalData,
    required this.onBroadcast,
    required this.onRevoke,
  });

  @override
  State<DistressSignalSheet> createState() => _DistressSignalSheetState();
}

class _DistressSignalSheetState extends State<DistressSignalSheet> {
  bool _isEditing = false;

  void _showBroadcastConfirmation(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text('Confirm Broadcast'),
          ],
        ),
        content: const Text(
          'If you broadcast a distress signal, your location will be made public.\n\nDo you want to continue?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              widget.onBroadcast(data);
              Navigator.pop(context); // Close bottom sheet
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _handleRevoke() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Signal'),
        content: const Text(
          'Are you sure you want to revoke your distress signal?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              widget.onRevoke();
              Navigator.pop(context); // Close bottom sheet
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: widget.isBroadcasting && !_isEditing
          ? DistressSignalView(
              trappedCounts: widget.currentSignalData!['trappedCounts'] ?? 0,
              childrenNumbers:
                  widget.currentSignalData!['childrenNumbers'] ?? 0,
              elderlyNumbers: widget.currentSignalData!['elderlyNumbers'] ?? 0,
              hasFood: widget.currentSignalData!['hasFood'] ?? false,
              hasWater: widget.currentSignalData!['hasWater'] ?? false,
              other: widget.currentSignalData!['other'],
              onEdit: () {
                setState(() {
                  _isEditing = true;
                });
              },
              onRevoke: _handleRevoke,
            )
          : DistressSignalForm(
              onSubmit: (data) {
                if (widget.isBroadcasting) {
                  // If editing, directly update
                  widget.onBroadcast(data);
                  Navigator.pop(context);
                } else {
                  // If new broadcast, show confirmation
                  _showBroadcastConfirmation(data);
                }
              },
            ),
    );
  }
}
