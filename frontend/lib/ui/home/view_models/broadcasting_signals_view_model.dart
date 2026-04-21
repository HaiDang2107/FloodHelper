import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/providers/providers.dart';
import '../../../data/services/broadcasting_signals_local_storage.dart';
import '../../../data/services/signal_service.dart';
import '../../../domain/models/broadcasting_signal.dart';

part 'broadcasting_signals_view_model.g.dart';

class BroadcastingSignalsState {
  final bool isLoading;
  final List<BroadcastingSignal> signals;
  final String? errorMessage;
  final List<BroadcastingSignalsSortCriterion> sortCriteria;

  const BroadcastingSignalsState({
    this.isLoading = false,
    this.signals = const [],
    this.errorMessage,
    this.sortCriteria = BroadcastingSignalsLocalStorage.defaultSortCriteria,
  });

  BroadcastingSignalsState copyWith({
    bool? isLoading,
    List<BroadcastingSignal>? signals,
    String? errorMessage,
    List<BroadcastingSignalsSortCriterion>? sortCriteria,
    bool clearError = false,
  }) {
    return BroadcastingSignalsState(
      isLoading: isLoading ?? this.isLoading,
      signals: signals ?? this.signals,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      sortCriteria: sortCriteria ?? this.sortCriteria,
    );
  }
}

@riverpod
class BroadcastingSignalsViewModel
    extends _$BroadcastingSignalsViewModel {
  late final SignalService _signalService = ref.read(signalServiceProvider);

  @override
  BroadcastingSignalsState build() {
    return const BroadcastingSignalsState();
  }

  Future<void> initialize() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || !currentUser.isRescuer) {
      return;
    }

    final sortCriteria =
        await BroadcastingSignalsLocalStorage.getSortCriteriaOrder(
          currentUser.id,
        );
    state = state.copyWith(sortCriteria: sortCriteria);
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final fetched = await _signalService.getRescuerBroadcastingSignals();
      state = state.copyWith(
        isLoading: false,
        signals: _sortSignals(fetched, state.sortCriteria),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load broadcasting signals: $e',
      );
    }
  }

  Future<void> applySortCriteria( // call sort
    List<BroadcastingSignalsSortCriterion> criteria,
  ) async {
    if (criteria.isEmpty) {
      return;
    }

    final normalized = <BroadcastingSignalsSortCriterion>[];
    for (final criterion in criteria) {
      if (!normalized.contains(criterion)) {
        normalized.add(criterion);
      }
    }

    state = state.copyWith(
      sortCriteria: normalized,
      signals: _sortSignals(state.signals, normalized),
    );

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      return;
    }

    await BroadcastingSignalsLocalStorage.saveSortCriteriaOrder(
      rescuerId: currentUser.id,
      criteria: normalized,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  List<BroadcastingSignal> _sortSignals(
    List<BroadcastingSignal> input,
    List<BroadcastingSignalsSortCriterion> criteria,
  ) {
    final sorted = input.toList(growable: false);

    sorted.sort((a, b) {
      // Với mỗi signal, phải chạy 1 vòng lặp
      for (final criterion in criteria) {
        final compare = _compareByCriterion(a, b, criterion);
        if (compare != 0) {
          return compare;
        }
      }
      // Final tie-breaker: earlier created signal first.
      return a.createdAt.compareTo(b.createdAt);
    });

    return sorted;
  }

  int _compareByCriterion(
    BroadcastingSignal a,
    BroadcastingSignal b,
    BroadcastingSignalsSortCriterion criterion,
  ) {
    switch (criterion) {
      case BroadcastingSignalsSortCriterion.trappedCounts:
        return b.trappedCount.compareTo(a.trappedCount);
      case BroadcastingSignalsSortCriterion.childrenNumbers:
        return b.childrenNum.compareTo(a.childrenNum);
      case BroadcastingSignalsSortCriterion.elderlyNumbers:
        return b.elderlyNum.compareTo(a.elderlyNum);
      case BroadcastingSignalsSortCriterion.hasFood:
        return _compareBoolTrueFirst(a.hasFood, b.hasFood);
      case BroadcastingSignalsSortCriterion.hasWater:
        return _compareBoolTrueFirst(a.hasWater, b.hasWater);
    }
  }

  int _compareBoolTrueFirst(bool a, bool b) { // hàm trả về số âm nếu phần tử thứ nhất đứng trước hơn phần tử thứ hai
    if (a == b) {
      return 0;
    }
    return a ? 1 : -1;
  }
}
