import 'package:flutter/material.dart';
import '../../../models/charity_campaign.dart';
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

  const DetailView({
    super.key,
    required this.campaign,
    required this.isOwner,
    required this.onPurchasedSupplies,
    required this.onTransaction,
  });

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
      CampaignStatus.finished
    ].contains(widget.campaign.status);

    return Column(
      key: const ValueKey('details'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CharityInfoRow(
            label: 'Organizer', value: widget.campaign.benefactorName),
        CharityInfoRow(
            label: 'Bank Account', value: widget.campaign.bankAccountNumber),
        CharityInfoRow(label: 'Bank Name', value: widget.campaign.bankName),
        CharityLocationRow(
          location: widget.campaign.reliefLocation,
          onMapPressed: () {
            // TODO: Navigate to map
          },
        ),
        CharityInfoRow(
            label: 'Start Date', value: _formatDate(widget.campaign.startDate)),
        CharityInfoRow(
            label: 'End Date', value: _formatDate(widget.campaign.endDate)),
        const SizedBox(height: 24),
        if (isActiveStatus) ...[
          CharityActionButtons(
            status: widget.campaign.status,
            onDonate: () => showDialog(
                context: context, builder: (_) => const DonateDialog()),
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
                    setState(() {
                      widget.campaign.announcements.insert(
                          0,
                          CampaignAnnouncement(
                            text: text,
                            date: DateTime.now(),
                          ));
                    });
                  }
                },
                icon: const Icon(Icons.post_add),
                label: const Text('Post Announcement'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F62FE),
                    foregroundColor: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
          ],
          const Text('Announcements',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 16),
          ...widget.campaign.announcements
              .map((a) => CharityAnnouncementItem(announcement: a)),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}
