import 'package:dio/dio.dart';

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
      final response = await _apiClient.get<Map<String, dynamic>>('/signal/mine/latest');
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

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }
}
