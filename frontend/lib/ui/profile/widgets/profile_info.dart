import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget {
  final bool isEditing;
  // Basic Info
  final TextEditingController userIdController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController nicknameController;
  final TextEditingController genderController;
  final TextEditingController emailController;
  
  // Additional Info
  final TextEditingController jobPositionController;
  final TextEditingController phoneController;
  final TextEditingController placeOfOriginController;
  final TextEditingController placeOfResidenceController;
  final TextEditingController dateOfIssueController;
  final TextEditingController dateOfExpiryController;

  const ProfileInfo({
    super.key,
    required this.isEditing,
    required this.userIdController,
    required this.firstNameController,
    required this.lastNameController,
    required this.nicknameController,
    required this.genderController,
    required this.emailController,
    required this.jobPositionController,
    required this.phoneController,
    required this.placeOfOriginController,
    required this.placeOfResidenceController,
    required this.dateOfIssueController,
    required this.dateOfExpiryController,
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
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: firstNameController,
                label: 'First Name',
                enabled: isEditing,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: lastNameController,
                label: 'Last Name',
                enabled: isEditing,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: nicknameController,
          label: 'Nickname',
          enabled: isEditing,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: genderController,
          label: 'Gender',
          enabled: isEditing,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: emailController,
          label: 'Email',
          enabled: isEditing,
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
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: dateOfExpiryController,
                label: 'Date of Expiry',
                enabled: isEditing,
              ),
            ),
          ],
        ),
      ],
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
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
    );
  }
}
