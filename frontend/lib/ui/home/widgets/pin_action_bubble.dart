import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PinActionBubble extends StatelessWidget {
  final double width;
  final double height;
  final String title;
  final String userId;
  final String fullname;
  final bool canHandle;
  final VoidCallback onClose;
  final VoidCallback? onHandle;

  const PinActionBubble({
    super.key,
    this.width = 280,
    this.height = 170,
    required this.title,
    required this.userId,
    required this.fullname,
    required this.canHandle,
    required this.onClose,
    this.onHandle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/speech_bubble.svg',
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(22, 20, 18, canHandle ? 44 : 38),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'User ID: $userId',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  'Fullname: $fullname',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black),
                ),
                SizedBox(height: canHandle ? 16 : 10),
                if (canHandle)
                  ElevatedButton(
                    onPressed: onHandle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Handle'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
