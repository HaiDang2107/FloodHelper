part of 'charity_campaign_detail.dart';

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
  final Future<void> Function(String? noteForResponse)? onApprove;
  final Future<void> Function(String? noteForResponse)? onReject;
  final Future<void> Function(String? noteForSuspension)? onSuspend;

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
                  _showSuspensionDetails
                      ? 'Suspension notes'
                      : 'Reviewer notes',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  _showSuspensionDetails
                      ? (campaign.noteForSuspension ?? '-')
                      : (campaign.noteForResponse ?? '-'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF475467),
                  ),
                ),
                if (_showSuspensionDetails) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Suspended at',
                    value: formatDateTime(campaign.suspendedAt),
                  ),
                ],
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

  bool get _showSuspensionDetails => campaign.status == CampaignStatus.suspended;

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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                campaign.benefactorName,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF667085)),
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
        _InfoRow(
          label: 'Requested at',
          value: formatDateTime(campaign.requestedAt),
        ),
        _InfoRow(
          label: 'Responded at',
          value: formatDateTime(campaign.respondedAt),
        ),
        _InfoRow(
          label: 'Start donation',
          value: formatDateTime(campaign.startedDonationAt),
        ),
        _InfoRow(
          label: 'Finish donation',
          value: formatDateTime(campaign.finishedDonationAt),
        ),
        _InfoRow(
          label: 'Start distribution',
          value: formatDateTime(campaign.startedDistributionAt),
        ),
        _InfoRow(
          label: 'Finish distribution',
          value: formatDateTime(campaign.finishedDistributionAt),
        ),
        _InfoRow(label: 'Bank account', value: campaign.bankInfo.accountNumber),
        _InfoRow(label: 'Bank name', value: campaign.bankInfo.bankName),
        _InfoRow(
          label: 'Bank statement',
          value: campaign.bankStatementFileUrl ?? '-',
        ),
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
                      content: Text('Decision note is required when rejecting'),
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
