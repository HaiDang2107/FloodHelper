import '../../../domain/models/broadcasting_signal.dart';
import '../../../domain/models/distress_signal_input.dart';
import '../../services/broadcasting_signals_local_storage.dart';
import '../../services/signal_service.dart';
import '../../services/sos_local_storage.dart';
import '../signal_repository.dart';

class RealSignalRepository implements SignalRepository {
  final SignalService _signalService;
  final SosLocalStorage _sosLocalStorage;
  final BroadcastingSignalsLocalStorage _broadcastingSignalsLocalStorage;

  RealSignalRepository({
    required SignalService signalService,
    required SosLocalStorage sosLocalStorage,
    required BroadcastingSignalsLocalStorage broadcastingSignalsLocalStorage,
  })  : _signalService = signalService,
        _sosLocalStorage = sosLocalStorage,
        _broadcastingSignalsLocalStorage = broadcastingSignalsLocalStorage;

  @override
  Future<LatestSignalResult?> getMyLatestSignal() async {
    final signal = await _signalService.getMyLatestSignal();
    if (signal == null) {
      return const LatestSignalResult(isBroadcasting: false, signal: null);
    }

    final state = (signal['state'] ?? '').toString().toUpperCase();
    if (state != 'BROADCASTING') {
      return const LatestSignalResult(isBroadcasting: false, signal: null);
    }

    return LatestSignalResult(
      isBroadcasting: true,
      signal: DistressSignalInput(
        trappedCounts: _asInt(signal['trappedCount']),
        childrenNumbers: _asInt(signal['childrenNum']),
        elderlyNumbers: _asInt(signal['elderlyNum']),
        hasFood: signal['hasFood'] == true,
        hasWater: signal['hasWater'] == true,
        other: (signal['note'] ?? '').toString().isEmpty
            ? null
            : signal['note'].toString(),
      ),
    );
  }

  @override
  Future<List<BroadcastingSignal>> getRescuerBroadcastingSignals() async {
    final rawList = await _signalService.getRescuerBroadcastingSignals();
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(_toBroadcastingSignal)
        .toList(growable: false);
  }

  @override
  Future<void> saveLocalSosState(String userId, DistressSignalInput data) {
    return _sosLocalStorage.saveBroadcastingState(userId, data);
  }

  @override
  Future<DistressSignalInput?> getLocalSosState(String userId) {
    return _sosLocalStorage.getBroadcastingState(userId);
  }

  @override
  Future<void> clearLocalSosState(String userId) {
    return _sosLocalStorage.clearBroadcastingState(userId);
  }

  @override
  Future<void> saveSortCriteriaOrder({
    required String rescuerId,
    required List<BroadcastingSignalsSortCriterion> criteria,
  }) {
    return _broadcastingSignalsLocalStorage.saveSortCriteriaOrder(
      rescuerId: rescuerId,
      criteria: criteria,
    );
  }

  @override
  Future<List<BroadcastingSignalsSortCriterion>> getSortCriteriaOrder(String rescuerId) {
    return _broadcastingSignalsLocalStorage.getSortCriteriaOrder(rescuerId);
  }

  @override
  Future<void> clearSortCriteriaOrder(String rescuerId) {
    return _broadcastingSignalsLocalStorage.clearSortCriteriaOrder(rescuerId);
  }

  BroadcastingSignal _toBroadcastingSignal(Map<String, dynamic> raw) {
    final user = raw['user'];
    final userJson = user is Map<String, dynamic> ? user : const <String, dynamic>{};

    // profiles is a list: [{ fullname, phoneNumber, avatarUrl }]
    final profiles = userJson['profiles'];
    final profile = (profiles is List && profiles.isNotEmpty)
        ? profiles.first as Map<String, dynamic>
        : const <String, dynamic>{};

    final createdAtRaw = raw['createdAt'];
    final createdAt = DateTime.tryParse(createdAtRaw?.toString() ?? '')?.toLocal();

    return BroadcastingSignal(
      signalId: (raw['signalId'] ?? '').toString(),
      createdBy: (raw['createdBy'] ?? '').toString(),
      createdAt: createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      trappedCount: _asInt(raw['trappedCount']),
      childrenNum: _asInt(raw['childrenNum']),
      elderlyNum: _asInt(raw['elderlyNum']),
      hasFood: raw['hasFood'] == true,
      hasWater: raw['hasWater'] == true,
      note: (raw['note'] ?? '').toString().trim().isEmpty
          ? null
          : raw['note'].toString().trim(),
      userFullname: (profile['fullname'] ?? '').toString().trim(),
      userPhoneNumber: (profile['phoneNumber'] ?? '').toString().trim().isEmpty
          ? null
          : profile['phoneNumber'].toString().trim(),
    );
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }
}
