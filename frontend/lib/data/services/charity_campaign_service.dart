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

  Future<Map<String, dynamic>> createCampaign(Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.post('/charity/campaigns', data: payload);
      return _extractMap(response.data, fallbackMessage: 'Failed to create campaign');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateCampaign(
    String campaignId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _apiClient.put(
        '/charity/campaigns/$campaignId',
        data: payload,
      );
      return _extractMap(response.data, fallbackMessage: 'Failed to update campaign');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> sendCampaignRequest(String campaignId) async {
    try {
      final response = await _apiClient.post(
        '/charity/campaigns/$campaignId/send-request',
      );
      return _extractMap(
        response.data,
        fallbackMessage: 'Failed to send campaign request',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> createDonateQr({
    required String campaignId,
    required BigInt amount,
  }) async {
    try {
      final response = await _apiClient.post(
        '/charity/campaigns/$campaignId/donate/qr',
        data: {'amount': amount.toString()},
      );
      return _extractMap(
        response.data,
        fallbackMessage: 'Failed to create VietQR',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Map<String, dynamic> _extractMap(
    dynamic responseData, {
    required String fallbackMessage,
  }) {
    if (responseData is! Map<String, dynamic>) {
      throw ApiException(message: fallbackMessage);
    }

    if (responseData['success'] == true && responseData['data'] is Map) {
      return Map<String, dynamic>.from(responseData['data'] as Map);
    }

    throw ApiException(
      message: responseData['message']?.toString() ?? fallbackMessage,
    );
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
