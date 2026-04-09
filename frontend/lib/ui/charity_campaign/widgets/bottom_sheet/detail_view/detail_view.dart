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
  final Future<void> Function()? onUpdateInformation;
  final Future<void> Function()? onSendRequest;

  const DetailView({
    super.key,
    required this.campaign,
    required this.isOwner,
    required this.onPurchasedSupplies,
    required this.onTransaction,
    this.onPostAnnouncement,
    this.onUpdateInformation,
    this.onSendRequest,
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
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _formatDateOrPlaceholder(DateTime? date) {
    if (date == null) {
      return 'Chưa cập nhật';
    }
    return _formatDate(date);
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
    final bool canShowMapIcon = [
      CampaignStatus.pending,
      CampaignStatus.distributing,
      CampaignStatus.finished,
    ].contains(widget.campaign.status);
    final bool showAuthorityNote = [
      CampaignStatus.approved,
      CampaignStatus.rejected,
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
          label: 'Bank Name',
          value: widget.campaign.bankInfo.bankName,
        ),
        CharityInfoRow(
          label: 'Bank Account',
          value: widget.campaign.bankInfo.accountNumber,
        ),
        if (widget.isOwner)
          CharityInfoRow(label: 'Purpose', value: widget.campaign.purpose),
        if (widget.isOwner)
          CharityInfoRow(
            label: 'Charity Object',
            value: widget.campaign.charityObject,
          ),
        CharityLocationRow(
          location: widget.campaign.reliefLocation,
          onMapPressed: canShowMapIcon
              ? () {
                  // TODO: Navigate to map
                }
              : null,
        ),
        CharityInfoRow(
          label: 'Start Donation',
          value: _formatDateOrPlaceholder(widget.campaign.startedDonationAt),
        ),
        CharityInfoRow(
          label: 'End Donation',
          value: _formatDateOrPlaceholder(widget.campaign.finishedDonationAt),
        ),
        CharityInfoRow(
          label: 'Start Distribution',
          value: _formatDateOrPlaceholder(widget.campaign.startedDistributionAt),
        ),
        CharityInfoRow(
          label: 'End Distribution',
          value: _formatDateOrPlaceholder(widget.campaign.finishedDistributionAt),
        ),
        if (showAuthorityNote)
          CharityInfoRow(
            label: 'Note by Authority',
            value: widget.campaign.noteByAuthority ?? 'Không có ghi chú',
          ),
        if (widget.isOwner && widget.campaign.status == CampaignStatus.created)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onUpdateInformation,
                  icon: const Icon(Icons.edit),
                  label: const Text('Update Campaign'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F62FE),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onSendRequest,
                  icon: const Icon(Icons.send),
                  label: const Text('Send Request'),
                ),
              ),
            ],
          ),
        if (widget.isOwner && widget.campaign.status == CampaignStatus.created)
          const SizedBox(height: 24),
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
