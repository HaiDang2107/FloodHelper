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
  final TextEditingController _firstNameController = TextEditingController(text: 'Hai');
  final TextEditingController _lastNameController = TextEditingController(text: 'Dang');
  final TextEditingController _emailController = TextEditingController(text: 'haidang@example.com');
  final TextEditingController _phoneController = TextEditingController(text: '0123456789');
  final TextEditingController _addressController = TextEditingController(text: 'Hanoi, Vietnam');

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
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
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
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
              firstNameController: _firstNameController,
              lastNameController: _lastNameController,
              emailController: _emailController,
              phoneController: _phoneController,
              addressController: _addressController,
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
