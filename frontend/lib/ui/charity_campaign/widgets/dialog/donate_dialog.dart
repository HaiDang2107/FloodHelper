import 'package:flutter/material.dart';

class DonateDialog extends StatelessWidget {
  const DonateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Donate',
        style: TextStyle(
          // color: Color(0xFF0F62FE),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Scan the QR code to donate.',
            style: TextStyle(
              // color: Color(0xFF0F62FE),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          // Placeholder for QR code
          Container(
            width: 200,
            height: 200,
            color: Colors.grey[300],
            child: const Center(child: Icon(Icons.qr_code, size: 100)),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: const Text(
              'Important: To ensure your transaction is recorded correctly, please use the pre-filled message when transferring. Otherwise, it may not be listed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.deepOrange, fontSize: 12),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
