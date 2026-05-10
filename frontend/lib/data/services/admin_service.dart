import 'api_client.dart';

class AdminService {
  final ApiClient _apiClient;

  AdminService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Map<String, dynamic>> getAdminProfile() async {
    final response = await _apiClient.get('/admin/profile');
    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> searchUserByEmail(String email) async {
    final response = await _apiClient.get(
      '/admin/users/search',
      queryParameters: <String, dynamic>{'email': email},
    );
    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getUserById(String userId) async {
    final response = await _apiClient.get('/admin/users/$userId');
    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> createAuthority({
    required String fullname,
    required String phoneNumber,
    required String username,
    required String password,
    required int residenceWardCode,
    String? nickname,
    String? gender,
    String? dob,
    int? originProvinceCode,
    int? originWardCode,
    int? residenceProvinceCode,
    String? dateOfIssue,
    String? dateOfExpire,
    String? citizenId,
    String? occupation,
  }) async {
    final data = <String, dynamic>{
      'fullname': fullname,
      'phoneNumber': phoneNumber,
      'username': username,
      'password': password,
      'residenceWardCode': residenceWardCode,
      if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
      if (gender != null && gender.isNotEmpty) 'gender': gender,
      if (dob != null && dob.isNotEmpty) 'dob': dob,
      if (originProvinceCode != null) 'originProvinceCode': originProvinceCode,
      if (originWardCode != null) 'originWardCode': originWardCode,
      if (residenceProvinceCode != null)
        'residenceProvinceCode': residenceProvinceCode,
      if (dateOfIssue != null && dateOfIssue.isNotEmpty) 'dateOfIssue': dateOfIssue,
      if (dateOfExpire != null && dateOfExpire.isNotEmpty) 'dateOfExpire': dateOfExpire,
      if (citizenId != null && citizenId.isNotEmpty) 'citizenId': citizenId,
      if (occupation != null && occupation.isNotEmpty) 'occupation': occupation,
    };

    final response = await _apiClient.post('/admin/authorities', data: data);
    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> updateAuthority(
    String userId, {
    String? fullname,
    String? nickname,
    String? phoneNumber,
    String? gender,
    String? dob,
    int? originProvinceCode,
    int? originWardCode,
    int? residenceProvinceCode,
    int? residenceWardCode,
    String? dateOfIssue,
    String? dateOfExpire,
    String? citizenId,
    String? occupation,
    bool? isAuthority,
  }) async {
    final data = <String, dynamic>{
      if (fullname != null && fullname.isNotEmpty) 'fullname': fullname,
      if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
      if (phoneNumber != null && phoneNumber.isNotEmpty) 'phoneNumber': phoneNumber,
      if (gender != null && gender.isNotEmpty) 'gender': gender,
      if (dob != null && dob.isNotEmpty) 'dob': dob,
      if (originProvinceCode != null) 'originProvinceCode': originProvinceCode,
      if (originWardCode != null) 'originWardCode': originWardCode,
      if (residenceProvinceCode != null) 'residenceProvinceCode': residenceProvinceCode,
      if (residenceWardCode != null) 'residenceWardCode': residenceWardCode,
      if (dateOfIssue != null && dateOfIssue.isNotEmpty) 'dateOfIssue': dateOfIssue,
      if (dateOfExpire != null && dateOfExpire.isNotEmpty) 'dateOfExpire': dateOfExpire,
      if (citizenId != null && citizenId.isNotEmpty) 'citizenId': citizenId,
      if (occupation != null && occupation.isNotEmpty) 'occupation': occupation,
      if (isAuthority != null) 'isAuthority': isAuthority,
    };

    final response = await _apiClient.patch('/admin/authorities/$userId', data: data);
    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }
}
