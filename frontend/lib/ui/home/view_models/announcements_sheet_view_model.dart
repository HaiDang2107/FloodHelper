import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/announcement_model.dart';
import '../../../data/providers/repository_providers.dart';

class AnnouncementsSheetState {
  const AnnouncementsSheetState({
    this.selectedSource = AnnouncementSource.daily,
    this.items = const <AnnouncementModel>[],
    this.isLoading = false,
    this.errorMessage,
  });

  final AnnouncementSource selectedSource;
  final List<AnnouncementModel> items;
  final bool isLoading;
  final String? errorMessage;

  AnnouncementsSheetState copyWith({
    AnnouncementSource? selectedSource,
    List<AnnouncementModel>? items,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AnnouncementsSheetState(
      selectedSource: selectedSource ?? this.selectedSource,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final announcementsSheetViewModelProvider = StateNotifierProvider.autoDispose<
  AnnouncementsSheetViewModel,
  AnnouncementsSheetState
>((ref) {
  return AnnouncementsSheetViewModel(ref);
});

class AnnouncementsSheetViewModel extends StateNotifier<AnnouncementsSheetState> {
  AnnouncementsSheetViewModel(this._ref)
      : super(const AnnouncementsSheetState()) {
    _loadForSource(state.selectedSource);
  }

  final Ref _ref;

  Future<void> selectSource(AnnouncementSource source) async {
    if (state.selectedSource == source && state.items.isNotEmpty) {
      return;
    }

    state = state.copyWith(selectedSource: source);
    await _loadForSource(source);
  }

  Future<void> _loadForSource(AnnouncementSource source) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repository = _ref.read(announcementRepositoryProvider);
      final items = await repository.getAnnouncements(source: source, limit: 20);
      state = state.copyWith(items: items, isLoading: false, clearError: true);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load announcements: $error',
      );
    }
  }
}
