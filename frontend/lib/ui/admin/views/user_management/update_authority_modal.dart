import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../view_models/admin_user_management_view_model.dart';
import '../../../../domain/models/user_profile.dart';
import '../../../core/common/widgets/location_selector.dart';
import 'package:antiflood/data/models/profile_model.dart';
import 'package:antiflood/data/models/admin/admin_dtos.dart';
import 'package:antiflood/data/providers/repository_providers.dart';

/// Modal for updating an authority's information
class UpdateAuthorityModal extends ConsumerStatefulWidget {
  const UpdateAuthorityModal({
    required this.profile,
    super.key,
  });

  final ProfileModel profile;

  @override
  ConsumerState<UpdateAuthorityModal> createState() => _UpdateAuthorityModalState();
}

class _UpdateAuthorityModalState extends ConsumerState<UpdateAuthorityModal> {
  late TextEditingController _fullnameController;
  late TextEditingController _phoneController;
  late TextEditingController _nicknameController;
  late TextEditingController _residenceWardCodeController;
  late TextEditingController _dobController;
  LocationSelection? _originSelection;
  LocationSelection? _residenceSelection;
  Gender? _selectedGender;
  late TextEditingController _occupationController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fullnameController = TextEditingController(text: widget.profile.fullname);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber);
    _nicknameController = TextEditingController(text: widget.profile.displayNameOrName);
    _residenceWardCodeController = TextEditingController(
      text: widget.profile.residenceWardCode?.toString() ?? '',
    );
    _dobController = TextEditingController(text: widget.profile.dob ?? '');
    _selectedGender = Gender.fromString(widget.profile.gender);
    // Leave selections null; LocationSelectorField will use initialProvinceCode/initialWardCode
    _originSelection = null;
    _residenceSelection = null;
    _occupationController = TextEditingController(text: widget.profile.occupation ?? '');
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _phoneController.dispose();
    _nicknameController.dispose();
    _residenceWardCodeController.dispose();
    _dobController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final first = DateTime(1900);
    DateTime initial = DateTime.tryParse(_dobController.text) ?? DateTime(now.year - 30);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() {
        _dobController.text = _formatDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(adminUserManagementViewModelProvider.notifier);

    return AlertDialog(
      title: const Text('Update Authority'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _fullnameController,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  hintText: 'Enter full name',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Gender>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: Gender.values
                    .map((g) => DropdownMenuItem(value: g, child: Text(g.displayName)))
                    .toList(growable: false),
                onChanged: (v) => setState(() => _selectedGender = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dobController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date of birth',
                  hintText: 'YYYY-MM-DD',
                ),
                onTap: _pickDob,
              ),
              const SizedBox(height: 12),
              // Origin selector
              LocationSelectorField(
                provinceLabel: 'Origin province',
                wardLabel: 'Origin ward',
                initialProvinceCode: widget.profile.originProvinceCode,
                initialWardCode: widget.profile.originWardCode,
                onChanged: (selection) => setState(() => _originSelection = selection),
                enabled: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  hintText: 'Enter phone number',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Nickname',
                  hintText: 'Enter nickname',
                ),
              ),
              const SizedBox(height: 12),
              // Residence selector
              LocationSelectorField(
                provinceLabel: 'Residence province',
                wardLabel: 'Residence ward',
                initialProvinceCode: widget.profile.residenceProvinceCode,
                initialWardCode: widget.profile.residenceWardCode,
                onChanged: (selection) => setState(() => _residenceSelection = selection),
                enabled: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _occupationController,
                decoration: const InputDecoration(
                  labelText: 'Occupation',
                  hintText: 'Enter occupation',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            notifier.toggleUpdateAuthorityModal();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting
              ? null
              : () async {
                  final fullname = _fullnameController.text.trim();
                  final phone = _phoneController.text.trim();
                  final residenceOk = _residenceSelection?.province != null && _residenceSelection?.ward != null;

                  if (fullname.isEmpty || phone.isEmpty || !residenceOk) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in all required fields')),
                    );
                    return;
                  }

                  setState(() => _isSubmitting = true);
                  try {
                    final repo = ref.read(adminRepositoryProvider);
                    final dto = UpdateAuthorityDto(
                      fullname: fullname,
                      phoneNumber: phone,
                      nickname: _nicknameController.text.trim().isEmpty ? null : _nicknameController.text.trim(),
                      gender: _selectedGender?.toBackendString(),
                      dob: _dobController.text.isEmpty ? null : _dobController.text,
                      originProvinceCode: _originSelection?.province?.code,
                      originWardCode: _originSelection?.ward?.code,
                      residenceProvinceCode: _residenceSelection?.province?.code,
                      residenceWardCode: _residenceSelection?.ward?.code,
                      occupation: _occupationController.text.trim().isEmpty ? null : _occupationController.text.trim(),
                    );

                    final updated = await repo.updateAuthority(widget.profile.userId, dto);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Authority updated successfully')),
                      );
                      notifier.toggleUpdateAuthorityModal();
                      Navigator.of(context).pop(updated);
                    }
                  } catch (error) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${error.toString()}')),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isSubmitting = false);
                  }
                },
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Update'),
        ),
      ],
    );
  }
}
