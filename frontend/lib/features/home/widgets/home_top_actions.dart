import 'package:flutter/material.dart';
import '../screens/_settings_sheet.dart';
import '../screens/_add_friend_sheet.dart';
import '../screens/_announcements_sheet.dart';

class HomeTopActions extends StatelessWidget {
  final Function(String, Widget) onShowBottomSheet;
  final VoidCallback onProfilePressed;

  const HomeTopActions({
    super.key,
    required this.onShowBottomSheet,
    required this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMapIcon(Icons.settings, () => onShowBottomSheet('Settings', const SettingsSheet())),
        const SizedBox(height: 8),
        _buildMapIcon(Icons.account_circle, onProfilePressed),
        const SizedBox(height: 8),
        _buildMapIcon(Icons.person_add, () => onShowBottomSheet('Add Friend', const AddFriendSheet())),
        const SizedBox(height: 8),
        _buildMapIcon(Icons.campaign, () => onShowBottomSheet('Announcements', const AnnouncementsSheet())),
      ],
    );
  }

  Widget _buildMapIcon(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF0F62FE)),
        onPressed: onPressed,
      ),
    );
  }
}
