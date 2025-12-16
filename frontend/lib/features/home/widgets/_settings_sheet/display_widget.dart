import 'package:flutter/material.dart';

class DisplayWidget extends StatefulWidget {
  const DisplayWidget({super.key});

  @override
  State<DisplayWidget> createState() => _DisplayWidgetState();
}

class _DisplayWidgetState extends State<DisplayWidget> {
  bool _showStrangerLocation = true;
  bool _showPostLocation = true;

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
            value: _showStrangerLocation,
            onChanged: (value) {
              setState(() {
                _showStrangerLocation = value ?? true;
              });
            },
            title: const Text(
              'Hiển thị vị trí của người lạ',
              style: TextStyle(color: Colors.black87),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            value: _showPostLocation,
            onChanged: (value) {
              setState(() {
                _showPostLocation = value ?? true;
              });
            },
            title: const Text(
              'Hiển thị vị trí bài post',
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
