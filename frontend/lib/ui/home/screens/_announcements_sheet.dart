import 'package:flutter/material.dart';
import '../widgets/_announcements_sheet/announcement_item.dart';
import '../widgets/_announcements_sheet/announcement_detail_dialog.dart';

enum AnnouncementSource { daily, authority, app }

class AnnouncementsSheet extends StatefulWidget {
  const AnnouncementsSheet({super.key});

  @override
  State<AnnouncementsSheet> createState() => _AnnouncementsSheetState();
}

class _AnnouncementsSheetState extends State<AnnouncementsSheet> {
  AnnouncementSource _selectedSource = AnnouncementSource.daily;

  // Mock data for Daily announcements
  final List<Map<String, String>> _dailyAnnouncements = [
    {'title': 'Thời tiết hôm nay', 'hint': 'Nhiệt độ 18-24°C, có mưa rải rác'},
    {'title': 'Mực nước sông Hồng', 'hint': 'Mực nước ở mức an toàn, 2.5m'},
    {'title': 'Chất lượng không khí', 'hint': 'AQI: 65 - Trung bình'},
  ];

  // Mock data for Authority announcements
  final List<Map<String, String>> _authorityAnnouncements = [
    {
      'title': 'Cảnh báo lũ lụt khu vực Hà Nội',
      'hint': 'Dự báo mưa lớn từ ngày 20-25/12. Người dân cần đề phòng...',
      'content':
          'Theo dự báo của Trung tâm Khí tượng Thủy văn Quốc gia, khu vực Hà Nội và các tỉnh lân cận sẽ có mưa lớn từ ngày 20 đến 25/12/2025. Lượng mưa dự kiến từ 150-250mm, có nơi trên 300mm. Người dân cần chủ động phòng tránh lũ quét, sạt lở đất và ngập úng cục bộ. Đề nghị các hộ dân ở vùng trũng thấp, ven sông suối di chuyển đến nơi an toàn. Các cơ quan chức năng đang theo dõi sát diễn biến thời tiết để có phương án ứng phó kịp thời.',
    },
    {
      'title': 'Thông báo sơ tán khẩn cấp - Quận Hoàn Kiếm',
      'hint': 'Yêu cầu sơ tán người dân khu vực phố Hàng Bông trong 24h...',
      'content':
          'UBND Quận Hoàn Kiếm thông báo: Do nguy cơ ngập lụt cao tại khu vực phố Hàng Bông, yêu cầu toàn bộ người dân trong khu vực sơ tán đến điểm tập kết tại Nhà văn hóa Quận trước 18h ngày 21/12/2025. Lực lượng chức năng sẽ hỗ trợ di chuyển tài sản và người già, trẻ em. Mọi thông tin chi tiết liên hệ hotline: 024.xxxx.xxxx',
    },
    {
      'title': 'Cập nhật tình hình thời tiết',
      'hint': 'Bão số 12 đang tiến vào Biển Đông, ảnh hưởng miền Bắc...',
      'content':
          'Bão số 12 đang di chuyển với tốc độ 20km/h theo hướng Tây Tây Bắc, dự kiến sẽ ảnh hưởng trực tiếp đến các tỉnh miền Bắc từ ngày 22/12. Sức gió mạnh cấp 10-11, giật cấp 13. Các địa phương cần chủ động triển khai phương án ứng phó, đảm bảo an toàn cho người dân.',
    },
  ];

  // Mock data for App announcements
  final List<Map<String, String>> _appAnnouncements = [
    {
      'title': 'Cập nhật phiên bản 2.1.0',
      'hint': 'Thêm tính năng chia sẻ vị trí real-time với bạn bè',
    },
    {
      'title': 'Bảo trì hệ thống',
      'hint': 'Hệ thống sẽ bảo trì từ 2h-4h sáng ngày 20/12',
    },
    {
      'title': 'Tính năng mới: Cảnh báo thông minh',
      'hint': 'AI dự đoán nguy cơ lũ lụt dựa trên vị trí của bạn',
    },
    {
      'title': 'Chính sách bảo mật cập nhật',
      'hint': 'Chúng tôi đã cập nhật chính sách bảo mật dữ liệu người dùng',
    },
  ];

  void _showAnnouncementDetail(String title, String content) {
    showDialog(
      context: context,
      builder: (context) =>
          AnnouncementDetailDialog(title: title, content: content),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<AnnouncementSource>(
                segments: const [
                  ButtonSegment(
                    value: AnnouncementSource.daily,
                    label: Text('Daily'),
                  ),
                  ButtonSegment(
                    value: AnnouncementSource.authority,
                    label: Text('Authority'),
                  ),
                  ButtonSegment(
                    value: AnnouncementSource.app,
                    label: Text('App'),
                  ),
                ],
                selected: {_selectedSource},
                onSelectionChanged: (Set<AnnouncementSource> newSelection) {
                  setState(() {
                    _selectedSource = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return const Color(0xFF0F62FE);
                    }
                    return Colors.white;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith<Color>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return Colors.black87;
                  }),
                ),
              ),
            ),

            const SizedBox(height: 20),
            _buildAnnouncementList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementList() {
    final announcements = _selectedSource == AnnouncementSource.daily
        ? _dailyAnnouncements
        : (_selectedSource == AnnouncementSource.authority
              ? _authorityAnnouncements
              : _appAnnouncements);

    if (announcements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No announcements',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Column(
      children: announcements.map((announcement) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: AnnouncementItem(
            title: announcement['title']!,
            hint: announcement['hint']!,
            onTap:
                _selectedSource != AnnouncementSource.daily &&
                    announcement.containsKey('content')
                ? () => _showAnnouncementDetail(
                    announcement['title']!,
                    announcement['content']!,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
