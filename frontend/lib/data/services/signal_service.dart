import 'package:dio/dio.dart';

import '../../domain/models/broadcasting_signal.dart';
import '../../domain/models/distress_signal_input.dart';
import 'api_client.dart';

class LatestSignalResult {
  final bool isBroadcasting;
  final DistressSignalInput? signal;

  const LatestSignalResult({
    required this.isBroadcasting,
    required this.signal,
  });
}

/// Service for distress signal APIs used by Home flow.
class SignalService {
  final ApiClient _apiClient;

  SignalService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<LatestSignalResult?> getMyLatestSignal() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/signal/mine/latest',
      );
      final body = response.data;
      if (body == null || body['success'] != true) {
        return null;
      }

      final signal = body['data'];
      if (signal is! Map<String, dynamic>) {
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
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<BroadcastingSignal>> getRescuerBroadcastingSignals() async { // Lấy danh sách Broadcasting signal
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/signal/rescuer/broadcasting',
      );
      final body = response.data;
      if (body == null || body['success'] != true) {
        return const [];
      }

      final data = body['data'];
      if (data is! List) {
        return const [];
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(_toBroadcastingSignal)
          .toList(growable: false);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  BroadcastingSignal _toBroadcastingSignal(Map<String, dynamic> raw) { // chuyển từ raw sang BroadcastingSignal
    final user = raw['user'];
    final userJson = user is Map<String, dynamic>
        ? user
        : const <String, dynamic>{};

    final createdAtRaw = raw['createdAt'];
    final createdAt = DateTime.tryParse(createdAtRaw?.toString() ?? '');

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
      userFullname: (userJson['fullname'] ?? '').toString().trim(),
      userPhoneNumber: (userJson['phoneNumber'] ?? '').toString().trim().isEmpty
          ? null
          : userJson['phoneNumber'].toString().trim(),
    );
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }
}
