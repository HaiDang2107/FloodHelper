import 'package:dio/dio.dart';

import '../models/location_option.dart';
import 'api_client.dart';

class LocationService {
  final ApiClient _apiClient;

  LocationService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<ProvinceOption>> getProvinces() async {
    try {
      final response = await _apiClient.get('/locations/provinces');
      final items = _extractItems(response.data);

      return items
          .map(
            (item) => ProvinceOption(
              code: int.tryParse(item['code']?.toString() ?? '') ?? 0,
              name: (item['name'] ?? '').toString(),
              divisionType: (item['divisionType'] ?? '').toString(),
              codename: (item['codename'] ?? '').toString(),
              phoneCode: int.tryParse(item['phoneCode']?.toString() ?? '') ?? 0,
            ),
          )
          .where((province) => province.code > 0)
          .toList(growable: false);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<WardOption>> getWards({int? provinceCode}) async {
    try {
      final response = await _apiClient.get(
        provinceCode == null
            ? '/locations/wards'
            : '/locations/provinces/$provinceCode/wards',
      );
      final items = _extractItems(response.data);

      return items
          .map(
            (item) => WardOption(
              code: int.tryParse(item['code']?.toString() ?? '') ?? 0,
              name: (item['name'] ?? '').toString(),
              divisionType: (item['divisionType'] ?? '').toString(),
              codename: (item['codename'] ?? '').toString(),
              provinceCode:
                  int.tryParse(item['provinceCode']?.toString() ?? '') ?? 0,
            ),
          )
          .where((ward) => ward.code > 0)
          .toList(growable: false);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  List<Map<String, dynamic>> _extractItems(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList(growable: false);
      }
    }

    return const [];
  }
}