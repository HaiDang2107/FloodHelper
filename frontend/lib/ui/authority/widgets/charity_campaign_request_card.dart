import 'package:flutter/material.dart';

import '../../../domain/models/charity_campaign.dart';
import '../theme/authority_theme.dart';

class CharityCampaignRequestCard extends StatelessWidget {
  const CharityCampaignRequestCard({
    super.key,
    required this.campaign,
    required this.isSelected,
    required this.onTap,
  });

  final CharityCampaign campaign;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEAF0FF) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AuthorityTheme.brandBlue
                  : const Color(0xFFE1E6F4),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AuthorityTheme.brandBlue.withValues(alpha: 0.12),
                child: Text(
                  campaign.benefactorName.isNotEmpty
                      ? campaign.benefactorName.substring(0, 1)
                      : '?',
                  style: const TextStyle(color: AuthorityTheme.brandBlue),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor(campaign.status).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  campaign.status.name.toUpperCase(),
                  style: TextStyle(
                    color: _statusColor(campaign.status),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(CampaignStatus status) {
    switch (status) {
      case CampaignStatus.pending:
        return const Color(0xFFCC7A00);
      case CampaignStatus.approved:
        return const Color(0xFF157F3B);
      case CampaignStatus.rejected:
        return const Color(0xFFB42318);
      case CampaignStatus.suspended:
        return const Color(0xFFB42318);
      case CampaignStatus.donating:
      case CampaignStatus.distributing:
        return const Color(0xFF0F62FE);
      case CampaignStatus.finished:
      case CampaignStatus.created:
        return const Color(0xFF667085);
    }
  }
}
