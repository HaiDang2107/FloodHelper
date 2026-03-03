import 'package:flutter/material.dart';
import 'package:antiflood/data/models/user_model.dart';
import 'package:antiflood/ui/core/common/widgets/user_avatar.dart';
import 'package:antiflood/ui/core/common/constants/user_state.dart';

class FriendSearchItem extends StatelessWidget {
  final UserModel user;
  final VoidCallback onLocateTap;

  const FriendSearchItem({
    super.key,
    required this.user,
    required this.onLocateTap,
  });

  UserStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return UserStatus.online;
      case 'offline':
        return UserStatus.offline;
      default:
        return UserStatus.unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          UserAvatar(
            imageUrl: user.avatarUrl,
            status: _parseStatus(user.status),
            size: 48,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.name,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onLocateTap,
            icon: const Icon(
              Icons.search,
              color: Color(0xFF0F62FE),
              size: 24,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
