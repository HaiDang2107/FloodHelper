import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/authority/profile_update_request.dart';
import '../../../../data/models/authority/role_request.dart';
import '../../view_models/profile_update_requests_view_model.dart';
import '../../widgets/review_frame.dart';
import '../../widgets/updating_profile_requests/profile_update_request_card.dart';
import '../../widgets/updating_profile_requests/profile_update_request_detail.dart';

class UpdatingProfileRequestsScreen extends ConsumerStatefulWidget {
  const UpdatingProfileRequestsScreen({
    super.key,
    this.statusQuery,
  });

  final String? statusQuery;

  @override
  ConsumerState<UpdatingProfileRequestsScreen> createState() =>
      _UpdatingProfileRequestsScreenState();
}

class _UpdatingProfileRequestsScreenState
    extends ConsumerState<UpdatingProfileRequestsScreen> {
  String? _lastStatusQuery;

  RoleRequestStatus? get _activeStatus => _parseStatus(widget.statusQuery);

  @override
  void initState() {
    super.initState();
    _lastStatusQuery = widget.statusQuery;
    _syncStatusFilter();
  }

  @override
  void didUpdateWidget(covariant UpdatingProfileRequestsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.statusQuery == _lastStatusQuery) {
      return;
    }

    _lastStatusQuery = widget.statusQuery;
    _syncStatusFilter();
  }

  void _syncStatusFilter() {
    final viewModel = ref.read(profileUpdateRequestsViewModelProvider.notifier);
    Future.microtask(
      () => viewModel.setStatusFilter(_parseStatus(widget.statusQuery)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileUpdateRequestsViewModelProvider);
    final viewModel = ref.read(profileUpdateRequestsViewModelProvider.notifier);
    final hasStatusSelection = _activeStatus != null;

    final errorMessage = state.errorMessage;
    if (errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
        viewModel.clearError();
      });
    }

    return AuthorityReviewFrame(
      title: 'Updating profile requests',
      filters: hasStatusSelection
          ? [
              AuthorityFilterChip(
                label: 'All',
                isActive: state.roleFilter == null,
                onTap: () => viewModel.setRoleFilter(null),
              ),
              AuthorityFilterChip(
                label: 'By benefactor',
                isActive: state.roleFilter == RoleRequestType.benefactor,
                onTap:
                    () => viewModel.setRoleFilter(RoleRequestType.benefactor),
              ),
              AuthorityFilterChip(
                label: 'By rescuer',
                isActive: state.roleFilter == RoleRequestType.rescuer,
                onTap: () => viewModel.setRoleFilter(RoleRequestType.rescuer),
              ),
            ]
          : const [],
      listContent:
          !hasStatusSelection
              ? const _StatusSelectionHint(
                message:
                    'Select a status from the sidebar to view profile updates.',
              )
              : state.isLoading && state.requests.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _ProfileUpdateRequestList(
                requests: state.requests,
                selectedId: state.selectedId,
                onSelect: viewModel.selectRequest,
                onReachEnd: viewModel.loadMore,
                isLoadingMore: state.isLoadingMore,
                endMessage: state.endMessage,
              ),
      detailPanel: ProfileUpdateRequestDetail(
        request: hasStatusSelection ? state.selectedRequest : null,
        isSubmitting: state.isLoading,
        onApprove: (note) => viewModel.approveSelected(note: note),
        onReject: (note) => viewModel.rejectSelected(note: note),
      ),
    );
  }
}

class _ProfileUpdateRequestList extends StatelessWidget {
  const _ProfileUpdateRequestList({
    required this.requests,
    required this.selectedId,
    required this.onSelect,
    required this.onReachEnd,
    required this.isLoadingMore,
    this.endMessage,
  });

  final List<AuthorityProfileUpdateRequest> requests;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final Future<void> Function() onReachEnd;
  final bool isLoadingMore;
  final String? endMessage;

  @override
  Widget build(BuildContext context) {
    final sections = _groupByDate(requests);
    if (sections.isEmpty) {
      return const Center(child: Text('No updates to review yet.'));
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF667085),
                    ),
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
                  duration: Duration(
                    milliseconds: 220 + (position * 70).toInt(),
                  ),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 8),
                        child: child,
                      ),
                    );
                  },
                  child: ProfileUpdateRequestCard(
                    request: item,
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

class _ProfileUpdateRequestSection {
  const _ProfileUpdateRequestSection({required this.label, required this.items});

  final String label;
  final List<AuthorityProfileUpdateRequest> items;
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

List<_ProfileUpdateRequestSection> _groupByDate(
  List<AuthorityProfileUpdateRequest> requests,
) {
  final formatter = DateFormat('MMM d, yyyy');
  final Map<String, List<AuthorityProfileUpdateRequest>> grouped = {};

  for (final request in requests) {
    final key = formatter.format(request.submittedAt);
    grouped.putIfAbsent(key, () => []).add(request);
  }

  final entries = grouped.entries.toList();
  entries.sort((a, b) {
    final aDate = a.value.first.submittedAt;
    final bDate = b.value.first.submittedAt;
    return bDate.compareTo(aDate);
  });

  return entries
      .map(
        (entry) =>
            _ProfileUpdateRequestSection(label: entry.key, items: entry.value),
      )
      .toList();
}

RoleRequestStatus? _parseStatus(String? raw) {
  switch (raw) {
    case 'pending':
      return RoleRequestStatus.pending;
    case 'approved':
      return RoleRequestStatus.approved;
    case 'rejected':
      return RoleRequestStatus.rejected;
    default:
      return null;
  }
}
