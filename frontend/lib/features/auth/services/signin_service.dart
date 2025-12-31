import 'package:antiflood/features/auth/models/auth_dtos.dart';
import 'package:antiflood/features/auth/services/auth_api_service.dart';

class SignInService {
  final AuthApiService _authApiService;

  SignInService(this._authApiService);

  Future<Map<String, dynamic>> signIn(String username, String password) async {
    try {
      final signinDto = SigninDto(
        username: username,
        password: password,
      );

      final response = await _authApiService.signIn(signinDto);
      return response;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }
}
