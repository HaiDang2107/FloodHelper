import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/auth_dto.dart';

/// Service for authentication API calls
class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Sign in with username and password
  Future<ApiResponse<SigninDataDto>> signIn(SigninRequestDto request) async {
    try {
      final response = await _apiClient.post(
        '/auth/signin',
        data: request.toJson(),
      );

      return ApiResponse<SigninDataDto>.fromJson(
        response.data,
        (data) => SigninDataDto.fromJson(data),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Sign up with user information
  Future<ApiResponse<void>> signUp(SignupRequestDto request) async {
    try {
      final response = await _apiClient.post(
        '/auth/signup',
        data: request.toJson(),
      );

      // Backend returns { message: "..." } only
      return ApiResponse<void>.fromJson(response.data, null);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Verify code (for signup or password reset)
  Future<VerifyCodeResponseDto> verifyCode(VerifyCodeRequestDto request) async {
    try {
      final response = await _apiClient.post(
        '/auth/verify',
        data: request.toJson(),
      );

      return VerifyCodeResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Resend verification code
  Future<ApiResponse<void>> resendCode(ResendCodeRequestDto request) async {
    try {
      final response = await _apiClient.post(
        '/auth/resend-code',
        data: request.toJson(),
      );

      return ApiResponse<void>.fromJson(response.data, null);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Sign out
  Future<ApiResponse<SignoutDataDto>> signOut({bool logoutAll = false}) async {
    try {
      final response = await _apiClient.delete(
        '/auth/signout',
        queryParameters: {'logoutAll': logoutAll},
      );

      return ApiResponse<SignoutDataDto>.fromJson(
        response.data,
        (data) => SignoutDataDto.fromJson(data),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Forgot password - send reset code
  Future<ApiResponse<void>> forgotPassword(ForgotPasswordRequestDto request) async {
    try {
      final response = await _apiClient.post(
        '/auth/password/forgot',
        data: request.toJson(),
      );

      return ApiResponse<void>.fromJson(response.data, null);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Reset password
  Future<ApiResponse<void>> resetPassword(
    ResetPasswordRequestDto request,
    String resetToken,
  ) async {
    try {
      final response = await _apiClient.post(
        '/auth/password/reset',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $resetToken',
          },
        ),
      );

      return ApiResponse<void>.fromJson(response.data, null);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Refresh token - uses cookie automatically via Dio CookieManager
  Future<ApiResponse<RefreshTokenDataDto>> refreshToken() async {
    try {
      // No body needed - refresh_token is sent via cookie automatically
      final response = await _apiClient.post(
        '/auth/token/refresh',
      );

      return ApiResponse<RefreshTokenDataDto>.fromJson(
        response.data,
        (data) => RefreshTokenDataDto.fromJson(data),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Set auth token for subsequent requests
  void setAuthToken(String token) {
    _apiClient.setAuthToken(token);
  }

  /// Clear auth token and cookies
  void clearAuthToken() {
    _apiClient.clearAuthToken();
    _apiClient.clearCookies(); // Clear cookies including refresh_token
  }
}
