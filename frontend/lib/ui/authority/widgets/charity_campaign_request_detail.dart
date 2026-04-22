import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/charity_campaign.dart';
import '../theme/authority_theme.dart';

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
  final Future<void> Function(String? noteByAuthority)? onApprove;
  final Future<void> Function(String? noteByAuthority)? onReject;
  final Future<void> Function(String? noteByAuthority)? onSuspend;
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
    _noteController.text = campaign?.noteByAuthority ?? '';
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
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Details and decision controls will appear on the right.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: const Color(0xFF667085)),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    super.key,
    required this.campaign,
    required this.noteController,
    required this.formatDateTime,
    required this.currentNote,
    required this.isSubmitting,
    required this.isDetailLoading,
    required this.onApprove,
    required this.onReject,
    required this.onSuspend,
  });

  final CharityCampaign campaign;
  final TextEditingController noteController;
  final String Function(DateTime? date) formatDateTime;
  final String? Function() currentNote;
  final bool isSubmitting;
  final bool isDetailLoading;
  final Future<void> Function(String? noteByAuthority)? onApprove;
  final Future<void> Function(String? noteByAuthority)? onReject;
  final Future<void> Function(String? noteByAuthority)? onSuspend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E6F4)),
      ),
      child: Stack(
        children: [
          ListView(
            children: [
              _buildHeader(context),
              const SizedBox(height: 18),
              _buildInfoRows(context),
              if (_showReadOnlyNote) ...[
                const SizedBox(height: 16),
                Text(
                  'Reviewer notes',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  campaign.noteByAuthority ?? '-',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: const Color(0xFF475467)),
                ),
              ],
              if (_showDecisionControls) ...[
                const SizedBox(height: 20),
                TextField(
                  controller: noteController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Decision note',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                if (_canReviewPending) _buildPendingActions(context),
                if (_canRejectApproved) _buildRejectAction(context),
                if (_canSuspendCampaign) _buildSuspendAction(context),
              ],
            ],
          ),
          if (isDetailLoading)
            const Positioned(
              top: 0,
              right: 0,
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
            ),
        ],
      ),
    );
  }

  bool get _canReviewPending => campaign.status == CampaignStatus.pending;

  bool get _canRejectApproved => campaign.status == CampaignStatus.approved;

  bool get _canSuspendCampaign =>
      campaign.status == CampaignStatus.donating ||
      campaign.status == CampaignStatus.distributing;

  bool get _showReadOnlyNote =>
      campaign.status == CampaignStatus.rejected ||
      campaign.status == CampaignStatus.finished ||
      campaign.status == CampaignStatus.suspended;

  bool get _showDecisionControls =>
      _canReviewPending || _canRejectApproved || _canSuspendCampaign;

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: AuthorityTheme.brandBlue.withValues(alpha: 0.12),
          child: Text(
            campaign.benefactorName.isNotEmpty
                ? campaign.benefactorName.substring(0, 1)
                : '?',
            style: const TextStyle(
              color: AuthorityTheme.brandBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                campaign.name,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                campaign.benefactorName,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: const Color(0xFF667085)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _StatusBadge(status: campaign.status),
      ],
    );
  }

  Widget _buildInfoRows(BuildContext context) {
    return Column(
      children: [
        _InfoRow(label: 'Purpose', value: campaign.purpose),
        _InfoRow(label: 'Charity object', value: campaign.charityObject),
        _InfoRow(label: 'Location', value: campaign.reliefLocation),
        _InfoRow(label: 'Requested at', value: formatDateTime(campaign.requestedAt)),
        _InfoRow(label: 'Responded at', value: formatDateTime(campaign.respondedAt)),
        _InfoRow(label: 'Start donation', value: formatDateTime(campaign.startedDonationAt)),
        _InfoRow(label: 'Finish donation', value: formatDateTime(campaign.finishedDonationAt)),
        _InfoRow(label: 'Start distribution', value: formatDateTime(campaign.startedDistributionAt)),
        _InfoRow(label: 'Finish distribution', value: formatDateTime(campaign.finishedDistributionAt)),
        _InfoRow(label: 'Bank account', value: campaign.bankInfo.accountNumber),
        _InfoRow(label: 'Bank name', value: campaign.bankInfo.bankName),
        _InfoRow(label: 'Bank statement', value: campaign.bankStatementFileUrl ?? '-'),
      ],
    );
  }

  Widget _buildPendingActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: const BorderSide(color: Color(0xFFE1E6F4)),
            ),
            onPressed: isSubmitting
                ? null
                : () async {
                    final note = currentNote();
                    if (note == null) {
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Decision note is required when rejecting',
                          ),
                        ),
                      );
                      return;
                    }
                    if (onReject != null) {
                      await onReject!(note);
                    }
                  },
            child: const Text('Reject request'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: isSubmitting
                ? null
                : () async {
                    if (onApprove != null) {
                      await onApprove!(currentNote());
                    }
                  },
            child: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Approve request'),
          ),
        ),
      ],
    );
  }

  Widget _buildRejectAction(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: Color(0xFFB42318)),
        ),
        onPressed: isSubmitting
            ? null
            : () async {
                final note = currentNote();
                if (note == null) {
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Decision note is required when rejecting',
                      ),
                    ),
                  );
                  return;
                }
                if (onReject != null) {
                  await onReject!(note);
                }
              },
        child: const Text('Reject campaign'),
      ),
    );
  }

  Widget _buildSuspendAction(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: Color(0xFFB42318)),
        ),
        onPressed: isSubmitting
            ? null
            : () async {
                final note = currentNote();
                if (note == null) {
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Decision note is required when suspending',
                      ),
                    ),
                  );
                  return;
                }
                if (onSuspend != null) {
                  await onSuspend!(note);
                }
              },
        child: const Text('Suspend campaign'),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final CampaignStatus status;

  Color _statusColor() {
    switch (status) {
      case CampaignStatus.pending:
        return const Color(0xFFCC7A00);
      case CampaignStatus.approved:
        return const Color(0xFF157F3B);
      case CampaignStatus.rejected:
        return const Color(0xFFB42318);
      case CampaignStatus.donating:
      case CampaignStatus.distributing:
        return const Color(0xFF0F62FE);
      case CampaignStatus.suspended:
        return const Color(0xFFB42318);
      case CampaignStatus.finished:
        return const Color(0xFF667085);
      case CampaignStatus.created:
        return const Color(0xFF667085);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: const Color(0xFF667085)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
