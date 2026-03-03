import '../models/announcement_model.dart';

/// Abstract repository for announcement operations
/// Implement this interface for mock or real data source
abstract class AnnouncementRepository {
  /// Get announcements by source
  Future<List<AnnouncementModel>> getAnnouncements({
    AnnouncementSource? source,
    int page = 1,
    int limit = 20,
  });
  
  /// Get announcement by ID
  Future<AnnouncementModel?> getAnnouncementById(String announcementId);
  
  /// Mark announcement as read
  Future<bool> markAsRead(String announcementId);
  
  /// Get unread count
  Future<int> getUnreadCount({AnnouncementSource? source});
}
