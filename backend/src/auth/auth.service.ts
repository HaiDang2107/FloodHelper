
import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { AccountState } from '../common/accountState.enum';
import { VerificationType } from '../common/verificationType.enum';
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
  ResetPasswordResponseDto,
  RefreshTokenResponseDto,
  VerifyCodeDto,
  ResendVerificationCodeDto,
} from './dto';

@Injectable()
export class AuthService {
  private prisma: PrismaClient;

  constructor(private jwtService: JwtService) {
    this.prisma = new PrismaClient();
  }

  async signUp(registerDto: SignupDto): Promise<{ message: string }> {
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
        // Resend verification for existing inactive account
        await this.createAndSendVerificationCode(
          existingAccount,
          VerificationType.ACCOUNT_CREATION,
        );
        throw new ConflictException(
          'Account is not activated. Verification code has been sent again.',
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
      user.account,
      VerificationType.ACCOUNT_CREATION,
    );

    return {
      message:
        'Registration successful. Please check your email to activate your account.',
    };
  }

  async verifyCode(verifyCodeDto: VerifyCodeDto): Promise<{ message: string }> {
    const { username, code } = verifyCodeDto;

    const verificationCode = await this.prisma.verificationCode.findFirst({
      where: {
        account: {
          username,
        },
        code,
        type: VerificationType.ACCOUNT_CREATION,
      },
    });

    if (!verificationCode) {
      throw new NotFoundException('Invalid verification code.');
    }

    if (new Date() > verificationCode.expiresAt) {
      // Consider deleting the expired code
      await this.prisma.verificationCode.delete({
        where: { verificationId: verificationCode.verificationId },
      });
      throw new UnauthorizedException('Verification code has expired.');
    }

    // Activate account and delete the code
    await this.prisma.$transaction([
      this.prisma.account.update({
        where: { accountId: verificationCode.accountId },
        data: { state: AccountState.ACTIVE },
      }),
      this.prisma.verificationCode.delete({
        where: { verificationId: verificationCode.verificationId },
      }),
    ]);

    return { message: 'Account verification successful.' };
  }

  async resendVerificationCode(
    resendDto: ResendVerificationCodeDto,
  ): Promise<{ message: string }> {
    const { username } = resendDto;
    const account = await this.prisma.account.findUnique({
      where: { username },
    });

    if (!account) {
      throw new NotFoundException('Account does not exist.');
    }

    if (account.state !== AccountState.INACTIVE) {
      throw new ConflictException('Account is already activated or banned.');
    }

    await this.createAndSendVerificationCode(
      account,
      VerificationType.ACCOUNT_CREATION,
    );

    return { message: 'Verification code has been sent again.' };
  }

  private async createAndSendVerificationCode(
    account,
    type: VerificationType,
  ) {
    // const code = this.generateVerificationCode();
    // const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

    // // Delete old codes of the same type
    // await this.prisma.verificationCode.deleteMany({
    //   where: {
    //     accountId: account.accountId,
    //     type,
    //   }
    // })

    // await this.prisma.verificationCode.create({
    //   data: {
    //     accountId: account.accountId,
    //     code,
    //     type,
    //     expiresAt,
    //   },
    // });

    // await this.sendEmail(account.username, 'Account Verification Code', code);
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
      throw new UnauthorizedException('User not found');
    }

    const isPasswordMatching = await bcrypt.compare(password, account.password);
    if (!isPasswordMatching) {
      throw new UnauthorizedException('Incorrect password.');
    }

    const tokens = await this.generateTokens(
      account.accountId,
      username,
      account.user.role,
      'normal-service',
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
    roles: string[],
    purpose: 'normal-service' | 'reset-password' = 'normal-service',
  ) {
    const payload = {
      sub: accountId,
      username,
      roles,
      purpose,
    };

    const atExpiresIn = process.env.AT_EXPIRES_IN || '15m';
    const rtExpiresIn = process.env.RT_EXPIRES_IN || '7d';

    const accessToken = this.jwtService.sign(payload as any, {
      secret: process.env.AT_SECRET || 'at-secret',
      expiresIn: atExpiresIn,
    } as any);
    const refreshToken = this.jwtService.sign(payload as any, {
      secret: process.env.RT_SECRET || 'rt-secret',
      expiresIn: rtExpiresIn,
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
    deviceId: string | undefined,
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
    return {
      success: true,
      message: 'Logout successful',
      data: {
        loggedOutSessions: 1,
      },
    };
  }

  async initiateGoogleLogin(): Promise<string> {
    // TODO: Implement Google OAuth initiation
    return 'https://accounts.google.com/oauth/authorize?...';
  }

  async handleGoogleCallback(
    googleCallbackDto: GoogleCallbackDto,
  ): Promise<GoogleSigninResponseDto> {
    return {
      success: true,
      message: 'Google login successful',
      data: {
        user: {
          userId: 'temp-user-id',
          name: 'Google User',
          phoneNumber: '+84901234567',
          role: ['GUEST'],
        },
        tokens: {
          accessToken: 'temp-access-token',
          refreshToken: 'temp-refresh-token',
          expiresIn: 900,
        },
        session: {
          sessionId: 'temp-session-id',
          expireAt: new Date(Date.now() + 15 * 60 * 1000),
        },
        isNewUser: true,
      },
    };
  }

  async forgotPassword(
    forgotPasswordDto: ForgotPasswordDto,
  ): Promise<{ message: string }> {
    const { username } = forgotPasswordDto;
    const account = await this.prisma.account.findUnique({
      where: { username },
    });

    if (!account) {
      throw new NotFoundException('Account does not exist.');
    }

    this.validateAccountState(account);

    await this.createAndSendVerificationCode(
      account,
      VerificationType.PASSWORD_RESET,
    );

    return {
      message: 'Password reset request has been sent. Please check your email.',
    };
  }

  async verifyPasswordReset(
    verifyDto: VerifyCodeDto,
  ): Promise<{ resetToken: string }> {
    const { username, code } = verifyDto;
    const verificationCode = await this.prisma.verificationCode.findFirst({
      where: {
        account: { username },
        code,
        type: VerificationType.PASSWORD_RESET,
      },
    });

    if (!verificationCode) {
      throw new NotFoundException('Invalid verification code.');
    }

    if (new Date() > verificationCode.expiresAt) {
      await this.prisma.verificationCode.delete({
        where: { verificationId: verificationCode.verificationId },
      });
      throw new UnauthorizedException('Verification code has expired.');
    }

    const account = await this.prisma.account.findUnique({
      where: { accountId: verificationCode.accountId }
    });

    if (!account) {
        throw new UnauthorizedException('User not found');
    }

    // Delete code and generate password-reset JWT
    await this.prisma.verificationCode.delete({
      where: { verificationId: verificationCode.verificationId },
    });

    const payload = {
      sub: account.accountId,
      username: account.username,
      purpose: 'reset-password' as const,
    };

    const resetToken = this.jwtService.sign(payload as any, {
      secret: process.env.AT_SECRET || 'at-secret',
      expiresIn: process.env.AT_EXPIRES_IN || '15m',
    } as any);

    return { resetToken };
  }

  async resetPassword(
    resetPasswordDto: ResetPasswordDto,
    user: { accountId: string },
  ): Promise<{ message: string }> {
    const { newPassword } = resetPasswordDto;
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    await this.prisma.account.update({
      where: { accountId: user.accountId },
      data: { password: hashedPassword },
    });

    return { message: 'Password has been reset successfully.' };
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
        session.account.user.role,
        'normal-service',
      );

      // Update session with new refresh token and expiration
      await this.prisma.session.update({
        where: { sessionId: session.sessionId },
        data: {
          refreshToken: await bcrypt.hash(newTokens.refreshToken, 10),
          expireAt: new Date(Date.now() + this.convertToSeconds(process.env.RT_EXPIRES_IN || '7d') * 1000),
        },
      });

      return {
        success: true,
        message: 'Token refreshed successfully',
        data: {
          tokens: {
            accessToken: newTokens.accessToken,
            refreshToken: newTokens.refreshToken,
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
