import '../../domain/models/charity_campaign.dart';

class CampaignAnnouncementPage {
  const CampaignAnnouncementPage({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });

  final List<CampaignAnnouncement> items;
  final bool hasMore;
  final String? nextCursor;
}