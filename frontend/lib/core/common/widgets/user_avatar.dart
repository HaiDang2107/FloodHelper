import 'package:flutter/material.dart';
import '../constants/user_state.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final UserStatus status;
  final double size;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final IconData? topRightIcon;
  final VoidCallback? onTopRightIconTap;
  final Color? topRightIconColor;
  final Color? topRightIconBackgroundColor;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.status,
    this.size = 60.0,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.topRightIcon,
    this.onTopRightIconTap,
    this.topRightIconColor,
    this.topRightIconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            // Avatar container
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
                image: imageUrl != null && imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null || imageUrl!.isEmpty
                  ? Icon(
                      Icons.person,
                      size: size * 0.6,
                      color: Colors.grey[600],
                    )
                  : null,
            ),
            // Status indicator
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.25,
                height: size * 0.25,
                decoration: BoxDecoration(
                  color: status.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: size * 0.04,
                  ),
                ),
              ),
            ),
            // Top right icon button (optional)
            if (topRightIcon != null)
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: onTopRightIconTap,
                  child: Container(
                    width: size * 0.3,
                    height: size * 0.3,
                    decoration: BoxDecoration(
                      color: topRightIconBackgroundColor ?? const Color(0xFF0F62FE),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: size * 0.04,
                      ),
                    ),
                    child: Icon(
                      topRightIcon,
                      size: size * 0.18,
                      color: topRightIconColor ?? Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
