import 'package:flutter/material.dart';
import '../../../../../../domain/models/charity_campaign.dart';

class CharityAnnouncementItem extends StatelessWidget {
  final CampaignAnnouncement announcement;

  const CharityAnnouncementItem({super.key, required this.announcement});

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                _formatDate(announcement.date),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            announcement.text,
            style: const TextStyle(color: Colors.black87),
          ),
          if (announcement.imageUrl != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                announcement.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
