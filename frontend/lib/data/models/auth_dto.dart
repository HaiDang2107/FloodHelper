/// Data Transfer Objects for Authentication API
/// These classes represent the request/response format for API communication

// ==================== REQUEST DTOs ====================

/// Sign in request
class SigninRequestDto {
  final String username;
  final String password;
  final String deviceId;

  SigninRequestDto({
    required this.username,
    required this.password,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'deviceId': deviceId,
      };
}

/// Sign up request
class SignupRequestDto {
  final String name;
  final String? displayName;
  final String phoneNumber;
  final String? dob;
  final String? village;
  final String? district;
  final String? country;
  final String? jobPosition;
  final String username;
  final String password;

  SignupRequestDto({
    required this.name,
    this.displayName,
    required this.phoneNumber,
    this.dob,
    this.village,
    this.district,
    this.country,
    this.jobPosition,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (displayName != null) 'displayName': displayName,
        'phoneNumber': phoneNumber,
        if (dob != null) 'dob': dob,
        if (village != null) 'village': village,
        if (district != null) 'district': district,
        if (country != null) 'country': country,
        if (jobPosition != null) 'jobPosition': jobPosition,
        'username': username,
        'password': password,
      };
}

/// Verify code request
class VerifyCodeRequestDto {
  final String username;
  final String type; // 'SIGNUP' or 'FORGOT_PASSWORD'
  final String code;

  VerifyCodeRequestDto({
    required this.username,
    required this.type,
    required this.code,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'type': type,
        'code': code,
      };
}

/// Resend verification code request
class ResendCodeRequestDto {
  final String username;
  final String type;

  ResendCodeRequestDto({
    required this.username,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'type': type,
      };
}

/// Forgot password request
class ForgotPasswordRequestDto {
  final String username;

  ForgotPasswordRequestDto({required this.username});

  Map<String, dynamic> toJson() => {'username': username};
}

/// Reset password request
class ResetPasswordRequestDto {
  final String newPassword;

  ResetPasswordRequestDto({required this.newPassword});

  Map<String, dynamic> toJson() => {'newPassword': newPassword};
}

/// Refresh token request
class RefreshTokenRequestDto {
  final String refreshToken;

  RefreshTokenRequestDto({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}

// ==================== RESPONSE DTOs ====================

/// Base API response
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }
}

/// User data in response
class UserResponseDto {
  final String userId;
  final String name;
  final String? displayName;
  final String? phoneNumber;
  final List<String> role;
  final String? avatarUrl;

  UserResponseDto({
    required this.userId,
    required this.name,
    this.displayName,
    this.phoneNumber,
    required this.role,
    this.avatarUrl,
  });

  factory UserResponseDto.fromJson(Map<String, dynamic> json) {
    return UserResponseDto(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'],
      phoneNumber: json['phoneNumber'],
      role: List<String>.from(json['role'] ?? []),
      avatarUrl: json['avatarUrl'],
    );
  }
}

/// Account data in response
class AccountResponseDto {
  final String accountId;
  final String username;
  final String state;

  AccountResponseDto({
    required this.accountId,
    required this.username,
    required this.state,
  });

  factory AccountResponseDto.fromJson(Map<String, dynamic> json) {
    return AccountResponseDto(
      accountId: json['accountId'] ?? '',
      username: json['username'] ?? '',
      state: json['state'] ?? '',
    );
  }
}

/// Tokens data in response
class TokensResponseDto {
  final String accessToken;
  final String? refreshToken;
  final int expiresIn;

  TokensResponseDto({
    required this.accessToken,
    this.refreshToken,
    required this.expiresIn,
  });

  factory TokensResponseDto.fromJson(Map<String, dynamic> json) {
    return TokensResponseDto(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'],
      expiresIn: json['expiresIn'] ?? 0,
    );
  }
}

/// Session data in response
class SessionResponseDto {
  final String sessionId;
  final DateTime expireAt;

  SessionResponseDto({
    required this.sessionId,
    required this.expireAt,
  });

  factory SessionResponseDto.fromJson(Map<String, dynamic> json) {
    return SessionResponseDto(
      sessionId: json['sessionId'] ?? '',
      expireAt: DateTime.parse(json['expireAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Verification code data in response
class VerificationResponseDto {
  final String verificationId;
  final DateTime expiresAt;

  VerificationResponseDto({
    required this.verificationId,
    required this.expiresAt,
  });

  factory VerificationResponseDto.fromJson(Map<String, dynamic> json) {
    return VerificationResponseDto(
      verificationId: json['verificationId'] ?? '',
      expiresAt: DateTime.parse(json['expiresAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Sign in response data
class SigninDataDto {
  final UserResponseDto user;
  final TokensResponseDto tokens;
  final SessionResponseDto session;

  SigninDataDto({
    required this.user,
    required this.tokens,
    required this.session,
  });

  factory SigninDataDto.fromJson(Map<String, dynamic> json) {
    return SigninDataDto(
      user: UserResponseDto.fromJson(json['user'] ?? {}),
      tokens: TokensResponseDto.fromJson(json['tokens'] ?? {}),
      session: SessionResponseDto.fromJson(json['session'] ?? {}),
    );
  }
}

/// Sign up response data
class SignupDataDto {
  final UserResponseDto user;
  final AccountResponseDto account;
  final VerificationResponseDto? verificationCode;

  SignupDataDto({
    required this.user,
    required this.account,
    this.verificationCode,
  });

  factory SignupDataDto.fromJson(Map<String, dynamic> json) {
    return SignupDataDto(
      user: UserResponseDto.fromJson(json['user'] ?? {}),
      account: AccountResponseDto.fromJson(json['account'] ?? {}),
      verificationCode: json['verificationCode'] != null
          ? VerificationResponseDto.fromJson(json['verificationCode'])
          : null,
    );
  }
}

/// Sign out response data
class SignoutDataDto {
  final int loggedOutSessions;

  SignoutDataDto({required this.loggedOutSessions});

  factory SignoutDataDto.fromJson(Map<String, dynamic> json) {
    return SignoutDataDto(
      loggedOutSessions: json['loggedOutSessions'] ?? 0,
    );
  }
}

/// Refresh token response data (for auto login)
class RefreshTokenDataDto {
  final TokensResponseDto tokens;
  final RefreshUserDto? user;
  final RefreshSessionDto? session;

  RefreshTokenDataDto({
    required this.tokens,
    this.user,
    this.session,
  });

  factory RefreshTokenDataDto.fromJson(Map<String, dynamic> json) {
    return RefreshTokenDataDto(
      tokens: TokensResponseDto.fromJson(json['tokens'] ?? {}),
      user: json['user'] != null ? RefreshUserDto.fromJson(json['user']) : null,
      session: json['session'] != null ? RefreshSessionDto.fromJson(json['session']) : null,
    );
  }
}

/// User data in refresh token response (role is single string)
class RefreshUserDto {
  final String userId;
  final String name;
  final String? displayName;
  final String? phoneNumber;
  final String role; // Single string from refresh endpoint
  final String? avatarUrl;

  RefreshUserDto({
    required this.userId,
    required this.name,
    this.displayName,
    this.phoneNumber,
    required this.role,
    this.avatarUrl,
  });

  factory RefreshUserDto.fromJson(Map<String, dynamic> json) {
    return RefreshUserDto(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'],
      phoneNumber: json['phoneNumber'],
      role: json['role'] ?? 'NORMAL_USER',
      avatarUrl: json['avatarUrl'],
    );
  }
}

/// Session data in refresh token response
class RefreshSessionDto {
  final String sessionId;
  final String deviceId;

  RefreshSessionDto({
    required this.sessionId,
    required this.deviceId,
  });

  factory RefreshSessionDto.fromJson(Map<String, dynamic> json) {
    return RefreshSessionDto(
      sessionId: json['sessionId'] ?? '',
      deviceId: json['deviceId'] ?? '',
    );
  }
}

/// Verify code response
class VerifyCodeResponseDto {
  final bool success;
  final String message;
  final String? resetToken;

  VerifyCodeResponseDto({
    required this.success,
    required this.message,
    this.resetToken,
  });

  factory VerifyCodeResponseDto.fromJson(Map<String, dynamic> json) {
    return VerifyCodeResponseDto(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      resetToken: json['resetToken'],
    );
  }
}
