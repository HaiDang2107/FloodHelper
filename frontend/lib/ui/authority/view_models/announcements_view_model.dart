import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/authority/announcement.dart';
import '../../../data/providers/authority_providers.dart';

class AuthorityAnnouncementsState {
  const AuthorityAnnouncementsState({
    this.allAnnouncements = const [],
    this.announcements = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isPublishing = false,
    this.isDeleting = false,
    this.selectedId,
    this.nextCursor,
    this.hasMore = true,
    this.endMessage,
    this.errorMessage,
    this.publishProgress = 0,
  });

  final List<AuthorityAnnouncement> allAnnouncements;
  final List<AuthorityAnnouncement> announcements;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isPublishing;
  final bool isDeleting;
  final String? selectedId;
  final String? nextCursor;
  final bool hasMore;
  final String? endMessage;
  final String? errorMessage;
  final double publishProgress;

  AuthorityAnnouncementsState copyWith({
    List<AuthorityAnnouncement>? allAnnouncements,
    List<AuthorityAnnouncement>? announcements,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isPublishing,
    bool? isDeleting,
    String? selectedId,
    bool clearSelectedId = false,
    String? nextCursor,
    bool? hasMore,
    String? endMessage,
    bool clearEndMessage = false,
    String? errorMessage,
    bool clearError = false,
    double? publishProgress,
  }) {
    return AuthorityAnnouncementsState(
      allAnnouncements: allAnnouncements ?? this.allAnnouncements,
      announcements: announcements ?? this.announcements,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isPublishing: isPublishing ?? this.isPublishing,
      isDeleting: isDeleting ?? this.isDeleting,
      selectedId: clearSelectedId ? null : (selectedId ?? this.selectedId),
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      endMessage: clearEndMessage ? null : (endMessage ?? this.endMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      publishProgress: publishProgress ?? this.publishProgress,
    );
  }

  AuthorityAnnouncement? get selectedAnnouncement {
    if (selectedId == null || announcements.isEmpty) {
      return null;
    }

    return announcements.firstWhere(
      (announcement) => announcement.id == selectedId,
      orElse: () => announcements.first,
    );
  }
}

final authorityAnnouncementsViewModelProvider =
    StateNotifierProvider<AuthorityAnnouncementsViewModel, AuthorityAnnouncementsState>(
  (ref) => AuthorityAnnouncementsViewModel(ref),
);

class AuthorityAnnouncementsViewModel
    extends StateNotifier<AuthorityAnnouncementsState> {
  AuthorityAnnouncementsViewModel(this.ref)
      : super(const AuthorityAnnouncementsState());

  final Ref ref;

  Future<void> load({bool force = false}) async {
    if (state.isLoading || state.isLoadingMore) {
      return;
    }

    if (!force && state.allAnnouncements.isNotEmpty) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearEndMessage: true,
      clearError: true,
    );

    try {
      final repository = ref.read(authorityRepositoryProvider);
      final page = await repository.fetchAuthorityAnnouncements(limit: 10);

      state = state.copyWith(
        allAnnouncements: page.items,
        announcements: page.items,
        isLoading: false,
        selectedId: page.items.isNotEmpty ? page.items.first.id : null,
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
        endMessage: page.items.isEmpty ? 'No announcements yet.' : null,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load announcements: $error',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, clearEndMessage: true);
    try {
      final repository = ref.read(authorityRepositoryProvider);
      final page = await repository.fetchAuthorityAnnouncements(
        beforeCreatedAt: state.nextCursor,
        limit: 10,
      );

      final merged = [...state.allAnnouncements, ...page.items];
      state = state.copyWith(
        allAnnouncements: merged,
        announcements: merged,
        isLoadingMore: false,
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
        endMessage: page.hasMore ? null : 'No more announcements.',
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Failed to load more announcements: $error',
      );
    }
  }

  Future<void> selectAnnouncement(String announcementId) async {
    state = state.copyWith(selectedId: announcementId, clearError: true);
    await _hydrateDetail(announcementId);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<AuthorityAnnouncement> publishAnnouncement({
    required String title,
    required String caption,
    Uint8List? bytes,
    String? fileName,
    String? mimeType,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    state = state.copyWith(
      isPublishing: true,
      publishProgress: 0,
      clearError: true,
    );

    try {
      final repository = ref.read(authorityRepositoryProvider);
      final created = await repository.publishAuthorityAnnouncement(
        title: title,
        caption: caption,
        bytes: bytes,
        fileName: fileName,
        mimeType: mimeType,
        onSendProgress: (sent, total) {
          if (total <= 0) {
            state = state.copyWith(publishProgress: 0);
            onSendProgress?.call(sent, total);
            return;
          }
          state = state.copyWith(publishProgress: sent / total);
          onSendProgress?.call(sent, total);
        },
      );

      final merged = [created, ...state.allAnnouncements]
          .where((item) => item.id.isNotEmpty)
          .fold<List<AuthorityAnnouncement>>([], (acc, item) {
        if (acc.any((existing) => existing.id == item.id)) {
          return acc
              .map((existing) => existing.id == item.id ? item : existing)
              .toList(growable: false);
        }
        return [item, ...acc];
      });

      state = state.copyWith(
        allAnnouncements: merged,
        announcements: merged,
        selectedId: created.id,
        isPublishing: false,
        publishProgress: 1,
      );
      return created;
    } catch (error) {
      state = state.copyWith(
        isPublishing: false,
        errorMessage: 'Failed to publish announcement: $error',
      );
      rethrow;
    }
  }

  Future<AuthorityAnnouncement> deleteSelectedAnnouncement() async {
    final selected = state.selectedAnnouncement;
    if (selected == null) {
      throw StateError('No announcement selected');
    }

    state = state.copyWith(isDeleting: true, clearError: true);
    try {
      final repository = ref.read(authorityRepositoryProvider);
      final deleted = await repository.deleteAuthorityAnnouncement(selected.id);

      final remaining = state.allAnnouncements
          .where((item) => item.id != selected.id)
          .toList(growable: false);
      state = state.copyWith(
        allAnnouncements: remaining,
        announcements: remaining,
        selectedId: remaining.isNotEmpty ? remaining.first.id : null,
        isDeleting: false,
        endMessage: remaining.isEmpty ? 'No announcements yet.' : null,
      );
      return deleted;
    } catch (error) {
      state = state.copyWith(
        isDeleting: false,
        errorMessage: 'Failed to delete announcement: $error',
      );
      rethrow;
    }
  }

  Future<void> _hydrateDetail(String announcementId) async {
    try {
      final repository = ref.read(authorityRepositoryProvider);
      final detail = await repository.fetchAuthorityAnnouncementDetail(
        announcementId,
      );
      _replaceAnnouncement(announcementId, detail);
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'Failed to load announcement detail: $error',
      );
    }
  }

  void _replaceAnnouncement(String announcementId, AuthorityAnnouncement updated) {
    final nextAll = state.allAnnouncements
        .map((announcement) => announcement.id == announcementId ? updated : announcement)
        .toList(growable: false);
    state = state.copyWith(
      allAnnouncements: nextAll,
      announcements: nextAll,
      selectedId: updated.id,
    );
  }
}