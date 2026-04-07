import 'package:flutter/material.dart';
import '../../../../../domain/models/charity_campaign.dart';
import 'components/charity_info_row.dart';
import 'components/charity_location_row.dart';
import 'components/charity_action_buttons.dart';
import 'components/charity_announcement_item.dart';
import '../../dialog/donate_dialog.dart';
import '../../dialog/post_announcement_dialog.dart';

class DetailView extends StatefulWidget {
  final CharityCampaign campaign;
  final bool isOwner;
  final VoidCallback onPurchasedSupplies;
  final VoidCallback onTransaction;
  final Future<void> Function(String text)? onPostAnnouncement;

  const DetailView({
    super.key,
    required this.campaign,
    required this.isOwner,
    required this.onPurchasedSupplies,
    required this.onTransaction,
    this.onPostAnnouncement,
  });

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  late List<CampaignAnnouncement> _announcements;

  @override
  void initState() {
    super.initState();
    _announcements = List<CampaignAnnouncement>.from(
      widget.campaign.announcements,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) {
      return 'Chưa cập nhật';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  Future<String?> _showPostAnnouncementDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (context) => const PostAnnouncementDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isActiveStatus = [
      CampaignStatus.donating,
      CampaignStatus.distributing,
      CampaignStatus.finished,
    ].contains(widget.campaign.status);

    return Column(
      key: const ValueKey('details'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CharityInfoRow(
          label: 'Organizer',
          value: widget.campaign.benefactorName,
        ),
        CharityInfoRow(
          label: 'Bank Account',
          value: widget.campaign.bankInfo.accountNumber,
        ),
        CharityInfoRow(
          label: 'Bank Name',
          value: widget.campaign.bankInfo.bankName,
        ),
        CharityLocationRow(
          location: widget.campaign.reliefLocation,
          onMapPressed: widget.campaign.status == CampaignStatus.donating
              ? null
              : () {
                  // TODO: Navigate to map
                },
        ),
        CharityInfoRow(
          label: 'Start Date',
          value: _formatDate(widget.campaign.period.startDate),
        ),
        CharityInfoRow(
          label: 'End Date',
          value: _formatDate(widget.campaign.period.endDate),
        ),
        CharityInfoRow(
          label: 'Start Donation',
          value: _formatDateTime(widget.campaign.startDonationAt),
        ),
        CharityInfoRow(
          label: 'End Donation',
          value: _formatDateTime(widget.campaign.finishDonationAt),
        ),
        CharityInfoRow(
          label: 'Start Distribution',
          value: _formatDateTime(widget.campaign.startDistributionAt),
        ),
        CharityInfoRow(
          label: 'End Distribution',
          value: _formatDateTime(widget.campaign.finishDistributionAt),
        ),
        const SizedBox(height: 24),
        if (isActiveStatus) ...[
          CharityActionButtons(
            status: widget.campaign.status,
            canDonate:
                !(widget.isOwner &&
                    widget.campaign.status == CampaignStatus.donating),
            onDonate: () => showDialog(
              context: context,
              builder: (_) => const DonateDialog(),
            ),
            onPurchasedSupplies: widget.onPurchasedSupplies,
            onTransaction: widget.onTransaction,
          ),
          const SizedBox(height: 24),
          if (widget.isOwner) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final text = await _showPostAnnouncementDialog(context);
                  if (text != null && text.isNotEmpty) {
                    final newAnnouncement = CampaignAnnouncement(
                      text: text,
                      date: DateTime.now(),
                    );

                    setState(() {
                      _announcements.insert(0, newAnnouncement);
                    });

                    await widget.onPostAnnouncement?.call(text);
                  }
                },
                icon: const Icon(Icons.post_add),
                label: const Text('Post Announcement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F62FE),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          const Text(
            'Announcements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ..._announcements.map(
            (a) => CharityAnnouncementItem(announcement: a),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}
