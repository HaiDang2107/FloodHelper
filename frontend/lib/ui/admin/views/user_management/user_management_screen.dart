import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/admin_theme.dart';
import '../../view_models/admin_user_management_view_model.dart';
import 'add_authority_modal.dart';
import 'update_authority_modal.dart';
import 'ban_confirm_modal.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUserManagementViewModelProvider);
    final notifier = ref.read(adminUserManagementViewModelProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and "Add Authority" button positioned top-right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'User management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AdminTheme.textDark,
                    ),
              ),
              FilledButton.icon(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => const AddAuthorityModal(),
                  );
                },
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Add Authority'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      onChanged: notifier.updateEmail,
                      decoration: const InputDecoration(
                        labelText: 'Search user by email',
                        hintText: 'authority@example.com',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: state.isLoading ? null : notifier.search,
                    icon: state.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: const Text('Search'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (state.errorMessage != null)
            Text(
              state.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.redAccent,
                  ),
            ),
          const SizedBox(height: 12),
          if (state.profile != null)
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.profile!.fullname,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.profile!.account?.username ?? '-',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF667085),
                              ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: state.profile!.roles
                              .map(
                                (role) => Chip(
                                  label: Text(role),
                                  backgroundColor: AdminTheme.brandBlue.withValues(alpha: 0.08),
                                ),
                              )
                              .toList(growable: false),
                        ),
                        const SizedBox(height: 20),
                        _InfoRow(label: 'User ID', value: state.profile!.userId),
                        _InfoRow(label: 'Phone number', value: state.profile!.phoneNumber),
                        _InfoRow(label: 'Gender', value: state.profile!.gender ?? '-'),
                        _InfoRow(label: 'Date of birth', value: state.profile!.dob ?? '-'),
                        _InfoRow(
                            label: 'Place of origin',
                            value: _wardText(
                              state.profile!.originProvinceCode,
                              state.profile!.originProvinceName,
                            ) +
                                (state.profile!.originWardName != null && state.profile!.originWardName!.isNotEmpty
                                    ? ' - ${state.profile!.originWardName}'
                                    : ''),
                        ),
                        _InfoRow(
                            label: 'Place of residence',
                            value: _wardText(
                              state.profile!.residenceProvinceCode,
                              state.profile!.residenceProvinceName,
                            ) +
                                (state.profile!.residenceWardName != null && state.profile!.residenceWardName!.isNotEmpty
                                    ? ' - ${state.profile!.residenceWardName}'
                                    : ''),
                        ),
                        _InfoRow(label: 'Residence ward', value: _wardText(
                          state.profile!.residenceWardCode,
                          state.profile!.residenceWardName,
                        )),
                        _InfoRow(label: 'Occupation', value: state.profile!.occupation ?? '-'),
                        _InfoRow(label: 'Account status', value: state.profile!.account?.state ?? '-'),
                        const SizedBox(height: 24),
                        // Role-based action buttons
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            // Show "Update Authority" only for authority users
                            if (state.shouldShowUpdateAuthorityButton)
                              OutlinedButton.icon(
                                onPressed: () {
                                  showDialog<void>(
                                    context: context,
                                    builder: (_) => UpdateAuthorityModal(profile: state.profile!),
                                  );
                                },
                                icon: const Icon(Icons.manage_accounts),
                                label: const Text('Update Authority'),
                              ),
                            // Show "Ban" only if user is not already banned
                            if (state.shouldShowBanButton && !state.isBannedAccount)
                              FilledButton.icon(
                                onPressed: () {
                                  showDialog<void>(
                                    context: context,
                                    builder: (_) => BanConfirmModal(profile: state.profile!),
                                  );
                                },
                                icon: const Icon(Icons.block),
                                label: const Text('Ban'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            // Show "Unban" only if user is banned
                            if (state.shouldShowUnbanButton && state.isBannedAccount)
                              FilledButton.icon(
                                onPressed: () {
                                  showDialog<void>(
                                    context: context,
                                    builder: (_) => BanConfirmModal(profile: state.profile!),
                                  );
                                },
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Unban'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Center(
                child: Text(
                  state.isLoading ? 'Searching...' : 'Search a user to manage authority roles and ward assignment.',
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _wardText(int? code, String? name) {
    if (code == null && (name == null || name.isEmpty)) {
      return '-';
    }

    if (code == null) {
      return name!;
    }

    if (name == null || name.isEmpty) {
      return code.toString();
    }

    return '$name ($code)';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
