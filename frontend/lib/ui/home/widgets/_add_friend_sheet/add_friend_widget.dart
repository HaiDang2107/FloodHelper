import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/common/services/global_notification_controller.dart';
import '../../view_models/friend_view_model.dart';

class AddFriendWidget extends ConsumerStatefulWidget {
  const AddFriendWidget({super.key});

  @override
  ConsumerState<AddFriendWidget> createState() => _AddFriendWidgetState();
}

class _AddFriendWidgetState extends ConsumerState<AddFriendWidget> {
  bool _showEmailField = false;
  final TextEditingController _emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickQRCodeImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      ref.read(globalNotificationControllerProvider).showNotification(
        'QR Code loaded: ${image.name}',
      );
      // TODO: Process QR code image
    }
  }

  void _toggleEmailField() {
    setState(() {
      _showEmailField = !_showEmailField;
      if (!_showEmailField) {
        _emailController.clear();
      }
    });
  }

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ref.read(globalNotificationControllerProvider).showNotification(
        'Please enter an email address',
        backgroundColor: Colors.red,
      );
      return;
    }

    final viewModel = ref.read(friendViewModelProvider.notifier);
    final success = await viewModel.sendFriendRequest(email);

    if (mounted) {
      if (success) {
        _emailController.clear();
        setState(() {
          _showEmailField = false;
        });
        ref.read(globalNotificationControllerProvider).showNotification(
          'Friend request sent successfully!',
          backgroundColor: Colors.green,
        );
      } else {
        final state = ref.read(friendViewModelProvider);
        ref.read(globalNotificationControllerProvider).showNotification(
          state.errorMessage ?? 'Failed to send friend request',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(friendViewModelProvider);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Friends',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.qr_code_scanner,
                  label: 'QR Code',
                  onTap: _pickQRCodeImage,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.alternate_email,
                  label: 'Email',
                  onTap: _toggleEmailField,
                  isActive: _showEmailField,
                ),
              ),
            ],
          ),
          if (_showEmailField) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      hintText: 'Enter email address',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: state.isSending ? null : _submitEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F62FE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: state.isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Send'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0F62FE).withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? const Color(0xFF0F62FE) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isActive ? const Color(0xFF0F62FE) : Colors.grey[700],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? const Color(0xFF0F62FE) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
