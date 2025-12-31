import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_dtos.freezed.dart';
part 'auth_dtos.g.dart';

@freezed
class SignupDto with _$SignupDto {
  factory SignupDto({
    required String username,
    required String password,
    required String name,
    required String phoneNumber,
    String? displayName,
    DateTime? dob,
    String? village,
    String? district,
    String? country,
    String? jobPosition,
  }) = _SignupDto;

  factory SignupDto.fromJson(Map<String, dynamic> json) =>
      _$SignupDtoFromJson(json);
}

@freezed
class SigninDto with _$SigninDto {
  factory SigninDto({
    required String username,
    required String password,
    String? deviceId,
  }) = _SigninDto;

  factory SigninDto.fromJson(Map<String, dynamic> json) =>
      _$SigninDtoFromJson(json);
}

@freezed
class VerifyCodeDto with _$VerifyCodeDto {
  factory VerifyCodeDto({
    required String username,
    required String code,
  }) = _VerifyCodeDto;

  factory VerifyCodeDto.fromJson(Map<String, dynamic> json) =>
      _$VerifyCodeDtoFromJson(json);
}

@freezed
class ResendVerificationCodeDto with _$ResendVerificationCodeDto {
  factory ResendVerificationCodeDto({
    required String username,
  }) = _ResendVerificationCodeDto;

  factory ResendVerificationCodeDto.fromJson(Map<String, dynamic> json) =>
      _$ResendVerificationCodeDtoFromJson(json);
}

@freezed
class ForgotPasswordDto with _$ForgotPasswordDto {
  factory ForgotPasswordDto({
    required String username,
  }) = _ForgotPasswordDto;

  factory ForgotPasswordDto.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordDtoFromJson(json);
}

@freezed
class ResetPasswordDto with _$ResetPasswordDto {
  factory ResetPasswordDto({
    required String newPassword,
  }) = _ResetPasswordDto;

  factory ResetPasswordDto.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordDtoFromJson(json);
}

@freezed
class RefreshTokenDto with _$RefreshTokenDto {
  factory RefreshTokenDto({
    required String refreshToken,
  }) = _RefreshTokenDto;

  factory RefreshTokenDto.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenDtoFromJson(json);
}

// You can also add response DTOs here if needed
