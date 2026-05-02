import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/authority/announcement.dart';
import '../../view_models/announcements_view_model.dart';
import 'announcement_card.dart';

class PublishedAnnouncementsList extends StatelessWidget {
  const PublishedAnnouncementsList({
    super.key,
    required this.state,
    required this.onSelect,
    required this.onLoadMore,
  });

  final AuthorityAnnouncementsState state;
  final ValueChanged<String> onSelect;
  final Future<void> Function() onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.announcements.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final sections = _groupByDate(state.announcements);
    if (sections.isEmpty) {
      return Center(
        child: Text(
          state.endMessage ?? 'No announcements yet.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF667085),
              ),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 200) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: sections.length + 1,
        itemBuilder: (context, index) {
          if (index == sections.length) {
            if (state.isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (state.endMessage != null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    state.endMessage!,
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
                final position = entry.key;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 220 + (position * 70)),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 8),
                        child: child,
                      ),
                    );
                  },
                  child: AnnouncementCard(
                    announcement: item,
                    isSelected: item.id == state.selectedId,
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

class _AnnouncementSection {
  const _AnnouncementSection({required this.label, required this.items});

  final String label;
  final List<AuthorityAnnouncement> items;
}

List<_AnnouncementSection> _groupByDate(List<AuthorityAnnouncement> items) {
  final formatter = DateFormat('MMM d, yyyy');
  final Map<String, List<AuthorityAnnouncement>> grouped = {};

  for (final item in items) {
    final key = formatter.format(item.createdAt);
    grouped.putIfAbsent(key, () => []).add(item);
  }

  final entries = grouped.entries.toList();
  entries.sort((a, b) => b.value.first.createdAt.compareTo(a.value.first.createdAt));

  return entries
      .map((entry) => _AnnouncementSection(label: entry.key, items: entry.value))
      .toList(growable: false);
}
