import 'package:flutter/material.dart';
import 'package:antiflood/ui/core/common/models/friend_model.dart';
import 'package:antiflood/ui/core/common/widgets/user_avatar.dart';

class FriendSearchItem extends StatelessWidget {
  final FriendModel friend;
  final VoidCallback onLocateTap;

  const FriendSearchItem({
    super.key,
    required this.friend,
    required this.onLocateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          UserAvatar(
            imageUrl: friend.avatarUrl,
            status: friend.status,
            size: 48,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              friend.name,
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
