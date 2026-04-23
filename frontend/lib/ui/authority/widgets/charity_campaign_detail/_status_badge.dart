part of 'charity_campaign_detail.dart';

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
