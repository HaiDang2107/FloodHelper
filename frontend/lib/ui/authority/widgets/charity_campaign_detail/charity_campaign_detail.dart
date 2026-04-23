import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../domain/models/charity_campaign.dart';
import '../../theme/authority_theme.dart';

part '_detail_card.dart';
part '_status_badge.dart';
part '_info_row.dart';

class CharityCampaignRequestDetail extends StatefulWidget {
  const CharityCampaignRequestDetail({
    super.key,
    required this.campaign,
    this.onApprove,
    this.onReject,
    this.onSuspend,
    this.isSubmitting = false,
    this.isDetailLoading = false,
  });

  final CharityCampaign? campaign;
  final Future<void> Function(String? noteForResponse)? onApprove;
  final Future<void> Function(String? noteForResponse)? onReject;
  final Future<void> Function(String? noteForSuspension)? onSuspend;
  final bool isSubmitting;
  final bool isDetailLoading;

  @override
  State<CharityCampaignRequestDetail> createState() =>
      _CharityCampaignRequestDetailState();
}

class _CharityCampaignRequestDetailState
    extends State<CharityCampaignRequestDetail> {
  late final TextEditingController _noteController;
  String? _lastCampaignId;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _syncNoteFromCampaign(force: true);
  }

  @override
  void didUpdateWidget(covariant CharityCampaignRequestDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncNoteFromCampaign();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _syncNoteFromCampaign({bool force = false}) {
    final campaign = widget.campaign;
    final campaignId = campaign?.id;
    if (!force && campaignId == _lastCampaignId) {
      return;
    }

    _lastCampaignId = campaignId;
    _noteController.text = campaign?.noteForResponse ?? '';
  }

  String? _currentNote() {
    final trimmed = _noteController.text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) {
      return '-';
    }
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.campaign == null) {
      return _emptyState(context);
    }

    final campaign = widget.campaign!;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _DetailCard(
        key: ValueKey(campaign.id),
        campaign: campaign,
        noteController: _noteController,
        formatDateTime: _formatDateTime,
        currentNote: _currentNote,
        isSubmitting: widget.isSubmitting,
        isDetailLoading: widget.isDetailLoading,
        onApprove: widget.onApprove,
        onReject: widget.onReject,
        onSuspend: widget.onSuspend,
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E6F4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 42,
            color: AuthorityTheme.brandBlue.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'Select a campaign request to review',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Details and decision controls will appear on the right.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF667085)),
          ),
        ],
      ),
    );
  }
}
