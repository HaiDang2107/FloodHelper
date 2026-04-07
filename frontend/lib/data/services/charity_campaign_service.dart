import 'package:dio/dio.dart';

import '../../domain/models/charity_campaign.dart';
import 'api_client.dart';

class CharityCampaignService {
  final ApiClient _apiClient;

  CharityCampaignService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<Map<String, dynamic>>> getExistingCampaignsByState(
    CampaignStatus state,
  ) async {
    try {
      final response = await _apiClient.get(
        '/charity/campaigns/existing',
        queryParameters: {'state': state.name.toUpperCase()},
      );

      return _extractList(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getMyCampaignsByState(
    CampaignStatus state,
  ) async {
    try {
      final response = await _apiClient.get(
        '/charity/campaigns/mine',
        queryParameters: {'state': state.name.toUpperCase()},
      );

      return _extractList(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getCampaignDetail(String campaignId) async {
    try {
      final response = await _apiClient.get('/charity/campaigns/$campaignId');
      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw ApiException(message: 'Invalid campaign detail response');
      }

      if (data['success'] == true && data['data'] is Map) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }

      throw ApiException(
        message:
            data['message']?.toString() ??
            'Failed to load charity campaign detail',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  List<Map<String, dynamic>> _extractList(dynamic responseData) {
    if (responseData is! Map<String, dynamic>) {
      return [];
    }

    final success = responseData['success'] == true;
    final payload = responseData['data'];
    if (!success || payload is! List) {
      throw ApiException(
        message:
            responseData['message']?.toString() ??
            'Failed to load charity campaigns',
      );
    }

    return payload
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
}
