import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/authority/role_request.dart';
import '../../theme/authority_theme.dart';
import '../../view_models/role_requests_view_model.dart';
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

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Role requests',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AuthorityTheme.textDark,
                    ),
              ),
              const Spacer(),
              _FilterChip(
                label: 'All',
                isActive: state.roleFilter == null,
                onTap: () => viewModel.setRoleFilter(null),
              ),
              _FilterChip(
                label: 'By benefactor',
                isActive: state.roleFilter == RoleRequestType.benefactor,
                onTap: () => viewModel.setRoleFilter(RoleRequestType.benefactor),
              ),
              _FilterChip(
                label: 'By rescuer',
                isActive: state.roleFilter == RoleRequestType.rescuer,
                onTap: () => viewModel.setRoleFilter(RoleRequestType.rescuer),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 1100;
                final listPanel = Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE1E6F4)),
                  ),
                  child: state.isLoading && state.requests.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : _RoleRequestList(
                          requests: state.requests,
                          selectedId: state.selectedId,
                          onSelect: viewModel.selectRequest,
                          onReachEnd: viewModel.loadMore,
                          isLoadingMore: state.isLoadingMore,
                          endMessage: state.endMessage,
                        ),
                );

                if (isNarrow) {
                  return Column(
                    children: [
                      Expanded(child: listPanel),
                      const SizedBox(height: 16),
                      Expanded(
                        child: RoleRequestDetail(
                          request: state.selectedRequest,
                          isSubmitting: state.isLoading,
                          onApprove: (note) => viewModel.approveSelected(note: note),
                          onReject: (note) => viewModel.rejectSelected(note: note),
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(flex: 3, child: listPanel),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 5,
                      child: RoleRequestDetail(
                        request: state.selectedRequest,
                        isSubmitting: state.isLoading,
                        onApprove: (note) => viewModel.approveSelected(note: note),
                        onReject: (note) => viewModel.rejectSelected(note: note),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isActive,
        onSelected: (_) => onTap(),
        selectedColor: AuthorityTheme.brandBlue,
        labelStyle: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF344054),
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE1E6F4)),
        ),
      ),
    );
  }
}

class _RoleRequestSection {
  const _RoleRequestSection({required this.label, required this.items});

  final String label;
  final List<RoleRequest> items;
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
