import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/models/user_profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/common/widgets/location_selector.dart';
import 'citizen_id_card_picker.dart';

class ProfileInfo extends StatelessWidget {
  final bool isEditing;
  // Basic Info
  final TextEditingController userIdController;
  final TextEditingController fullNameController;
  final TextEditingController nicknameController;
  final Gender? selectedGender;
  final ValueChanged<Gender?>? onGenderChanged;
  final TextEditingController emailController;
  final TextEditingController dobController;

  // Additional Info
  final TextEditingController occupationController;
  final TextEditingController phoneController;
  final TextEditingController citizenIdController;
  final TextEditingController dateOfIssueController;
  final TextEditingController dateOfExpiryController;

  final String originProvinceDisplay;
  final String originWardDisplay;
  final String residenceProvinceDisplay;
  final String residenceWardDisplay;

  final int? originProvinceCode;
  final int? originWardCode;
  final int? residenceProvinceCode;
  final int? residenceWardCode;

  final ValueChanged<LocationSelection>? onOriginLocationChanged;
  final ValueChanged<LocationSelection>? onResidenceLocationChanged;
  final VoidCallback? onDobTap;
  final VoidCallback? onDateOfIssueTap;
  final VoidCallback? onDateOfExpiryTap;
  // ID Card image support
  final String? currentFrontCitizenIdUrl;
  final String? currentBackCitizenIdUrl;
  final XFile? tempFrontImage;
  final XFile? tempBackImage;
  final ValueChanged<XFile?>? onFrontImageSelected;
  final ValueChanged<XFile?>? onBackImageSelected;
  final XFile? tempRescuerCertificate;
  final ValueChanged<XFile?>? onRescuerCertificateSelected;
  final VoidCallback? onViewRescuerCertificate;
  final String? currentRescuerCertificateUrl;
  final VoidCallback? onViewFront;
  final VoidCallback? onViewBack;

  const ProfileInfo({
    super.key,
    required this.isEditing,
    required this.userIdController,
    required this.fullNameController,
    required this.nicknameController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.emailController,
    required this.dobController,
    required this.occupationController,
    required this.phoneController,
    required this.citizenIdController,
    required this.dateOfIssueController,
    required this.dateOfExpiryController,
    required this.originProvinceDisplay,
    required this.originWardDisplay,
    required this.residenceProvinceDisplay,
    required this.residenceWardDisplay,
    required this.originProvinceCode,
    required this.originWardCode,
    required this.residenceProvinceCode,
    required this.residenceWardCode,
    required this.onOriginLocationChanged,
    required this.onResidenceLocationChanged,
    this.onDobTap,
    this.onDateOfIssueTap,
    this.onDateOfExpiryTap,
    this.currentFrontCitizenIdUrl,
    this.currentBackCitizenIdUrl,
    this.tempFrontImage,
    this.tempBackImage,
    this.onFrontImageSelected,
    this.onBackImageSelected,
    this.onViewFront,
    this.onViewBack,
    this.tempRescuerCertificate,
    this.onRescuerCertificateSelected,
    this.onViewRescuerCertificate,
    this.currentRescuerCertificateUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic Personal Information
        _buildSectionHeader(context, 'Basic Personal Information'),
        const SizedBox(height: 16),
        _buildTextField(
          controller: userIdController,
          label: 'User ID',
          enabled: false,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: fullNameController,
          label: 'Full Name',
          enabled: isEditing,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: nicknameController,
          label: 'Nickname',
          enabled: isEditing,
        ),
        const SizedBox(height: 16),
        _buildGenderField(),
        const SizedBox(height: 16),
        _buildTextField(
          controller: emailController,
          label: 'Email',
          enabled: false,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: dobController,
          label: 'Date of Birth',
          enabled: isEditing,
          readOnly: isEditing,
          onTap: onDobTap,
          suffixIcon: isEditing
              ? const Icon(Icons.calendar_today, size: 18)
              : null,
        ),

        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 24),

        // Additional Personal Information
        _buildSectionHeader(context, 'Additional Personal Information'),
        const SizedBox(height: 16),
        _buildTextField(
          controller: occupationController,
          label: 'Occupation',
          enabled: isEditing,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: phoneController,
          label: 'Phone Number',
          enabled: isEditing,
        ),
        const SizedBox(height: 16),
        _buildLocationField(
          title: 'Place of Origin',
          provinceDisplay: originProvinceDisplay,
          wardDisplay: originWardDisplay,
          provinceCode: originProvinceCode,
          wardCode: originWardCode,
          onChanged: onOriginLocationChanged,
        ),
        const SizedBox(height: 16),
        _buildLocationField(
          title: 'Place of Residence',
          provinceDisplay: residenceProvinceDisplay,
          wardDisplay: residenceWardDisplay,
          provinceCode: residenceProvinceCode,
          wardCode: residenceWardCode,
          onChanged: onResidenceLocationChanged,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: citizenIdController,
          label: 'Citizen ID',
          enabled: isEditing,
        ),
        const SizedBox(height: 16),

        CitizenIdCardPicker(
          currentFrontUrl: currentFrontCitizenIdUrl,
          currentBackUrl: currentBackCitizenIdUrl,
          selectedFrontImage: tempFrontImage,
          selectedBackImage: tempBackImage,
          onFrontImageSelected: onFrontImageSelected,
          onBackImageSelected: onBackImageSelected,
          onViewFront: onViewFront,
          onViewBack: onViewBack,
          isEditing: isEditing,
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: dateOfIssueController,
                label: 'Date of Issue',
                enabled: isEditing,
                readOnly: isEditing,
                onTap: onDateOfIssueTap,
                suffixIcon: isEditing
                    ? const Icon(Icons.calendar_today, size: 18)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: dateOfExpiryController,
                label: 'Date of Expiry',
                enabled: isEditing,
                readOnly: isEditing,
                onTap: onDateOfExpiryTap,
                suffixIcon: isEditing
                    ? const Icon(Icons.calendar_today, size: 18)
                    : null,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        _buildCertificatePicker(context),
      ],
    );
  }

  Widget _buildGenderField() {
    if (!isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gender',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              selectedGender?.displayName ?? 'Not set',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: selectedGender != null
                    ? Colors.black87
                    : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 4),
            Divider(color: Colors.grey[200]),
          ],
        ),
      );
    }

    // Editable dropdown
    return DropdownButtonFormField<Gender>(
      initialValue: selectedGender,
      dropdownColor: Colors.white,
      style: const TextStyle(color: Colors.black),
      decoration: const InputDecoration(
        labelText: 'Gender',
        labelStyle: TextStyle(color: Colors.grey),
        floatingLabelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      items: Gender.values.map((gender) {
        return DropdownMenuItem<Gender>(
          value: gender,
          child: Text(gender.displayName),
        );
      }).toList(),
      onChanged: onGenderChanged,
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: Theme.of(context).primaryColor, width: 4),
        ),
      ),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // Widget _buildImageUploadBox(String label) {
  //   return Container(
  //     height: 100,
  //     decoration: BoxDecoration(
  //       border: Border.all(color: Colors.grey[300]!),
  //       borderRadius: BorderRadius.circular(8),
  //       color: Colors.grey[50],
  //     ),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(Icons.add_a_photo, color: Colors.grey[400]),
  //         const SizedBox(height: 4),
  //         Text(
  //           label,
  //           style: TextStyle(
  //             fontSize: 12,
  //             color: Colors.grey[600],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool enabled,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    if (!enabled) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              controller.text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Divider(color: Colors.grey[200]),
          ],
        ),
      );
    }

    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: Colors.black),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        floatingLabelStyle: const TextStyle(color: Colors.black),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildLocationField({
    required String title,
    required String provinceDisplay,
    required String wardDisplay,
    required int? provinceCode,
    required int? wardCode,
    required ValueChanged<LocationSelection>? onChanged,
  }) {
    if (!isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            _buildLocationLine(label: 'Province', value: provinceDisplay),
            const SizedBox(height: 4),
            _buildLocationLine(label: 'Ward', value: wardDisplay),
            const SizedBox(height: 4),
            Divider(color: Colors.grey[200]),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 8),
          LocationSelectorField(
            provinceLabel: 'Province',
            wardLabel: 'Ward',
            initialProvinceCode: provinceCode,
            initialWardCode: wardCode,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationLine({required String label, required String value}) {
    return Text(
      '$label: ${value.isEmpty ? '-' : value}',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCertificatePicker(BuildContext context) {
    final hasPendingFile = tempRescuerCertificate != null;
    final hasSavedUrl = (currentRescuerCertificateUrl ?? '').trim().isNotEmpty;

    // File name to display
    final pendingFileName = hasPendingFile ? tempRescuerCertificate!.name : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Certificate for Rescuer',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),

        // Pending file name (selected but not yet saved)
        if (hasPendingFile) ...
          [
            Row(
              children: [
                const Icon(Icons.insert_drive_file, size: 18, color: Colors.blue),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    pendingFileName!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '(pending upload)',
                  style: TextStyle(fontSize: 11, color: Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

        // Saved URL — clickable link
        if (!hasPendingFile && hasSavedUrl) ...
          [
            InkWell(
              onTap: () async {
                final uri = Uri.tryParse(currentRescuerCertificateUrl!);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, size: 18, color: Colors.red),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _extractFileName(currentRescuerCertificateUrl!),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

        // Upload button
        if (isEditing)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickCertificate(context),
                  icon: const Icon(Icons.upload_file),
                  label: Text(
                    hasPendingFile || hasSavedUrl
                        ? 'Replace certificate'
                        : 'Upload certificate',
                  ),
                ),
              ),
            ],
          )
        else if (!hasPendingFile && !hasSavedUrl)
          const Text(
            'No certificate uploaded.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
      ],
    );
  }

  /// Extract a human-readable file name from a URL.
  String _extractFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final segment = uri.pathSegments.lastWhere(
        (s) => s.isNotEmpty,
        orElse: () => url,
      );
      return Uri.decodeComponent(segment);
    } catch (_) {
      return url;
    }
  }

  Future<void> _pickCertificate(BuildContext context) async {
    if (!isEditing) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );

    final file = result?.files.single;
    if (file == null || file.path == null) {
      return;
    }

    final picked = XFile(file.path!);
    onRescuerCertificateSelected?.call(picked);
  }
}
