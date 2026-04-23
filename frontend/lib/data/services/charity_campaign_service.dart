import 'package:dio/dio.dart';

import '../../domain/models/bank_option.dart';
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

  Future<List<BankOption>> getBanks() async {
    try {
      final response = await _apiClient.get('/charity/banks');
      final banks = _extractList(response.data);

      return banks
          .map((item) => Map<String, dynamic>.from(item))
          .map(
            (item) => BankOption(
              id: int.tryParse(item['id']?.toString() ?? '') ?? 0,
              shortName: (item['shortName'] ?? '').toString(),
            ),
          )
          .where((bank) => bank.id > 0)
          .toList(growable: false)
        ..sort((left, right) => left.shortName.toLowerCase().compareTo(
              right.shortName.toLowerCase(),
            ));
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

  Future<Map<String, dynamic>> updateCampaignLocation({
    required String campaignId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _apiClient.patch(
        '/charity/campaigns/$campaignId/location',
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      return _extractMap(
        response.data,
        fallbackMessage: 'Failed to check in campaign location',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getDistributingCampaignLocations() async {
    try {
      final response = await _apiClient.get(
        '/charity/campaigns/distributing-locations',
      );

      return _extractList(response.data);
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
        '/charity/internal/campaigns/$campaignId/donate/qr',
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

  Future<Map<String, dynamic>> triggerDonateTestCallback({
    required String transactionId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/charity/internal/transactions/$transactionId/test-callback',
      );
      return _extractMap(
        response.data,
        fallbackMessage: 'Failed to trigger test callback',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getCampaignTransactions({
    required String campaignId,
    String state = 'SUCCESS',
  }) async {
    try {
      final response = await _apiClient.get(
        '/charity/campaigns/$campaignId/transactions',
        queryParameters: {'state': state},
      );

      return _extractList(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getCampaignSupplies({
    required String campaignId,
  }) async {
    try {
      final response = await _apiClient.get('/charity/campaigns/$campaignId/supplies');
      return _extractList(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> createCampaignSupply({
    required String campaignId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _apiClient.post(
        '/charity/campaigns/$campaignId/supplies',
        data: payload,
      );
      return _extractMap(response.data, fallbackMessage: 'Failed to create supply');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateCampaignSupply({
    required String campaignId,
    required String supplyId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _apiClient.put(
        '/charity/campaigns/$campaignId/supplies/$supplyId',
        data: payload,
      );
      return _extractMap(response.data, fallbackMessage: 'Failed to update supply');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteCampaignSupply({
    required String campaignId,
    required String supplyId,
  }) async {
    try {
      await _apiClient.delete('/charity/campaigns/$campaignId/supplies/$supplyId');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getCampaignFinancialSupports({
    required String campaignId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/charity/campaigns/$campaignId/financial-supports',
      );
      return _extractList(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> createCampaignFinancialSupport({
    required String campaignId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _apiClient.post(
        '/charity/campaigns/$campaignId/financial-supports',
        data: payload,
      );
      return _extractMap(
        response.data,
        fallbackMessage: 'Failed to create financial support',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateCampaignFinancialSupport({
    required String campaignId,
    required String financialSupportId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _apiClient.put(
        '/charity/campaigns/$campaignId/financial-supports/$financialSupportId',
        data: payload,
      );
      return _extractMap(
        response.data,
        fallbackMessage: 'Failed to update financial support',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteCampaignFinancialSupport({
    required String campaignId,
    required String financialSupportId,
  }) async {
    try {
      await _apiClient.delete(
        '/charity/campaigns/$campaignId/financial-supports/$financialSupportId',
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
