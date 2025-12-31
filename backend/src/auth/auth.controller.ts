import { Controller, Post, Body, Get, UseGuards, Res, Delete } from '@nestjs/common';
import type { Response } from 'express';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { CurrentUser } from './decorators/current-user.decorator';
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

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) { }

  @Post('register')
  async signUp(@Body() registerDto: SignupDto): Promise<{ message: string }> {
    return this.authService.signUp(registerDto);
  }

  @Post('register/verify')
  async verifyCode(@Body() verifyCodeDto: VerifyCodeDto): Promise<{ message: string }> {
    return this.authService.verifyCode(verifyCodeDto);
  }

  @Post('register/resend-code')
  async resendVerificationCode(
    @Body() resendDto: ResendVerificationCodeDto,
  ): Promise<{ message: string }> {
    return this.authService.resendVerificationCode(resendDto);
  }

  @Post('session')
  async signIn(
    @Body() signinDto: SigninDto,
    @Res({ passthrough: true }) response: Response,
  ): Promise<SigninResponseDto> {
    const result = await this.authService.signin(signinDto);
    response.cookie('refresh_token', result.data.tokens.refreshToken, {
      httpOnly: true,
    });
    delete result.data.tokens.refreshToken;
    return result;
  }

  @UseGuards(JwtAuthGuard)
  @Delete('session')
  async signOut(
    @Body() logoutDto: SignoutDto,
    @CurrentUser() user,
  ): Promise<SignoutResponseDto> {
    return this.authService.logout(logoutDto, user);
  }

  @Get('google')
  async googleLogin(): Promise<string> {
    // TODO: Implement Google OAuth initiation
    return this.authService.initiateGoogleLogin();
  }

  @Post('google/callback')
  async googleCallback(
    @Body() googleCallbackDto: GoogleCallbackDto,
  ): Promise<GoogleSigninResponseDto> {
    // TODO: Implement Google OAuth callback
    return this.authService.handleGoogleCallback(googleCallbackDto);
  }

  @Post('password/forgot')
  async forgotPassword(
    @Body() forgotPasswordDto: ForgotPasswordDto,
  ): Promise<{ message: string }> {
    return this.authService.forgotPassword(forgotPasswordDto);
  }

  @Post('password/verify')
  async verifyPasswordReset(
    @Body() verifyDto: VerifyCodeDto,
  ): Promise<{ resetToken: string }> {
    return this.authService.verifyPasswordReset(verifyDto);
  }

  @UseGuards(JwtAuthGuard)
  @Post('password/reset')
  async resetPassword(
    @Body() resetPasswordDto: ResetPasswordDto,
    @CurrentUser() user: { accountId: string },
  ): Promise<{ message: string }> {
    return this.authService.resetPassword(resetPasswordDto, user);
  }

  @Post('session/refresh')
  async refreshToken(
    @Body() refreshTokenDto: RefreshTokenDto,
  ): Promise<RefreshTokenResponseDto> {
    // TODO: Implement token refresh logic
    return this.authService.refreshToken(refreshTokenDto);
  }
}