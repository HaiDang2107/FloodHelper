import 'package:flutter/material.dart';

class DisplayWidget extends StatefulWidget {
  final bool showStrangerLocation;
  final bool showPostLocation;
  final Function(bool) onShowStrangerLocationChanged;
  final Function(bool) onShowPostLocationChanged;

  const DisplayWidget({
    super.key,
    required this.showStrangerLocation,
    required this.showPostLocation,
    required this.onShowStrangerLocationChanged,
    required this.onShowPostLocationChanged,
  });

  @override
  State<DisplayWidget> createState() => _DisplayWidgetState();
}

class _DisplayWidgetState extends State<DisplayWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Display',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: widget.showStrangerLocation,
            onChanged: (value) {
              widget.onShowStrangerLocationChanged(value ?? true);
            },
            title: const Text(
              'Show stranger locations',
              style: TextStyle(color: Colors.black87),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            value: widget.showPostLocation,
            onChanged: (value) {
              widget.onShowPostLocationChanged(value ?? true);
            },
            title: const Text(
              'Show post locations',
              style: TextStyle(color: Colors.black87),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
