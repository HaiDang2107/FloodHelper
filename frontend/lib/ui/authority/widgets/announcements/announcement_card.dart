import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/authority/announcement.dart';
import '../../theme/authority_theme.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.isSelected,
    required this.onTap,
  });

  final AuthorityAnnouncement announcement;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF4FF) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AuthorityTheme.brandBlue : const Color(0xFFE1E6F4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      announcement.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101828),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM d').format(announcement.createdAt),
                    style: const TextStyle(color: Color(0xFF667085), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                announcement.caption ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF475467)),
              ),
              if (announcement.hasDocument) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.description_outlined, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        announcement.documentName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
