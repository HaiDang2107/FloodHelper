import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../domain/models/charity_campaign.dart';
import '../../view_models/charity_campaign_requests_view_model.dart';
import '../../widgets/charity_campaign_request_card.dart';
import '../../widgets/charity_campaign_request_detail.dart';
import '../../widgets/request_review_frame.dart';

class CharityCampaignScreen extends ConsumerStatefulWidget {
  const CharityCampaignScreen({super.key, this.statusQuery});

  final String? statusQuery;

  @override
  ConsumerState<CharityCampaignScreen> createState() =>
      _CharityCampaignScreenState();
}

class _CharityCampaignScreenState extends ConsumerState<CharityCampaignScreen> {
  CampaignStatus? _statusFromQuery(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return CampaignStatus.pending;
      case 'approved':
        return CampaignStatus.approved;
      case 'rejected':
        return CampaignStatus.rejected;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(charityCampaignRequestsViewModelProvider);
    final viewModel = ref.read(charityCampaignRequestsViewModelProvider.notifier);
    final routeStatusFilter = _statusFromQuery(widget.statusQuery);
    final errorMessage = state.errorMessage;
    final hasStatusSelection = routeStatusFilter != null;

    if (errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
        viewModel.clearError();
      });
    }

    if (routeStatusFilter != state.statusFilter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        viewModel.setStatusFilter(routeStatusFilter);
      });
    }

    return AuthorityReviewFrame(
      title: 'Charity campaign requests',
      filters: const [],
      listContent: !hasStatusSelection
          ? const _StatusSelectionHint(message: 'Select a status from the sidebar to view campaign requests.')
          : state.isLoading && state.campaigns.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _CampaignRequestList(
                  campaigns: state.campaigns,
                  selectedId: state.selectedId,
                  onSelect: viewModel.selectCampaign,
                  onReachEnd: viewModel.loadMore,
                  isLoadingMore: state.isLoadingMore,
                  endMessage: state.endMessage,
                ),
      detailPanel: CharityCampaignRequestDetail(
        campaign: hasStatusSelection ? state.selectedCampaign : null,
        isSubmitting: state.isLoading,
        isDetailLoading: hasStatusSelection ? state.isDetailLoading : false,
        onApprove: (note) => viewModel.approveSelected(
          noteByAuthority: note,
        ),
        onReject: (note) => viewModel.rejectSelected(
          noteByAuthority: note,
        ),
      ),
    );
  }
}

class _CampaignRequestList extends StatelessWidget {
  const _CampaignRequestList({
    required this.campaigns,
    required this.selectedId,
    required this.onSelect,
    required this.onReachEnd,
    required this.isLoadingMore,
    this.endMessage,
  });

  final List<CharityCampaign> campaigns;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final Future<void> Function() onReachEnd;
  final bool isLoadingMore;
  final String? endMessage;

  @override
  Widget build(BuildContext context) {
    final sections = _groupByDate(campaigns);
    if (sections.isEmpty) {
      return const Center(child: Text('No requests to review yet.'));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 200) {
          onReachEnd();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: sections.length + 1,
        itemBuilder: (context, index) {
          if (index == sections.length) {
            if (isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (endMessage != null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    endMessage!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: const Color(0xFF667085)),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }

          final section = sections[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 12),
                child: Text(
                  section.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF475467),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              ...section.items.asMap().entries.map((entry) {
                final item = entry.value;
                final position = entry.key.toDouble();
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 220 + (position * 70).toInt()),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 8),
                        child: child,
                      ),
                    );
                  },
                  child: CharityCampaignRequestCard(
                    campaign: item,
                    isSelected: item.id == selectedId,
                    onTap: () => onSelect(item.id),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _CampaignSection {
  const _CampaignSection({required this.label, required this.items});

  final String label;
  final List<CharityCampaign> items;
}

class _StatusSelectionHint extends StatelessWidget {
  const _StatusSelectionHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF667085),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Chia campaign theo ngày.
List<_CampaignSection> _groupByDate(List<CharityCampaign> campaigns) {
  final formatter = DateFormat('MMM d, yyyy');
  final Map<String, List<CharityCampaign>> grouped = {};

  for (final campaign in campaigns) {
    final keyDate = _groupingDateOf(campaign);
    final key = formatter.format(keyDate);
    grouped.putIfAbsent(key, () => []).add(campaign);
  }

  final entries = grouped.entries.toList();
  entries.sort((a, b) {
    final aDate = _groupingDateOf(a.value.first);
    final bDate = _groupingDateOf(b.value.first);
    return bDate.compareTo(aDate);
  });

  return entries
      .map((entry) => _CampaignSection(label: entry.key, items: entry.value))
      .toList(growable: false);
}

DateTime _groupingDateOf(CharityCampaign campaign) {
  return campaign.requestedAt ??
    campaign.startedDonationAt ??
    campaign.startedDistributionAt ??
    campaign.finishedDonationAt ??
    campaign.finishedDistributionAt ??
    DateTime.fromMillisecondsSinceEpoch(0);
}
