
import {
  Injectable,
  Inject,
  UnauthorizedException,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { AccountState } from '../common/enum/accountState.enum';
import { Purpose } from '../common/enum/purpose.enum';
import { MailerService } from '@nestjs-modules/mailer';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import type { Cache } from 'cache-manager';
import { CachedOtp, JwtPayload } from './interfaces';
import {
  SignupDto,
  SigninDto,
  SignoutDto,
  ForgotPasswordDto,
  ResetPasswordDto,
  RefreshTokenDto,
  GoogleCallbackDto,
  SignupResponseDto,
  SigninResponseDto,
  SignoutResponseDto,
  GoogleSigninResponseDto,
  ForgotPasswordResponseDto,
  VerifyCodeResponseDto,
  ResetPasswordResponseDto,
  RefreshTokenResponseDto,
  VerifyCodeDto,
  ResendVerificationCodeDto,
} from './dto';

@Injectable()
export class AuthService {
  private prisma: PrismaClient;

  constructor(
    private jwtService: JwtService,
    private mailerService: MailerService,
    @Inject(CACHE_MANAGER) private cacheManager: Cache,
  ) {
    this.prisma = new PrismaClient();

  }

  async signUp(registerDto: SignupDto): Promise<{ success: boolean; message: string }> {
    const { username, password, name, phoneNumber, ...rest } = registerDto;

    const existingAccount = await this.prisma.account.findUnique({
      where: { username },
    });

    if (existingAccount) {
      if (
        existingAccount.state === AccountState.BANNED ||
        existingAccount.state === AccountState.ACTIVE
      ) {
        throw new ConflictException('Account already exists');
      }
      if (existingAccount.state === AccountState.INACTIVE) {
        throw new ConflictException(
          'Account is not activated.',
        );
      }
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await this.prisma.user.create({
      data: {
        name,
        phoneNumber,
        displayName: rest.displayName,
        dob: rest.dob ? new Date(rest.dob) : undefined,
        village: rest.village,
        district: rest.district,
        country: rest.country,
        jobPosition: rest.jobPosition,
        account: {
          create: {
            username,
            password: hashedPassword,
            state: AccountState.INACTIVE,
          },
        },
      },
      include: {
        account: true,
      },
    });

    await this.createAndSendVerificationCode(
      user.account?.username,
      Purpose.CREATE_ACCOUNT,
    );

    return {
      success: true,
      message:
        'Registration successful. Please check your email to activate your account.',
    };
  }

  async createAndSendVerificationCode(
    account: any,
    type: Purpose,
  ): Promise<void> {
    const code = this.generateVerificationCode();

    const payload: CachedOtp = {
      code: code,
      type: type,
    };

    await this.cacheManager.set(`otp_${account}`, payload, parseInt(process.env.TTL_OTP || '300000'));

    await this.mailerService.sendMail({
      to: account,
      subject: 'Mã xác thực',
      html: `<h1>Mã OTP của bạn là: ${code}</h1><p>Hết hạn sau 5 phút.</p>`,
    });
  }

  async verifyCode(verifyCodeDto: VerifyCodeDto): Promise<VerifyCodeResponseDto> {
    const { username, type, code } = verifyCodeDto;

    // Get verification code from Redis
    const storedPayload = await this.cacheManager.get<CachedOtp>(`otp_${username}`);

    if (!storedPayload || storedPayload.code !== code || storedPayload.type !== type) {
      throw new NotFoundException('Invalid verification code.');
    }

    await this.cacheManager.del(`otp_${username}`);

    const account = await this.prisma.account.findUnique({
      where: { username },
      include: { user: { select: { role: true } } },
    });

    if (!account) {
      throw new NotFoundException('Account not found.');
    }

    if (type === Purpose.CREATE_ACCOUNT) {
      if (account.state !== AccountState.INACTIVE) {
        throw new ConflictException('Account is already activated or banned.');
      }

      // Activate account
      await this.prisma.account.update({
        where: { accountId: account.accountId },
        data: { state: AccountState.ACTIVE },
      });

      return {
        success: true,
        message: 'Account verification successful.'
      };
    } else {
      const role = account.user.role;

      return {
        success: true,
        resetToken: (await this.generateTokens(account.accountId, username, '', role, type)).accessToken,
        message: 'Password reset verification successful.'
      };
    }
  }

  async resendVerificationCode(
    resendDto: ResendVerificationCodeDto,
  ): Promise<{ success: boolean; message: string }> {
    const { username, type } = resendDto;
    const account = await this.prisma.account.findUnique({
      where: { username },
    });

    if (!account) {
      throw new NotFoundException('Account does not exist.');
    }

    // if (account.state !== AccountState.INACTIVE) {
    //   throw new ConflictException('Account is already activated or banned.');
    // }

    if (type === Purpose.CREATE_ACCOUNT) {
      // For account creation, account must be INACTIVE
      if (account.state !== AccountState.INACTIVE) {
        throw new ConflictException('Account is already activated or banned.');
      }
    } else if (type === Purpose.RESET_PASSWORD) {
      // For password reset, account must be ACTIVE
      this.validateAccountState(account);
    }

    await this.createAndSendVerificationCode(
      account.username,
      type,
    );

    return { success: true, message: 'Verification code has been sent again.' };
  }

  private generateVerificationCode(length = 6): string {
    return Math.random().toString(10).substring(2, 2 + length);
  }

  private validateAccountState(account: any): void {
    if (account.state === AccountState.BANNED) {
      const message = 'Account is banned.';
      throw new ConflictException(message);
    }

    if (account.state === AccountState.INACTIVE) {
      const message = 'Account is not activated.';
      throw new ConflictException(message);
    }
  }

  async signin(signinDto: SigninDto): Promise<SigninResponseDto> {
    const { username, password, deviceId } = signinDto;

    const account = await this.prisma.account.findUnique({
      where: { username },
      include: { user: true },
    });

    if (!account) {
      throw new UnauthorizedException('User not found!');
    }

    const isPasswordMatching = await bcrypt.compare(password, account.password);
    if (!isPasswordMatching) {
      throw new UnauthorizedException('Incorrect password.');
    }

    // Validate account state before allowing login
    this.validateAccountState(account);

    const tokens = await this.generateTokens(
      account.accountId,
      username,
      deviceId,
      account.user.role,
      Purpose.CREATE_ACCOUNT,
    );
    await this.updateRefreshToken(
      account.accountId,
      tokens.refreshToken,
      deviceId,
      account.user.role,
    );

    const { user } = account;
    return {
      success: true,
      message: 'Sign in successful',
      data: {
        user: {
          userId: user.userId,
          name: user.name,
          displayName: user.displayName,
          phoneNumber: user.phoneNumber,
          role: user.role,
        },
        tokens: {
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
          expiresIn: tokens.accessTokenExpiresIn,
        },
        session: {
          sessionId: 'not-implemented', // This should be the created session id
          expireAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
        },
      },
    };
  }

  private async generateTokens(
    accountId: string,
    username: string,
    deviceId: string,
    roles: string[],
    purpose: Purpose
  ) {
    const payload: JwtPayload = {
      sub: accountId,
      username,
      deviceId,
      roles,
      purpose: purpose,
    };

    let refreshToken = '';

    if (purpose === Purpose.USE_OTHER_SERVICES) {
      const rtExpiresIn = process.env.RT_EXPIRES_IN || '7d';

      refreshToken = this.jwtService.sign(payload as any, {
        secret: process.env.RT_SECRET || 'rt-secret',
        expiresIn: rtExpiresIn,
      } as any);
    }

    const atExpiresIn = process.env.AT_EXPIRES_IN || '15m';

    const accessToken = this.jwtService.sign(payload as any, {
      secret: process.env.JWT_SECRET || 'jwt-secret',
      expiresIn: atExpiresIn,
    } as any);

    return {
      accessToken,
      refreshToken,
      accessTokenExpiresIn: this.convertToSeconds(atExpiresIn),
    };
  }

  private convertToSeconds(timeString: string): number {
    const regex = /^(\d+)([smhd])$/;
    const match = timeString.match(regex);

    if (!match) return 900; // Default 15 minutes

    const value = parseInt(match[1]);
    const unit = match[2];

    switch (unit) {
      case 's': return value;
      case 'm': return value * 60;
      case 'h': return value * 60 * 60;
      case 'd': return value * 60 * 60 * 24;
      default: return 900;
    }
  }

  private async updateRefreshToken(
    accountId: string,
    refreshToken: string,
    deviceId: string,
    role: string[],
  ) {
    const hashedRefreshToken = await bcrypt.hash(refreshToken, 10);
    await this.prisma.session.create({
      data: {
        accountId,
        refreshToken: hashedRefreshToken,
        deviceId,
        role: role.join(','), // Store roles as a comma-separated string
        expireAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
      },
    });
  }

  async logout(logoutDto: SignoutDto, user: any): Promise<SignoutResponseDto> {
    const { logoutAll } = logoutDto;
    let deletedSessions;

    if (logoutAll) {
      // Delete all sessions for this account
      deletedSessions = await this.prisma.session.deleteMany({
        where: {
          accountId: user.accountId,
        },
      });
    } else {
      // Delete only the session for this specific device
      deletedSessions = await this.prisma.session.deleteMany({
        where: {
          accountId: user.accountId,
          deviceId: user.deviceId,
        },
      });
    }

    return {
      success: true,
      message: 'Logout successful',
      data: {
        loggedOutSessions: deletedSessions.count,
      },
    };
  }

  // async initiateGoogleLogin(): Promise<string> {
  //   // This method is not needed with Passport strategy
  //   // The redirect is handled by GoogleAuthGuard
  //   return 'Use GET /auth/google to initiate Google OAuth flow';
  // }

  async handleGoogleCallback(
    googleUser: any,
    deviceId?: string,
  ): Promise<GoogleSigninResponseDto> {
    const { googleId, email, firstName, lastName, picture } = googleUser;

    // Check if user exists by email or googleId
    let accountWithUser = await this.prisma.account.findFirst({
      where: {
        OR: [
          { username: email },
          { providerId: googleId },
        ],
      },
      include: { user: true },
    });

    let isNewUser = false;

    if (!accountWithUser) {
      // Create new user with Google account
      isNewUser = true;
      const newUser = await this.prisma.user.create({
        data: {
          name: `${firstName} ${lastName}`,
          displayName: `${firstName} ${lastName}`,
          phoneNumber: email, // Using email as phoneNumber placeholder
          avatarUrl: picture,
          account: {
            create: {
              username: email,
              password: '', // No password for OAuth users
              state: AccountState.ACTIVE,
            },
          },
        },
        include: {
          account: true,
        },
      });
      
      // Re-fetch to get proper structure
      accountWithUser = await this.prisma.account.findUnique({
        where: { accountId: newUser.account!.accountId },
        include: { user: true },
      });
    }

    if (!accountWithUser) {
      throw new UnauthorizedException('Failed to create or retrieve account');
    }

    if (accountWithUser.state !== AccountState.ACTIVE) {
      throw new UnauthorizedException('Account is not active');
    }

    // Generate tokens
    const tokens = await this.generateTokens(
      accountWithUser.accountId,
      accountWithUser.username,
      deviceId || 'google-oauth',
      accountWithUser.user.role,
      Purpose.USE_OTHER_SERVICES,
    );

    // Update refresh token in session
    await this.updateRefreshToken(
      accountWithUser.accountId,
      tokens.refreshToken,
      deviceId || 'google-oauth',
      accountWithUser.user.role,
    );

    const user = accountWithUser.user;
    return {
      success: true,
      message: 'Google login successful',
      data: {
        user: {
          userId: user.userId,
          name: user.name,
          phoneNumber: user.phoneNumber,
          role: user.role,
        },
        tokens: {
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
          expiresIn: tokens.accessTokenExpiresIn,
        },
        session: {
          sessionId: 'google-session',
          expireAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
        },
        isNewUser,
      },
    };
  }

  async forgotPassword(
    forgotPasswordDto: ForgotPasswordDto,
  ): Promise<{ success: boolean; message: string }> {
    const { username } = forgotPasswordDto;
    const account = await this.prisma.account.findUnique({
      where: { username },
    });

    if (!account) {
      throw new NotFoundException('Account does not exist.');
    }

    this.validateAccountState(account);

    await this.createAndSendVerificationCode(
      account.username,
      Purpose.RESET_PASSWORD,
    );

    return {
      success: true,
      message: 'Password reset request has been sent. Please check your email.',
    };
  }

  // verifyPasswordReset removed - use verifyCode() with Purpose.RESET_PASSWORD instead

  async resetPassword(
    resetPasswordDto: ResetPasswordDto,
    user: { accountId: string },
  ): Promise<{ success: boolean; message: string }> {
    const { newPassword } = resetPasswordDto;
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    await this.prisma.account.update({
      where: { accountId: user.accountId },
      data: { password: hashedPassword },
    });

    return { success: true, message: 'Password has been reset successfully.' };
  }

  async refreshToken(
    refreshTokenDto: RefreshTokenDto,
  ): Promise<RefreshTokenResponseDto> {
    try {
      // Verify refresh token
      const payload = this.jwtService.verify(refreshTokenDto.refreshToken, {
        secret: process.env.RT_SECRET || 'rt-secret',
      });

      // Find session by refresh token
      const session = await this.prisma.session.findFirst({
        where: {
          refreshToken: await bcrypt.hash(refreshTokenDto.refreshToken, 10),
          expireAt: {
            gt: new Date(),
          },
        },
        include: {
          account: {
            include: { user: true },
          },
        },
      });

      if (!session) {
        throw new UnauthorizedException('Invalid or expired refresh token');
      }

      // Check if account is still active
      if (session.account.state !== 'ACTIVE') {
        throw new UnauthorizedException('Account is not active');
      }

      // Generate new tokens
      const newTokens = await this.generateTokens(
        session.account.accountId,
        session.account.username,
        session.deviceId || '',
        session.account.user.role,
        Purpose.REFRESH_TOKEN,
      );

      return {
        success: true,
        message: 'Token refreshed successfully',
        data: {
          tokens: {
            accessToken: newTokens.accessToken,
            expiresIn: newTokens.accessTokenExpiresIn,
          },
        },
      };
    } catch (error) {
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      throw new UnauthorizedException('Invalid refresh token');
    }
  }
}
