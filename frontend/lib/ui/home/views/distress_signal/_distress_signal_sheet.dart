import 'package:flutter/material.dart';
import '../../../../domain/models/distress_signal_input.dart';
import '../../widgets/_distress_signal_sheet/distress_signal_form.dart';
import '../../widgets/_distress_signal_sheet/distress_signal_view.dart';

class DistressSignalSheet extends StatefulWidget {
  final bool isBroadcasting;
  final DistressSignalInput? currentSignalData;
  final ValueChanged<DistressSignalInput> onBroadcast;
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

  void _showBroadcastConfirmation(DistressSignalInput data) {
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
          'If you broadcast a distress signal, you location will be seen by rescuer.\n\nDo you want to continue?',
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
              data: widget.currentSignalData!,
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
