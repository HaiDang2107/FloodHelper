import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/authority/role_request.dart';
import '../../view_models/role_requests_view_model.dart';
import '../../widgets/request_review_frame.dart';
import '../../widgets/role_request_card.dart';
import '../../widgets/role_request_detail.dart';

class RoleRequestsScreen extends ConsumerStatefulWidget {
  const RoleRequestsScreen({
    super.key,
    this.statusQuery,
  });

  final String? statusQuery;

  @override
  ConsumerState<RoleRequestsScreen> createState() => _RoleRequestsScreenState();
}

class _RoleRequestsScreenState extends ConsumerState<RoleRequestsScreen> {
  String? _lastStatusQuery;

  RoleRequestStatus? get _activeStatus => _parseStatus(widget.statusQuery);

  @override
  void initState() {
    super.initState();
    _lastStatusQuery = widget.statusQuery;
    _syncStatusFilter();
  }

  @override
  void didUpdateWidget(covariant RoleRequestsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.statusQuery == _lastStatusQuery) {
      return;
    }

    _lastStatusQuery = widget.statusQuery;
    _syncStatusFilter();
  }

  void _syncStatusFilter() {
    final viewModel = ref.read(roleRequestsViewModelProvider.notifier);
    Future.microtask(
      () => viewModel.setStatusFilter(_parseStatus(widget.statusQuery)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roleRequestsViewModelProvider);
    final viewModel = ref.read(roleRequestsViewModelProvider.notifier);
    final hasStatusSelection = _activeStatus != null;

    return AuthorityReviewFrame(
      title: 'Role requests',
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
                onTap: () => viewModel.setRoleFilter(RoleRequestType.benefactor),
              ),
              AuthorityFilterChip(
                label: 'By rescuer',
                isActive: state.roleFilter == RoleRequestType.rescuer,
                onTap: () => viewModel.setRoleFilter(RoleRequestType.rescuer),
              ),
            ]
          : const [],
      listContent: !hasStatusSelection
          ? const _StatusSelectionHint(
              message: 'Select a status from the sidebar to view role requests.',
            )
          : state.isLoading && state.requests.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _RoleRequestList(
                  requests: state.requests,
                  selectedId: state.selectedId,
                  onSelect: viewModel.selectRequest,
                  onReachEnd: viewModel.loadMore,
                  isLoadingMore: state.isLoadingMore,
                  endMessage: state.endMessage,
                ),
      detailPanel: RoleRequestDetail(
        request: hasStatusSelection ? state.selectedRequest : null,
        isSubmitting: state.isLoading,
        onApprove: (note) => viewModel.approveSelected(note: note),
        onReject: (note) => viewModel.rejectSelected(note: note),
      ),
    );
  }
}

class _RoleRequestList extends StatelessWidget {
  const _RoleRequestList({
    required this.requests,
    required this.selectedId,
    required this.onSelect,
    required this.onReachEnd,
    required this.isLoadingMore,
    this.endMessage,
  });

  final List<RoleRequest> requests;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final Future<void> Function() onReachEnd;
  final bool isLoadingMore;
  final String? endMessage;

  @override
  Widget build(BuildContext context) {
    final sections = _groupByDate(requests);
    if (sections.isEmpty) {
      return const Center(
        child: Text('No requests to review yet.'),
      );
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
                  child: RoleRequestCard(
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

class _RoleRequestSection {
  const _RoleRequestSection({required this.label, required this.items});

  final String label;
  final List<RoleRequest> items;
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

List<_RoleRequestSection> _groupByDate(List<RoleRequest> requests) {
  final formatter = DateFormat('MMM d, yyyy');
  final Map<String, List<RoleRequest>> grouped = {};

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
      .map((entry) => _RoleRequestSection(label: entry.key, items: entry.value))
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
