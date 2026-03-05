import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/user_profile.dart';
import '../view_models/profile_view_model.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info.dart';
import '../widgets/profile_role.dart';
import '../widgets/profile_action_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Controllers - initialized in initState based on profile data
  late final TextEditingController _userIdController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _nicknameController;
  Gender? _selectedGender;
  late final TextEditingController _emailController;
  late final TextEditingController _jobPositionController;
  late final TextEditingController _phoneController;
  late final TextEditingController _placeOfOriginController;
  late final TextEditingController _placeOfResidenceController;
  late final TextEditingController _dateOfIssueController;
  late final TextEditingController _dateOfExpiryController;
  
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty values first
    _userIdController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _nicknameController = TextEditingController();
    _emailController = TextEditingController();
    _jobPositionController = TextEditingController();
    _phoneController = TextEditingController();
    _placeOfOriginController = TextEditingController();
    _placeOfResidenceController = TextEditingController();
    _dateOfIssueController = TextEditingController();
    _dateOfExpiryController = TextEditingController();
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _jobPositionController.dispose();
    _phoneController.dispose();
    _placeOfOriginController.dispose();
    _placeOfResidenceController.dispose();
    _dateOfIssueController.dispose();
    _dateOfExpiryController.dispose();
    super.dispose();
  }

  /// Update controllers when profile data is loaded (using domain model)
  void _updateControllersFromProfile(ProfileState profileState) {
    final profile = profileState.profile;
    if (profile == null) return;
    
    // Only update if not already initialized or if profile changed
    if (!_controllersInitialized) {
      _userIdController.text = profile.userId;
      _firstNameController.text = profile.name;
      _lastNameController.text = ''; // Backend doesn't have lastName, using name
      _nicknameController.text = profile.displayName ?? '';
      _selectedGender = profile.gender;
      _emailController.text = profile.accountState?.username ?? '';
      _jobPositionController.text = profile.jobPosition ?? '';
      _phoneController.text = profile.phoneNumber;
      _placeOfOriginController.text = profile.address?.village ?? '';
      _placeOfResidenceController.text = profile.fullAddress;
      _dateOfIssueController.text = ''; // Backend doesn't have this field
      _dateOfExpiryController.text = ''; // Backend doesn't have this field
      _controllersInitialized = true;
    }
  }

  Future<void> _toggleEdit() async {
    final viewModel = ref.read(profileViewModelProvider.notifier);
    final state = ref.read(profileViewModelProvider);
    
    if (state.isEditing) {
      // Save profile
      final success = await viewModel.updateProfile(
        displayName: _nicknameController.text,
        gender: _selectedGender?.toBackendString(),
        village: _placeOfOriginController.text,
        jobPosition: _jobPositionController.text,
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } else {
      viewModel.toggleEditMode();
    }
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Call sign out through provider
      await ref.read(profileViewModelProvider.notifier).signOut();

      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Navigate to login screen and remove all previous routes
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    
    // Update controllers when profile loads
    _updateControllersFromProfile(profileState);
    
    // Show error messages
    ref.listen<ProfileState>(profileViewModelProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(profileViewModelProvider.notifier).clearError();
      }
      if (next.successMessage != null && next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!)),
        );
        ref.read(profileViewModelProvider.notifier).clearSuccess();
      }
    });

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
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileHeader(
                    isEditing: profileState.isEditing,
                    onEditPressed: profileState.isSaving ? null : _toggleEdit,
                    onMyQRPressed: () {},
                    onAvatarTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Change avatar feature coming soon!')),
                      );
                    },
                    avatarUrl: profileState.profile?.avatarUrl,
                    displayName: profileState.profile?.effectiveDisplayName ?? 'User',
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  ProfileInfo(
                    isEditing: profileState.isEditing,
                    userIdController: _userIdController,
                    firstNameController: _firstNameController,
                    lastNameController: _lastNameController,
                    nicknameController: _nicknameController,
                    selectedGender: _selectedGender,
                    onGenderChanged: (gender) {
                      setState(() => _selectedGender = gender);
                    },
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
                  ProfileRole(
                    roles: profileState.profile?.roles ?? [],
                  ),
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
