import '../../domain/models/broadcasting_signal.dart';
import '../../domain/models/distress_signal_input.dart';
import '../services/broadcasting_signals_local_storage.dart';

class LatestSignalResult {
  final bool isBroadcasting;
  final DistressSignalInput? signal;

  const LatestSignalResult({
    required this.isBroadcasting,
    required this.signal,
  });
}

/// Abstract repository for signal/sos operations
abstract class SignalRepository {
  Future<LatestSignalResult?> getMyLatestSignal();
  Future<List<BroadcastingSignal>> getRescuerBroadcastingSignals();
  
  Future<void> saveLocalSosState(String userId, DistressSignalInput data);
  Future<DistressSignalInput?> getLocalSosState(String userId);
  Future<void> clearLocalSosState(String userId);

  Future<void> saveSortCriteriaOrder({
    required String rescuerId,
    required List<BroadcastingSignalsSortCriterion> criteria,
  });
  Future<List<BroadcastingSignalsSortCriterion>> getSortCriteriaOrder(String rescuerId);
  Future<void> clearSortCriteriaOrder(String rescuerId);
}
