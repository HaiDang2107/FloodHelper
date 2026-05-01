import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/models/announcement_model.dart';
import '../../view_models/announcements_sheet_view_model.dart';
import '../../widgets/_announcements_sheet/announcement_item.dart';
import '../../widgets/_announcements_sheet/announcement_detail_dialog.dart';

class AnnouncementsSheet extends ConsumerWidget {
  const AnnouncementsSheet({super.key});

  void _showAnnouncementDetail(
    BuildContext context,
    AnnouncementModel announcement,
  ) {
    final fileName = _extractFileName(announcement.documentUrl);

    showDialog(
      context: context,
      builder: (dialogContext) => AnnouncementDetailDialog(
        title: announcement.title,
        content: announcement.content ?? announcement.hint,
        documentFileName: fileName,
        onOpenDocument: announcement.documentUrl == null
            ? null
            : () => _openDocument(dialogContext, announcement.documentUrl!),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(announcementsSheetViewModelProvider);
    final viewModel = ref.read(announcementsSheetViewModelProvider.notifier);

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
                selected: {state.selectedSource},
                onSelectionChanged: (Set<AnnouncementSource> newSelection) {
                  viewModel.selectSource(newSelection.first);
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
            _buildAnnouncementList(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementList(BuildContext context, AnnouncementsSheetState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            state.errorMessage!,
            style: TextStyle(fontSize: 14, color: Colors.red[700]),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final announcements = state.items;

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
            title: announcement.title,
            hint: announcement.hint,
            onTap: () => _showAnnouncementDetail(context, announcement),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _openDocument(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid document URL.')),
      );
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open document.')),
      );
    }
  }

  String? _extractFileName(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(url);
    if (uri == null || uri.pathSegments.isEmpty) {
      return null;
    }

    return Uri.decodeComponent(uri.pathSegments.last);
  }
}
