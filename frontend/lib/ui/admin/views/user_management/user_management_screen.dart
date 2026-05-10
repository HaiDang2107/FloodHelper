import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/admin_theme.dart';
import '../../view_models/admin_user_management_view_model.dart';

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

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User management',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AdminTheme.textDark,
                ),
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
                      onChanged: ref
                          .read(adminUserManagementViewModelProvider.notifier)
                          .updateEmail,
                      decoration: const InputDecoration(
                        labelText: 'Search user by email',
                        hintText: 'authority@example.com',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : () => ref
                            .read(adminUserManagementViewModelProvider.notifier)
                            .search(),
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
                        _InfoRow(label: 'Residence ward', value: _wardText(
                          state.profile!.residenceWardCode,
                          state.profile!.residenceWardName,
                        )),
                        _InfoRow(label: 'Occupation', value: state.profile!.occupation ?? '-'),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            FilledButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.person_add_alt_1),
                              label: const Text('Add Authority'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.manage_accounts),
                              label: const Text('Update Authority'),
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
            const Expanded(
              child: Center(
                child: Text('Search a user to manage authority roles and ward assignment.'),
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
