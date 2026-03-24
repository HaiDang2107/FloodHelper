import 'package:flutter/material.dart';
import '../../../domain/models/user_profile.dart';

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
  final TextEditingController jobPositionController;
  final TextEditingController phoneController;
  final TextEditingController placeOfOriginController;
  final TextEditingController placeOfResidenceController;
  final TextEditingController citizenIdController;
  final TextEditingController dateOfIssueController;
  final TextEditingController dateOfExpiryController;
  final VoidCallback? onDobTap;
  final VoidCallback? onDateOfIssueTap;
  final VoidCallback? onDateOfExpiryTap;

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
    required this.jobPositionController,
    required this.phoneController,
    required this.placeOfOriginController,
    required this.placeOfResidenceController,
    required this.citizenIdController,
    required this.dateOfIssueController,
    required this.dateOfExpiryController,
    this.onDobTap,
    this.onDateOfIssueTap,
    this.onDateOfExpiryTap,
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
          enabled: false, // User ID usually not editable
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
          controller: jobPositionController,
          label: 'Job Position',
          enabled: isEditing,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: phoneController,
          label: 'Phone Number',
          enabled: isEditing,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: placeOfOriginController,
          label: 'Place of Origin',
          enabled: isEditing,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: placeOfResidenceController,
          label: 'Place of Residence',
          enabled: isEditing,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: citizenIdController,
          label: 'Citizen ID',
          enabled: isEditing,
        ),
        const SizedBox(height: 16),
        
        // ID Card Upload Section
        Text(
          'ID Card Images',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildImageUploadBox('Front Side'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildImageUploadBox('Back Side'),
            ),
          ],
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
      ],
    );
  }

  Widget _buildGenderField() {
    if (!isEditing) {
      // Read-only display
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gender',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              selectedGender?.displayName ?? 'Not set',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: selectedGender != null ? Colors.black87 : Colors.grey[400],
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
      decoration: const InputDecoration(
        labelText: 'Gender',
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
          left: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 4,
          ),
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

  Widget _buildImageUploadBox(String label) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo, color: Colors.grey[400]),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

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
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
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
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
