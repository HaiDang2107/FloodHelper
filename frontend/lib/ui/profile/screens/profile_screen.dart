import 'package:flutter/material.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info.dart';
import '../widgets/profile_role.dart';
import '../widgets/profile_action_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  // Controllers
  // Basic Info
  final TextEditingController _userIdController = TextEditingController(text: 'USER123456');
  final TextEditingController _firstNameController = TextEditingController(text: 'Hai');
  final TextEditingController _lastNameController = TextEditingController(text: 'Dang');
  final TextEditingController _nicknameController = TextEditingController(text: 'DangDev');
  final TextEditingController _genderController = TextEditingController(text: 'Male');
  final TextEditingController _emailController = TextEditingController(text: 'haidang@example.com');
  
  // Additional Info
  final TextEditingController _jobPositionController = TextEditingController(text: 'Software Engineer');
  final TextEditingController _phoneController = TextEditingController(text: '0123456789');
  final TextEditingController _placeOfOriginController = TextEditingController(text: 'Hanoi, Vietnam');
  final TextEditingController _placeOfResidenceController = TextEditingController(text: 'Hanoi, Vietnam');
  final TextEditingController _dateOfIssueController = TextEditingController(text: '01/01/2020');
  final TextEditingController _dateOfExpiryController = TextEditingController(text: '01/01/2030');

  @override
  void dispose() {
    _userIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicknameController.dispose();
    _genderController.dispose();
    _emailController.dispose();
    _jobPositionController.dispose();
    _phoneController.dispose();
    _placeOfOriginController.dispose();
    _placeOfResidenceController.dispose();
    _dateOfIssueController.dispose();
    _dateOfExpiryController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
    if (!_isEditing) {
      // Save logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  void _handleSignOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Navigate to login screen and remove all previous routes
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(
              isEditing: _isEditing,
              onEditPressed: _toggleEdit,
              onMyQRPressed: () {},
              onAvatarTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Change avatar feature coming soon!')),
                );
              },
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            ProfileInfo(
              isEditing: _isEditing,
              userIdController: _userIdController,
              firstNameController: _firstNameController,
              lastNameController: _lastNameController,
              nicknameController: _nicknameController,
              genderController: _genderController,
              emailController: _emailController,
              jobPositionController: _jobPositionController,
              phoneController: _phoneController,
              placeOfOriginController: _placeOfOriginController,
              placeOfResidenceController: _placeOfResidenceController,
              dateOfIssueController: _dateOfIssueController,
              dateOfExpiryController: _dateOfExpiryController,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            const ProfileRole(),
            const SizedBox(height: 32),
            ProfileActionButton(
              text: 'Change Password',
              onPressed: () {},
              backgroundColor: Colors.grey[200],
              textColor: Colors.black,
            ),
            const SizedBox(height: 16),
            ProfileActionButton(
              text: 'Sign Out',
              onPressed: _handleSignOut,
              backgroundColor: Colors.red[50],
              textColor: Colors.red,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
