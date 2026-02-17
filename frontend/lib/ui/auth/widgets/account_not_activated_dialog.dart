import 'package:flutter/material.dart';

/// A reusable dialog for handling unactivated account scenarios.
/// This dialog prompts the user to activate their account.
class AccountNotActivatedDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onActivate;

  const AccountNotActivatedDialog({
    super.key,
    required this.onCancel,
    required this.onActivate,
  });

  /// Shows the dialog and returns the result
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AccountNotActivatedDialog(
          onCancel: () => Navigator.of(dialogContext).pop(false),
          onActivate: () => Navigator.of(dialogContext).pop(true),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Account Not Activated'),
      content: const Text(
        'Your account exists but has not been activated yet. '
        'Please verify your account using the activation code sent to your email.',
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onActivate,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F62FE),
          ),
          child: const Text('Activate Account'),
        ),
      ],
    );
  }
}
