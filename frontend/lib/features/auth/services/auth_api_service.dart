import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:antiflood/common/constants/api.dart';
import 'package:antiflood/features/auth/models/auth_dtos.dart';
import 'package:antiflood/features/auth/services/auth_storage.dart';

part 'auth_api_service.g.dart';

@riverpod
AuthApiService authApiService(AuthApiServiceRef ref) {
  return AuthApiService();
}

class AuthApiService {
  final Dio _dio;

  // TODO: Implement interceptors for token handling
  AuthApiService()
      : _dio = Dio(BaseOptions(baseUrl: '${ApiConstants.baseUrl}${ApiConstants.authBasePath}')) {
    // Initialize AuthStorage with this instance
    AuthStorage.initialize(this);

    // Add logging interceptor first
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));

    // Add interceptors for automatic token handling
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add access token to headers if available
        final token = await AuthStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle token expiry - try to refresh token only if user is logged in
        if (error.response?.statusCode == 401) {
          final isLoggedIn = await AuthStorage.isAuthenticated();
          if (isLoggedIn) {
            try {
              final refreshSuccess = await AuthStorage.refreshAccessToken();
              if (refreshSuccess) {
                // Retry the original request with new token
                final token = await AuthStorage.getAccessToken();
                if (token != null) {
                  error.requestOptions.headers['Authorization'] = 'Bearer $token';
                  final retryResponse = await _dio.fetch(error.requestOptions);
                  return handler.resolve(retryResponse);
                }
              }
            } catch (refreshError) {
              print('Token refresh failed: $refreshError');
            }
          }
        }
        return handler.next(error);
      },
    ));
  }

  Future<void> signUp(SignupDto data) async {
    try {
      await _dio.post('/register', data: data.toJson());
    } on DioException catch (e) {
      // TODO: Handle exceptions
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<void> verifyCode(VerifyCodeDto data) async {
    try {
      await _dio.post('/register/verify', data: data.toJson());
    } on DioException catch (e) {
      throw Exception('Failed to verify code: $e');
    }
  }
  
  Future<void> resendVerificationCode(ResendVerificationCodeDto data) async {
    try {
      await _dio.post('/register/resend-code', data: data.toJson());
    } on DioException catch (e) {
      throw Exception('Failed to resend verification code: $e');
    }
  }

  Future<Map<String, dynamic>> signIn(SigninDto data) async {
    try {
      final response = await _dio.post('/session', data: data.toJson());
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _dio.delete('/session');
    } on DioException catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  Future<void> forgotPassword(ForgotPasswordDto data) async {
    try {
      await _dio.post('/password/forgot', data: data.toJson());
    } on DioException catch (e) {
      throw Exception('Failed to request password reset: $e');
    }
  }

  Future<String> verifyPasswordReset(VerifyCodeDto data) async {
    try {
      final response = await _dio.post('/password/verify', data: data.toJson());
      return response.data['resetToken'];
    } on DioException catch (e) {
      throw Exception('Failed to verify password reset: $e');
    }
  }

  Future<void> resetPassword(ResetPasswordDto data, String resetToken) async {
    try {
      await _dio.post(
        '/password/reset',
        data: data.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $resetToken'}),
      );
    } on DioException catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  Future<Map<String, dynamic>> refreshToken(RefreshTokenDto data) async {
    try {
      final response = await _dio.post('/session/refresh', data: data.toJson());
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to refresh token: $e');
    }
  }
}
