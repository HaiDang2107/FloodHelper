import 'package:dio/dio.dart';
import 'api_client.dart';

/// Service for distress signal APIs used by Home flow.
class SignalService {
  final ApiClient _apiClient;

  SignalService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Fetches the raw JSON representation of the latest signal of the current user.
  Future<Map<String, dynamic>?> getMyLatestSignal() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/signal/mine/latest',
      );
      final body = response.data;
      if (body == null || body['success'] != true) {
        return null;
      }
      return body['data'] as Map<String, dynamic>?;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Fetches the raw list of active broadcasting signals.
  Future<List<dynamic>> getRescuerBroadcastingSignals() async {
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
      return data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
