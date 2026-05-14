import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../routing/routes.dart';
import '../../../domain/models/user_profile.dart';
import '../../../domain/models/user.dart';
import 'package:image_picker/image_picker.dart';
import '../view_models/profile_view_model.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info.dart';
import '../widgets/role_management.dart';
import '../widgets/profile_action_button.dart';
import '../widgets/fullscreen_image_viewer.dart';
import '../../core/common/widgets/location_selector.dart';
import '../../core/common/widgets/change_password_dialog.dart';
import '../../../../data/providers/providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Controllers - initialized in initState based on profile data
  late final TextEditingController _userIdController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _nicknameController;
  Gender? _selectedGender;
  late final TextEditingController _emailController;
  late final TextEditingController _dobController;
  late final TextEditingController _occupationController;
  late final TextEditingController _phoneController;
  late final TextEditingController _citizenIdController;
  late final TextEditingController _dateOfIssueController;
  late final TextEditingController _dateOfExpiryController;

  int? _originProvinceCode;
  String? _originProvinceName;
  int? _originWardCode;
  String? _originWardName;
  int? _residenceProvinceCode;
  String? _residenceProvinceName;
  int? _residenceWardCode;
  String? _residenceWardName;

  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty values first
    _userIdController = TextEditingController();
    _fullNameController = TextEditingController();
    _nicknameController = TextEditingController();
    _emailController = TextEditingController();
    _dobController = TextEditingController();
    _occupationController = TextEditingController();
    _phoneController = TextEditingController();
    _citizenIdController = TextEditingController();
    _dateOfIssueController = TextEditingController();
    _dateOfExpiryController = TextEditingController();
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _fullNameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _occupationController.dispose();
    _phoneController.dispose();
    _citizenIdController.dispose();
    _dateOfIssueController.dispose();
    _dateOfExpiryController.dispose();
    super.dispose();
  }

  /// Update controllers when profile data is loaded (using domain model)
  void _updateControllersFromProfile(ProfileState profileState) {
    final profile = profileState.profile;
    if (profile == null) return;

    // Only avoid overwriting while the user is actively editing.
    if (!_controllersInitialized || !profileState.isEditing) {
      _userIdController.text = profile.userId;
      _fullNameController.text = profile.name;
      _nicknameController.text = profile.displayName ?? '';
      _selectedGender = profile.gender;
      _emailController.text = profile.accountState?.username ?? '';
      _dobController.text = profile.dateOfBirth != null
          ? profile.dateOfBirth!.toIso8601String().split('T')[0]
          : '';
      _occupationController.text = profile.occupation ?? '';
      _phoneController.text = profile.phoneNumber;
      _syncLocationState(profile);
      _citizenIdController.text = profile.citizenInfo?.citizenId ?? '';
      _dateOfIssueController.text = profile.citizenInfo?.dateOfIssue != null
          ? profile.citizenInfo!.dateOfIssue!.toIso8601String().split('T')[0]
          : '';
      _dateOfExpiryController.text = profile.citizenInfo?.dateOfExpire != null
          ? profile.citizenInfo!.dateOfExpire!.toIso8601String().split('T')[0]
          : '';
      _controllersInitialized = true;
    }
  }

  void _syncLocationState(UserProfile profile) {
    _originProvinceCode = profile.address?.originProvinceCode;
    _originProvinceName = profile.address?.originProvinceName;
    _originWardCode = profile.address?.originWardCode;
    _originWardName = profile.address?.originWardName;
    _residenceProvinceCode = profile.address?.residenceProvinceCode;
    _residenceProvinceName = profile.address?.residenceProvinceName;
    _residenceWardCode = profile.address?.residenceWardCode;
    _residenceWardName = profile.address?.residenceWardName;
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  DateTime? _parseControllerDate(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) {
      return null;
    }
    return DateTime.tryParse(text);
  }

  Future<void> _pickDate({
    required TextEditingController controller,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    final initialDate = _parseControllerDate(controller) ?? lastDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate)
          ? firstDate
          : (initialDate.isAfter(lastDate) ? lastDate : initialDate),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && mounted) {
      setState(() {
        controller.text = _formatDate(picked);
      });
    }
  }

  /// Returns true if the current form values differ from the saved profile.
  bool _hasProfileChanges(ProfileState state) {
    final profile = state.profile;
    if (profile == null) return false;

    final savedFullname = profile.name;
    final savedNickname = profile.displayName ?? '';
    final savedGender = profile.gender;
    final savedDob = profile.dateOfBirth != null
        ? profile.dateOfBirth!.toIso8601String().split('T')[0]
        : '';
    final savedOccupation = profile.occupation ?? '';
    final savedCitizenId = profile.citizenInfo?.citizenId ?? '';
    final savedDateOfIssue = profile.citizenInfo?.dateOfIssue != null
        ? profile.citizenInfo!.dateOfIssue!.toIso8601String().split('T')[0]
        : '';
    final savedDateOfExpire = profile.citizenInfo?.dateOfExpire != null
        ? profile.citizenInfo!.dateOfExpire!.toIso8601String().split('T')[0]
        : '';
    final savedPhone = profile.phoneNumber;

    if (_fullNameController.text != savedFullname) return true;
    if (_phoneController.text != savedPhone) return true;
    if (_nicknameController.text != savedNickname) return true;
    if (_selectedGender != savedGender) return true;
    if (_dobController.text != savedDob) return true;
    if (_occupationController.text != savedOccupation) return true;
    if (_citizenIdController.text != savedCitizenId) return true;
    if (_dateOfIssueController.text != savedDateOfIssue) return true;
    if (_dateOfExpiryController.text != savedDateOfExpire) return true;
    if (_originProvinceCode != profile.address?.originProvinceCode) return true;
    if (_residenceProvinceCode != profile.address?.residenceProvinceCode) return true;
    if (_originWardCode != profile.address?.originWardCode) return true;
    if (_residenceWardCode != profile.address?.residenceWardCode) return true;
    // Check temp images
    if (state.tempAvatarImage != null) return true;
    if (state.tempFrontCitizenIdImage != null) return true;
    if (state.tempBackCitizenIdImage != null) return true;
    if (state.tempRescuerCertificate != null) return true;
    return false;
  }

  /// Returns true if any field OTHER than the rescuer certificate has changed.
  bool _hasNonCertificateChanges(ProfileState state) {
    final profile = state.profile;
    if (profile == null) return false;

    final savedFullname = profile.name;
    final savedNickname = profile.displayName ?? '';
    final savedGender = profile.gender;
    final savedDob = profile.dateOfBirth != null
        ? profile.dateOfBirth!.toIso8601String().split('T')[0]
        : '';
    final savedOccupation = profile.occupation ?? '';
    final savedCitizenId = profile.citizenInfo?.citizenId ?? '';
    final savedDateOfIssue = profile.citizenInfo?.dateOfIssue != null
        ? profile.citizenInfo!.dateOfIssue!.toIso8601String().split('T')[0]
        : '';
    final savedDateOfExpire = profile.citizenInfo?.dateOfExpire != null
        ? profile.citizenInfo!.dateOfExpire!.toIso8601String().split('T')[0]
        : '';
    final savedPhone = profile.phoneNumber;

    if (_fullNameController.text != savedFullname) return true;
    if (_phoneController.text != savedPhone) return true;
    if (_nicknameController.text != savedNickname) return true;
    if (_selectedGender != savedGender) return true;
    if (_dobController.text != savedDob) return true;
    if (_occupationController.text != savedOccupation) return true;
    if (_citizenIdController.text != savedCitizenId) return true;
    if (_dateOfIssueController.text != savedDateOfIssue) return true;
    if (_dateOfExpiryController.text != savedDateOfExpire) return true;
    if (_originProvinceCode != profile.address?.originProvinceCode) return true;
    if (_residenceProvinceCode != profile.address?.residenceProvinceCode) return true;
    if (_originWardCode != profile.address?.originWardCode) return true;
    if (_residenceWardCode != profile.address?.residenceWardCode) return true;
    // Avatar and ID card images (not certificate)
    if (state.tempAvatarImage != null) return true;
    if (state.tempFrontCitizenIdImage != null) return true;
    if (state.tempBackCitizenIdImage != null) return true;
    return false;
  }

  Future<void> _toggleEdit() async {
    final viewModel = ref.read(profileViewModelProvider.notifier);
    final state = ref.read(profileViewModelProvider);

    if (state.isEditing) {
      // Check if user is Benefactor or Rescuer
      final roles = state.profile?.roles ?? [];
      final isBenefactor = roles.contains(UserRole.benefactor);
      final isRescuer = roles.contains(UserRole.rescuer);
      final isRestricted = isBenefactor || isRescuer;

      // A Benefactor-only user who only changed the Certificate can save directly
      final hasOnlyCertificateChange =
          isBenefactor &&
          !isRescuer &&
          state.tempRescuerCertificate != null &&
          !_hasNonCertificateChanges(state);

      if (isRestricted && _hasProfileChanges(state) && !hasOnlyCertificateChange) {
        // Build the DTO body to pass to the request
        final dto = _buildUpdateDto(state);

        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Profile Update Restricted'),
            content: const Text(
              'You cannot change your profile freely.\n\n'
              'Do you want to send a profile update request to your authority?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Send Update Request'),
              ),
            ],
          ),
        );

        if (confirmed != true || !mounted) return;

        await viewModel.createProfileUpdateRequest(
          body: dto,
          avatar: state.tempAvatarImage,
          frontCitizenId: state.tempFrontCitizenIdImage,
          backCitizenId: state.tempBackCitizenIdImage,
          rescuerCertificate: state.tempRescuerCertificate,
        );
        return;
      }

      // Normal user — save directly
      final success = await viewModel.updateProfile(
        fullname: _fullNameController.text,
        nickname: _nicknameController.text,
        gender: _selectedGender?.toBackendString(),
        dob: _dobController.text.isNotEmpty ? _dobController.text : null,
        originProvinceCode: _originProvinceCode,
        originProvinceName: _originProvinceName,
        originWardCode: _originWardCode,
        originWardName: _originWardName,
        residenceProvinceCode: _residenceProvinceCode,
        residenceProvinceName: _residenceProvinceName,
        residenceWardCode: _residenceWardCode,
        residenceWardName: _residenceWardName,
        dateOfIssue: _dateOfIssueController.text.isNotEmpty
            ? _dateOfIssueController.text
            : null,
        dateOfExpire: _dateOfExpiryController.text.isNotEmpty
            ? _dateOfExpiryController.text
            : null,
        citizenId: _citizenIdController.text,
        occupation: _occupationController.text,
        phoneNumber: _phoneController.text,
        rescuerCertificate: state.tempRescuerCertificate,
      );

      if (!success) {
        return;
      }
    } else {
      viewModel.toggleEditMode();
    }
  }

  /// Build an update DTO map from the current controller values.
  Map<String, dynamic> _buildUpdateDto(ProfileState state) {
    final map = <String, dynamic>{};
    if (_fullNameController.text.isNotEmpty) map['fullname'] = _fullNameController.text;
    if (_nicknameController.text.isNotEmpty) map['nickname'] = _nicknameController.text;
    if (_selectedGender != null) map['gender'] = _selectedGender!.toBackendString();
    if (_dobController.text.isNotEmpty) map['dob'] = _dobController.text;
    if (_occupationController.text.isNotEmpty) map['occupation'] = _occupationController.text;
    if (_phoneController.text.isNotEmpty) map['phoneNumber'] = _phoneController.text;
    if (_citizenIdController.text.isNotEmpty) map['citizenId'] = _citizenIdController.text;
    if (_dateOfIssueController.text.isNotEmpty) map['dateOfIssue'] = _dateOfIssueController.text;
    if (_dateOfExpiryController.text.isNotEmpty) map['dateOfExpire'] = _dateOfExpiryController.text;
    if (_originProvinceCode != null) map['originProvinceCode'] = _originProvinceCode;
    if (_originProvinceName != null) map['originProvinceName'] = _originProvinceName;
    if (_originWardCode != null) map['originWardCode'] = _originWardCode;
    if (_originWardName != null) map['originWardName'] = _originWardName;
    if (_residenceProvinceCode != null) map['residenceProvinceCode'] = _residenceProvinceCode;
    if (_residenceProvinceName != null) map['residenceProvinceName'] = _residenceProvinceName;
    if (_residenceWardCode != null) map['residenceWardCode'] = _residenceWardCode;
    if (_residenceWardName != null) map['residenceWardName'] = _residenceWardName;
    return map;
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
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Send final offline packet before signing out
      ref.read(locationTrackingServiceProvider).publishSignOut();

      // Call sign out through provider
      await ref.read(profileViewModelProvider.notifier).signOut();

      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Navigate to login screen and remove all previous routes
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.signIn,
        (route) => false,
      );
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

  Future<void> _showChangePasswordDialog() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);

    final result = await showChangePasswordDialog(context);
    if (result == null || !mounted) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ref.read(authRepositoryProvider).changePassword(
        oldPassword: result.oldPassword,
        newPassword: result.newPassword,
      );
      if (navigator.canPop()) {
        navigator.pop();
      }
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Password changed successfully.')),
      );
    } catch (e) {
      if (navigator.canPop()) {
        navigator.pop();
      }
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to change password: ${e.toString()}'),
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
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(profileViewModelProvider.notifier).clearError();
      }
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.successMessage!)));
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
                    onAvatarTap: () async {
                      if (profileState.isEditing) {
                        // Edit mode: pick new image
                        final picker = ImagePicker();
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          final file = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (file == null) return;
                          if (!mounted) return;

                          final vm = ref.read(
                            profileViewModelProvider.notifier,
                          );
                          vm.setTempAvatarImage(file);
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Avatar selected. Press Save Profile to upload.',
                              ),
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to pick avatar: ${e.toString()}',
                              ),
                            ),
                          );
                        }
                      } else {
                        // View mode: show fullscreen
                        if (!mounted) return;
                        showFullscreenImageViewer(
                          context: context,
                          networkUrl: profileState.profile?.avatarUrl,
                          localFilePath: null,
                          title: 'Avatar',
                        );
                      }
                    },
                    avatarUrl: profileState.profile?.avatarUrl,
                    displayName:
                        profileState.profile?.effectiveDisplayName ?? 'User',
                    tempAvatarImage: profileState.tempAvatarImage,
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  ProfileInfo(
                    isEditing: profileState.isEditing,
                    userIdController: _userIdController,
                    fullNameController: _fullNameController,
                    nicknameController: _nicknameController,
                    selectedGender: _selectedGender,
                    onGenderChanged: (gender) {
                      setState(() => _selectedGender = gender);
                    },
                    emailController: _emailController,
                    dobController: _dobController,
                    occupationController: _occupationController,
                    phoneController: _phoneController,
                    citizenIdController: _citizenIdController,
                    dateOfIssueController: _dateOfIssueController,
                    dateOfExpiryController: _dateOfExpiryController,
                    originProvinceDisplay:
                        profileState.profile?.address?.originProvinceName ?? '',
                    originWardDisplay:
                        profileState.profile?.address?.originWardName ?? '',
                    residenceProvinceDisplay:
                        profileState.profile?.address?.residenceProvinceName ??
                        '',
                    residenceWardDisplay:
                        profileState.profile?.address?.residenceWardName ?? '',
                    originProvinceCode: _originProvinceCode,
                    originWardCode: _originWardCode,
                    residenceProvinceCode: _residenceProvinceCode,
                    residenceWardCode: _residenceWardCode,
                    onOriginLocationChanged: _updateOriginLocation,
                    onResidenceLocationChanged: _updateResidenceLocation,
                    onDobTap: profileState.isEditing
                        ? () => _pickDate(
                            controller: _dobController,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          )
                        : null,
                    onDateOfIssueTap: profileState.isEditing
                        ? () => _pickDate(
                            controller: _dateOfIssueController,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          )
                        : null,
                    onDateOfExpiryTap: profileState.isEditing
                        ? () => _pickDate(
                            controller: _dateOfExpiryController,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          )
                        : null,
                    // Image picker wiring
                    currentFrontCitizenIdUrl: profileState
                        .profile
                        ?.citizenInfo
                        ?.frontCitizenIdCardImageUrl,
                    currentBackCitizenIdUrl: profileState
                        .profile
                        ?.citizenInfo
                        ?.backCitizenIdCardImageUrl,
                    tempFrontImage: profileState.tempFrontCitizenIdImage,
                    tempBackImage: profileState.tempBackCitizenIdImage,
                    onFrontImageSelected: (xfile) async {
                      final vm = ref.read(profileViewModelProvider.notifier);
                      vm.setTempFrontCitizenIdImage(xfile);
                      if (xfile != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Front ID selected. Press Save Profile to upload.',
                            ),
                          ),
                        );
                      }
                    },
                    onBackImageSelected: (xfile) async {
                      final vm = ref.read(profileViewModelProvider.notifier);
                      vm.setTempBackCitizenIdImage(xfile);
                      if (xfile != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Back ID selected. Press Save Profile to upload.',
                            ),
                          ),
                        );
                      }
                    },
                    onViewFront: () {
                      if (!profileState.isEditing) {
                        showFullscreenImageViewer(
                          context: context,
                          networkUrl: profileState
                              .profile
                              ?.citizenInfo
                              ?.frontCitizenIdCardImageUrl,
                          localFilePath: null,
                          title: 'Front ID Card',
                        );
                      }
                    },
                    onViewBack: () {
                      if (!profileState.isEditing) {
                        showFullscreenImageViewer(
                          context: context,
                          networkUrl: profileState
                              .profile
                              ?.citizenInfo
                              ?.backCitizenIdCardImageUrl,
                          localFilePath: null,
                          title: 'Back ID Card',
                        );
                      }
                    },
                    tempRescuerCertificate: profileState.tempRescuerCertificate,
                    currentRescuerCertificateUrl: profileState
                        .profile
                        ?.citizenInfo
                        ?.rescuerCertificateUrl,
                    onRescuerCertificateSelected: (file) {
                      ref
                          .read(profileViewModelProvider.notifier)
                          .setTempRescuerCertificate(file);
                      if (file != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Certificate selected. Press Save Profile to upload.',
                            ),
                          ),
                        );
                      }
                    },
                    onViewRescuerCertificate: () {
                      final url = profileState
                          .profile
                          ?.citizenInfo
                          ?.rescuerCertificateUrl;
                      if (url == null || url.trim().isEmpty) return;
                      showFullscreenImageViewer(
                        context: context,
                        networkUrl: url,
                        localFilePath: null,
                        title: 'Rescuer Certificate',
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  ProfileRole(
                    roles: profileState.profile?.roles ?? [],
                    requests: profileState.roleRequests,
                    profileUpdateRequests: profileState.profileUpdateRequests,
                    isLoadingRequests: profileState.isLoadingRoleRequests,
                    isLoadingProfileUpdateRequests:
                        profileState.isLoadingProfileUpdateRequests,
                    canSubmitRoleRequest: profileState.canSubmitRoleRequest,
                    roleRequestBlockedReason: profileState.canSubmitRoleRequest
                        ? null
                        : 'Missing fields: ${profileState.missingFieldsForRoleRequest.join(', ')}',
                    onAddRole: (role) async {
                      await ref
                          .read(profileViewModelProvider.notifier)
                          .submitRoleRequest(role);
                    },
                    onRefreshRequests: () => ref
                        .read(profileViewModelProvider.notifier)
                        .refreshRoleManagementData(),
                    onRefreshProfileUpdateRequests: () => ref
                        .read(profileViewModelProvider.notifier)
                        .refreshProfileUpdateRequests(),
                    onRevokeProfileUpdateRequest: (requestId) => ref
                        .read(profileViewModelProvider.notifier)
                        .revokeProfileUpdateRequest(requestId),
                  ),
                  const SizedBox(height: 32),
                  ProfileActionButton(
                    text: 'Sent Requests',
                    onPressed: () => showSentRequestsSheet(
                      context,
                      requests: profileState.roleRequests,
                      profileUpdateRequests: profileState.profileUpdateRequests,
                      isLoadingRequests: profileState.isLoadingRoleRequests,
                      isLoadingProfileUpdateRequests: profileState.isLoadingProfileUpdateRequests,
                      onRefreshRequests: () => ref.read(profileViewModelProvider.notifier).refreshRoleManagementData(),
                      onRefreshProfileUpdateRequests: () => ref.read(profileViewModelProvider.notifier).refreshProfileUpdateRequests(),
                      onRevokeProfileUpdateRequest: (requestId) => ref.read(profileViewModelProvider.notifier).revokeProfileUpdateRequest(requestId),
                      onRevokeRoleRequest: (requestId) => ref.read(profileViewModelProvider.notifier).revokeRoleRequest(requestId),
                    ),
                    backgroundColor: Colors.grey[200],
                    textColor: Colors.black,
                  ),
                  const SizedBox(height: 16),
                  ProfileActionButton(
                    text: 'Change Password',
                    onPressed: _showChangePasswordDialog,
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

  void _updateOriginLocation(LocationSelection selection) {
    setState(() {
      _originProvinceCode = selection.province?.code;
      _originProvinceName = selection.province?.name;
      _originWardCode = selection.ward?.code;
      _originWardName = selection.ward?.name;
    });
  }

  void _updateResidenceLocation(LocationSelection selection) {
    setState(() {
      _residenceProvinceCode = selection.province?.code;
      _residenceProvinceName = selection.province?.name;
      _residenceWardCode = selection.ward?.code;
      _residenceWardName = selection.ward?.name;
    });
  }
}
