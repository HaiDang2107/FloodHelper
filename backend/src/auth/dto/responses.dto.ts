export class SignupResponseDto {
  success: boolean;
  message: string;
  data: {
    user: {
      userId: string;
      name: string;
      displayName?: string | null;
      phoneNumber: string;
      role: string[];
    };
    account: {
      accountId: string;
      username: string;
      state: string;
    };
    verificationCode?: {
      verificationId: string;
      expiresAt: Date;
    };
  };
}

export class SigninResponseDto {
  success: boolean;
  message: string;
  data: {
    user: {
      userId: string;
      name: string;
      displayName?: string | null;
      phoneNumber: string;
      role: string[];
      avatarUrl?: string | null;
      gender?: string | null;
      dob?: Date | null;
      placeOfOrigin?: string | null;
      placeOfResidence?: string | null;
      originProvinceCode?: number | null;
      originProvinceName?: string | null;
      originWardCode?: number | null;
      originWardName?: string | null;
      residenceProvinceCode?: number | null;
      residenceProvinceName?: string | null;
      residenceWardCode?: number | null;
      residenceWardName?: string | null;
      dateOfIssue?: Date | null;
      dateOfExpire?: Date | null;
      citizenId?: string | null;
      citizenIdCardImg?: string | null;
      jobPosition?: string | null;
      showCharityCampaignLocations?: boolean;
    };
    tokens: {
      accessToken: string;
      refreshToken?: string;
      expiresIn: number;
    };
  };
}

export class SignoutResponseDto {
  success: boolean;
  message: string;
  data: {
    loggedOutSessions: number;
  };
}

export class GoogleSigninResponseDto {
  success: boolean;
  message: string;
  data: {
    user: {
      userId: string;
      name: string;
      displayName?: string | null;
      phoneNumber?: string | null;
      role: string[];
      avatarUrl?: string | null;
    };
    tokens: {
      accessToken: string;
      refreshToken: string;
      expiresIn: number;
    };
    session: {
      sessionId: string;
      expireAt: Date;
    };
    isNewUser: boolean;
  };
}

export class ForgotPasswordResponseDto {
  success: boolean;
  message: string;
  data: {
    verificationId: string;
    expiresAt: Date;
  };
}

export class VerifyCodeResponseDto {
  success: boolean;
  resetToken?: string;
  message: string;
}

export class ResetPasswordResponseDto {
  success: boolean;
  message: string;
}

export class RefreshTokenResponseDto {
  success: boolean;
  message: string;
  data?: {
    tokens: {
      accessToken: string;
      refreshToken?: string;
      expiresIn: number;
    };
  } | null;
}

export class ErrorResponseDto {
  success: false;
  message: string;
  error: {
    code: string;
    details?: any;
  };
}
