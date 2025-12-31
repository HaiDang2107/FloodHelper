// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SignupDtoImpl _$$SignupDtoImplFromJson(Map<String, dynamic> json) =>
    _$SignupDtoImpl(
      username: json['username'] as String,
      password: json['password'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      displayName: json['displayName'] as String?,
      dob: json['dob'] == null ? null : DateTime.parse(json['dob'] as String),
      village: json['village'] as String?,
      district: json['district'] as String?,
      country: json['country'] as String?,
      jobPosition: json['jobPosition'] as String?,
    );

Map<String, dynamic> _$$SignupDtoImplToJson(_$SignupDtoImpl instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'name': instance.name,
      'phoneNumber': instance.phoneNumber,
      'displayName': instance.displayName,
      'dob': instance.dob?.toIso8601String(),
      'village': instance.village,
      'district': instance.district,
      'country': instance.country,
      'jobPosition': instance.jobPosition,
    };

_$SigninDtoImpl _$$SigninDtoImplFromJson(Map<String, dynamic> json) =>
    _$SigninDtoImpl(
      username: json['username'] as String,
      password: json['password'] as String,
      deviceId: json['deviceId'] as String?,
    );

Map<String, dynamic> _$$SigninDtoImplToJson(_$SigninDtoImpl instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'deviceId': instance.deviceId,
    };

_$VerifyCodeDtoImpl _$$VerifyCodeDtoImplFromJson(Map<String, dynamic> json) =>
    _$VerifyCodeDtoImpl(
      username: json['username'] as String,
      code: json['code'] as String,
    );

Map<String, dynamic> _$$VerifyCodeDtoImplToJson(_$VerifyCodeDtoImpl instance) =>
    <String, dynamic>{'username': instance.username, 'code': instance.code};

_$ResendVerificationCodeDtoImpl _$$ResendVerificationCodeDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ResendVerificationCodeDtoImpl(username: json['username'] as String);

Map<String, dynamic> _$$ResendVerificationCodeDtoImplToJson(
  _$ResendVerificationCodeDtoImpl instance,
) => <String, dynamic>{'username': instance.username};

_$ForgotPasswordDtoImpl _$$ForgotPasswordDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ForgotPasswordDtoImpl(username: json['username'] as String);

Map<String, dynamic> _$$ForgotPasswordDtoImplToJson(
  _$ForgotPasswordDtoImpl instance,
) => <String, dynamic>{'username': instance.username};

_$ResetPasswordDtoImpl _$$ResetPasswordDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ResetPasswordDtoImpl(newPassword: json['newPassword'] as String);

Map<String, dynamic> _$$ResetPasswordDtoImplToJson(
  _$ResetPasswordDtoImpl instance,
) => <String, dynamic>{'newPassword': instance.newPassword};

_$RefreshTokenDtoImpl _$$RefreshTokenDtoImplFromJson(
  Map<String, dynamic> json,
) => _$RefreshTokenDtoImpl(refreshToken: json['refreshToken'] as String);

Map<String, dynamic> _$$RefreshTokenDtoImplToJson(
  _$RefreshTokenDtoImpl instance,
) => <String, dynamic>{'refreshToken': instance.refreshToken};
