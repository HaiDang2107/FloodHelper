import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final bool isEditing;
  final VoidCallback? onEditPressed;
  final VoidCallback onMyQRPressed;
  final VoidCallback? onAvatarTap;
  final String? avatarUrl;
  final String displayName;

  const ProfileHeader({
    super.key,
    required this.isEditing,
    required this.onEditPressed,
    required this.onMyQRPressed,
    this.onAvatarTap,
    this.avatarUrl,
    this.displayName = 'User',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: isEditing ? onAvatarTap : null,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                    ? NetworkImage(avatarUrl!)
                    : null,
                child: avatarUrl == null || avatarUrl!.isEmpty
                    ? Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              if (isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F62FE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: onEditPressed,
                icon: Icon(isEditing ? Icons.save : Icons.edit),
                label: Text(isEditing ? 'Save Profile' : 'Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F62FE),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onMyQRPressed,
                icon: const Icon(Icons.qr_code),
                label: const Text('MyQR'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F62FE),
                  side: const BorderSide(color: Color(0xFF0F62FE)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
