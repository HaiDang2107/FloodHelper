import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../view_models/admin_user_management_view_model.dart';
import 'package:antiflood/data/models/profile_model.dart';

/// Ban/Unban confirmation modal dialog
class BanConfirmModal extends ConsumerWidget {
  const BanConfirmModal({
    required this.profile,
    super.key,
  });

  final ProfileModel profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(adminUserManagementViewModelProvider.notifier);
    final state = ref.watch(adminUserManagementViewModelProvider);
    final isBanned = state.isBannedAccount;

    return AlertDialog(
      title: Text(isBanned ? 'Unban Account?' : 'Ban Account?'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User: ${profile.fullname}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Email: ${profile.account?.username}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              isBanned
                  ? 'This will restore account access. The user will be able to log in again.'
                  : 'This will disable the account and prevent login.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: isBanned ? Colors.green : Colors.red,
          ),
          onPressed: state.isBanningUser
              ? null
              : () {
                  if (isBanned) {
                    notifier.unbanUser(profile.userId);
                  } else {
                    notifier.banUser(profile.userId);
                  }
                  Navigator.of(context).pop();
                },
          child: state.isBanningUser
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isBanned ? 'Unban' : 'Ban'),
        ),
      ],
    );
  }
}
