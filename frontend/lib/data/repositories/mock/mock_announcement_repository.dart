import '../../models/announcement_model.dart';
import '../announcement_repository.dart';

/// Mock implementation of AnnouncementRepository for development/testing
class MockAnnouncementRepository implements AnnouncementRepository {
  final List<AnnouncementModel> _mockAnnouncements = [
    AnnouncementModel(
      id: '1',
      title: 'Cảnh báo mưa lớn',
      hint: 'Dự báo mưa lớn trên diện rộng tại các tỉnh miền Bắc',
      content:
          'Dự báo trong 24h tới sẽ có mưa lớn trên diện rộng tại các tỉnh miền Bắc. Người dân cần chủ động các biện pháp phòng chống.',
      source: AnnouncementSource.authority,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    AnnouncementModel(
      id: '2',
      title: 'Điểm sơ tán mới được mở',
      hint: 'UBND Quận Cầu Giấy đã mở thêm 3 điểm sơ tán',
      content:
          'UBND Quận Cầu Giấy đã mở thêm 3 điểm sơ tán tại các trường học trong địa bàn để đón người dân vùng ngập.',
      source: AnnouncementSource.authority,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
    ),
    AnnouncementModel(
      id: '3',
      title: 'Hướng dẫn sử dụng tính năng SOS',
      hint: 'Nhấn nút SOS trên màn hình chính',
      content:
          'Để phát tín hiệu SOS, bạn cần nhấn nút SOS trên màn hình chính và điền đầy đủ thông tin về tình trạng hiện tại của mình.',
      source: AnnouncementSource.app,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    AnnouncementModel(
      id: '4',
      title: 'Thời tiết hôm nay',
      hint: 'Hà Nội: Nhiệt độ 28-32°C, có mưa rào',
      content:
          'Hà Nội: Nhiệt độ 28-32°C, có mưa rào và dông vài nơi vào chiều tối. Mực nước sông Hồng: 8.5m (dưới mức báo động 1).',
      source: AnnouncementSource.daily,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      isRead: true,
    ),
    AnnouncementModel(
      id: '5',
      title: 'Lịch trực cứu hộ',
      hint: 'Đội cứu hộ quận Hoàn Kiếm trực 24/7',
      content:
          'Đội cứu hộ quận Hoàn Kiếm trực 24/7 trong đợt mưa lũ này. Hotline: 1900-xxxx.',
      source: AnnouncementSource.authority,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      isRead: false,
    ),
    AnnouncementModel(
      id: '6',
      title: 'Cập nhật ứng dụng phiên bản mới',
      hint: 'Phiên bản 2.0 đã có nhiều tính năng mới',
      content:
          'Phiên bản 2.0 đã có nhiều tính năng mới bao gồm: bản đồ ngập nước realtime, chat với đội cứu hộ, và thông báo cảnh báo tự động.',
      source: AnnouncementSource.app,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];

  @override
  Future<List<AnnouncementModel>> getAnnouncements({
    AnnouncementSource? source,
    int page = 1,
    int limit = 20,
  }) async {
    await _simulateDelay();

    var filtered = _mockAnnouncements.toList();
    if (source != null) {
      filtered = filtered.where((a) => a.source == source).toList();
    }

    // Sort by createdAt descending (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final start = (page - 1) * limit;
    final end = start + limit;
    if (start >= filtered.length) return [];
    return filtered.sublist(
      start,
      end > filtered.length ? filtered.length : end,
    );
  }

  @override
  Future<AnnouncementModel?> getAnnouncementById(String announcementId) async {
    await _simulateDelay();
    try {
      return _mockAnnouncements.firstWhere((a) => a.id == announcementId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> markAsRead(String announcementId) async {
    await _simulateDelay();
    final index = _mockAnnouncements.indexWhere((a) => a.id == announcementId);
    if (index != -1) {
      final old = _mockAnnouncements[index];
      _mockAnnouncements[index] = AnnouncementModel(
        id: old.id,
        title: old.title,
        hint: old.hint,
        content: old.content,
        source: old.source,
        createdAt: old.createdAt,
        isRead: true,
      );
      return true;
    }
    return false;
  }

  @override
  Future<int> getUnreadCount({AnnouncementSource? source}) async {
    await _simulateDelay();
    var filtered = _mockAnnouncements.toList();
    if (source != null) {
      filtered = filtered.where((a) => a.source == source).toList();
    }
    return filtered.where((a) => !a.isRead).length;
  }

  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
