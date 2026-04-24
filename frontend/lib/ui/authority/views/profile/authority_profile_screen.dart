import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/authority_theme.dart';
import '../../view_models/authority_profile_view_model.dart';

class AuthorityProfileScreen extends ConsumerStatefulWidget {
  const AuthorityProfileScreen({super.key});

  @override
  ConsumerState<AuthorityProfileScreen> createState() =>
      _AuthorityProfileScreenState();
}

class _AuthorityProfileScreenState
    extends ConsumerState<AuthorityProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authorityProfileViewModelProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authorityProfileViewModelProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Authority profile',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AuthorityTheme.textDark,
                ),
          ),
          const SizedBox(height: 16),
          if (state.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (state.profile != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: state.profile!.avatarUrl.isNotEmpty
                        ? NetworkImage(state.profile!.avatarUrl)
                        : null,
                      child: state.profile!.avatarUrl.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.profile!.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            state.profile!.roleTitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: const Color(0xFF667085)),
                          ),
                          const SizedBox(height: 12),
                          _ProfileRow(
                            label: 'Email',
                            value: state.profile!.email,
                          ),
                          _ProfileRow(
                            label: 'Nickname',
                            value: state.profile!.nickname ?? '-',
                          ),
                          _ProfileRow(
                            label: 'Phone',
                            value: state.profile!.phoneNumber ?? '-',
                          ),
                          _ProfileRow(
                            label: 'Gender',
                            value: state.profile!.gender ?? '-',
                          ),
                          _ProfileRow(
                            label: 'Date of Birth',
                            value: _formatDateOnly(state.profile!.dob),
                          ),
                          _LocationSection(
                            label: 'Place of Origin',
                            province: _displayText(
                              state.profile!.originProvinceName,
                              fallback: state.profile!.placeOfOrigin,
                              partIndex: 1,
                            ),
                            ward: _displayText(
                              state.profile!.originWardName,
                              fallback: state.profile!.placeOfOrigin,
                              partIndex: 0,
                            ),
                          ),
                          _LocationSection(
                            label: 'Place of Residence',
                            province: _displayText(
                              state.profile!.residenceProvinceName,
                              fallback: state.profile!.placeOfResidence,
                              partIndex: 1,
                            ),
                            ward: _displayText(
                              state.profile!.residenceWardName,
                              fallback: state.profile!.placeOfResidence,
                              partIndex: 0,
                            ),
                          ),
                          _ProfileRow(
                            label: 'Citizen ID',
                            value: state.profile!.citizenId ?? '-',
                          ),
                          _ProfileRow(
                            label: 'Date of Issue',
                            value: _formatDateOnly(state.profile!.dateOfIssue),
                          ),
                          _ProfileRow(
                            label: 'Date of Expire',
                            value: _formatDateOnly(state.profile!.dateOfExpire),
                          ),
                          _ProfileRow(
                            label: 'Job Position',
                            value: state.profile!.jobPosition ?? '-',
                          ),
                          _ProfileRow(
                            label: 'Role',
                            value: state.profile!.roleTitle,
                          ),
                          _ProfileRow(
                            label: 'User ID',
                            value: state.profile!.userId,
                          ),
                          _ProfileRow(
                            label: 'Department',
                            value: state.profile!.placeOfResidence ?? '-',
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AuthorityTheme.brandBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const Text('Profile unavailable.'),
        ],
      ),
    );
  }

  String _formatDateOnly(String? value) {
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

  String _displayText(
    String? value, {
    String? fallback,
    required int partIndex,
  }) {
    final text = value?.trim();
    if (text != null && text.isNotEmpty) {
      return text;
    }

    return _splitLocationPart(fallback, partIndex);
  }

  String _splitLocationPart(String? value, int index) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return '-';
    }

    final parts = text
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) {
      return '-';
    }

    if (index < 0 || index >= parts.length) {
      return parts.last;
    }

    return parts[index];
  }
}

class _LocationSection extends StatelessWidget {
  const _LocationSection({
    required this.label,
    required this.province,
    required this.ward,
  });

  final String label;
  final String province;
  final String ward;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: const Color(0xFF667085)),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Province: $province',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ward: $ward',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: const Color(0xFF667085)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
