import { Controller, Post, Body, Get, UseGuards, Res, Delete, Req, Query } from '@nestjs/common';
import type { Response, Request } from 'express';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { GoogleAuthGuard } from './guards/google-auth.guard';
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
  VerifyCodeResponseDto,
  ResetPasswordResponseDto,
  RefreshTokenResponseDto,
  VerifyCodeDto,
  ResendVerificationCodeDto,
} from './dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) { }

  @Post('signup')
  async signUp(@Body() registerDto: SignupDto): Promise<{ success: boolean; message: string }> {
    return this.authService.signUp(registerDto);
  }

  @Post('verify')
  async verifyCode(@Body() verifyCodeDto: VerifyCodeDto): Promise<VerifyCodeResponseDto> {
    return this.authService.verifyCode(verifyCodeDto);
  }

  @Post('resend-code')
  async resendVerificationCode(
    @Body() resendDto: ResendVerificationCodeDto,
  ): Promise<{ success: boolean; message: string }> {
    return this.authService.resendVerificationCode(resendDto);
  }

  @Post('signin')
  async signIn(
    @Body() signinDto: SigninDto,
    @Res({ passthrough: true }) response: Response,
    // @Res: Can thiệp vào Response (set header, ...) bởi vì bình thường, NestJS gửi response tự động
    // passthrough: Báo cho NestJS vẫn gửi response tự động sau khi can thiệp xong
    // Vì refresh token được cho vào cookie ==> xóa refresh_token trong body
  ): Promise<SigninResponseDto> {
    const result = await this.authService.signin(signinDto);
    response.cookie('refresh_token', result.data.tokens.refreshToken, {
      httpOnly: true,
      path: '/',
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
    });
    delete result.data.tokens.refreshToken;
    return result;
  }

  @UseGuards(JwtAuthGuard)
  @Delete('signout')
  async signOut(
    @CurrentUser() user,
    @Res({ passthrough: true }) response: Response,
    @Query('logoutAll') logoutAll?: boolean,
  ): Promise<SignoutResponseDto> {
    const result = await this.authService.logout({ logoutAll }, user);
    response.clearCookie('refresh_token', { path: '/' });
    return result;
  }

  // @Get('google')
  // @UseGuards(GoogleAuthGuard)
  // async googleLogin(): Promise<void> {
  //   // Initiates Google OAuth flow - redirects to Google
  //   // No response needed as guard handles redirect
  // }

  // @Get('google/callback')
  // @UseGuards(GoogleAuthGuard)
  // async googleCallback(
  //   @Req() req: Request,
  //   @Res({ passthrough: true }) response: Response,
  // ): Promise<GoogleSigninResponseDto> {
  //   const googleUser = req.user;
  //   const result = await this.authService.handleGoogleCallback(googleUser);
    
  //   // Set refresh token in cookie
  //   response.cookie('refresh_token', result.data.tokens.refreshToken, {
  //     httpOnly: true,
  //     path: 'auth/token/refresh',
  //   });
    
  //   // Remove refresh token from response body
  //   result.data.tokens.refreshToken = undefined as any;
    
  //   return result;
  // }

  @Post('password/forgot')
  async forgotPassword(
    @Body() forgotPasswordDto: ForgotPasswordDto,
  ): Promise<{ success: boolean; message: string }> {
    return this.authService.forgotPassword(forgotPasswordDto);
  }

  // @Post('password/verify')
  // async verifyPasswordReset(
  //   @Body() verifyDto: VerifyCodeDto,
  // ): Promise<{ resetToken: string }> {
  //   return this.authService.verifyPasswordReset(verifyDto);
  // }

  @UseGuards(JwtAuthGuard)
  @Post('password/reset')
  async resetPassword(
    @Body() resetPasswordDto: ResetPasswordDto,
    @CurrentUser() user: { accountId: string },
  ): Promise<{ success: boolean; message: string }> {
    return this.authService.resetPassword(resetPasswordDto, user);
  }

  @Post('token/refresh')
  async refreshToken(
    @Req() request: Request,
    @Res({ passthrough: true }) response: Response,
  ): Promise<RefreshTokenResponseDto> {
    // Get refresh token from cookie
    const refreshToken = request.cookies?.refresh_token;
    
    if (!refreshToken) {
      return {
        success: false,
        message: 'No refresh token provided',
        data: null,
      };
    }

    const result = await this.authService.refreshToken({ refreshToken });
    
    // If successful, set new refresh token cookie
    if (result.success && result.data?.tokens?.refreshToken) {
      response.cookie('refresh_token', result.data.tokens.refreshToken, {
        httpOnly: true,
        path: '/',
        maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
      });
      // Remove refresh token from response body
      delete result.data.tokens.refreshToken;
    }
    
    return result;
  }
}