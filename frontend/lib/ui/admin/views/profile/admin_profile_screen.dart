import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/admin_theme.dart';
import '../../view_models/admin_profile_view_model.dart';

class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminProfileViewModelProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProfileViewModelProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Admin profile',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AdminTheme.textDark,
                      ),
                ),
              ),
              IconButton(
                onPressed: () => ref.read(adminProfileViewModelProvider.notifier).load(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Reload profile',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (state.errorMessage != null)
            Expanded(
              child: Center(
                child: Text(
                  state.errorMessage!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.redAccent,
                      ),
                ),
              ),
            )
          else if (state.profile == null)
            const Expanded(child: Center(child: Text('Profile unavailable.')))
          else
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AdminTheme.brandBlue.withValues(alpha: 0.12),
                              backgroundImage: state.profile!.avatarUrl != null &&
                                      state.profile!.avatarUrl!.isNotEmpty
                                  ? NetworkImage(state.profile!.avatarUrl!)
                                  : null,
                              child: state.profile!.avatarUrl == null ||
                                      state.profile!.avatarUrl!.isEmpty
                                  ? const Icon(Icons.admin_panel_settings, size: 36)
                                  : null,
                            ),
                            const SizedBox(width: 20),
                            Expanded(
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
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: state.profile!.roles
                                        .map(
                                          (role) => Chip(
                                            label: Text(role),
                                            side: BorderSide(
                                              color: AdminTheme.brandBlue.withValues(alpha: 0.25),
                                            ),
                                            backgroundColor: AdminTheme.brandBlue.withValues(alpha: 0.08),
                                          ),
                                        )
                                        .toList(growable: false),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _InfoRow(label: 'User ID', value: state.profile!.userId),
                        _InfoRow(label: 'Full name', value: state.profile!.fullname),
                        _InfoRow(label: 'Nickname', value: state.profile!.nickname ?? '-'),
                        _InfoRow(label: 'Phone number', value: state.profile!.phoneNumber),
                        _InfoRow(label: 'Gender', value: state.profile!.gender ?? '-'),
                        _InfoRow(label: 'Date of birth', value: _formatDate(state.profile!.dob)),
                        _InfoRow(
                          label: 'Residence ward',
                          value: _wardText(
                            state.profile!.residenceWardCode,
                            state.profile!.residenceWardName,
                          ),
                        ),
                        _InfoRow(
                          label: 'Origin ward',
                          value: _wardText(
                            state.profile!.originWardCode,
                            state.profile!.originWardName,
                          ),
                        ),
                        _InfoRow(label: 'Citizen ID', value: state.profile!.citizenId ?? '-'),
                        _InfoRow(label: 'Occupation', value: state.profile!.occupation ?? '-'),
                        _InfoRow(label: 'Date of issue', value: _formatDate(state.profile!.dateOfIssue)),
                        _InfoRow(label: 'Date of expire', value: _formatDate(state.profile!.dateOfExpire)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return '-';
    }

    final parsed = DateTime.tryParse(text);
    if (parsed == null) {
      return text.split('T').first;
    }

    final year = parsed.year.toString().padLeft(4, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF344054),
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF475467),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
