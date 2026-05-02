import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { JwtPayload } from '../interfaces/jwt-payload.interface';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private readonly prisma: PrismaService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.AT_SECRET || 'jwt-secret',
    });
  }

  // Hàm này tự động được gọi. Passport tự động gán đối tượng trả về vào request.user.
  async validate(payload: JwtPayload) {
    // Verify account exists and is active

    const account = await this.prisma.account.findUnique({
      where: { accountId: payload.sub },
      include: { user: true },
    });

    if (!account || account.state !== 'ACTIVE') {
      throw new UnauthorizedException(
        'Account not found or inactive or banned',
      );
    }

    // Return user info for request context
    return {
      accountId: account.accountId,
      userId: account.userId,
      username: account.username,
      role: account.user.role,
      purpose: payload.purpose,
      user: account.user,
    };
  }
}
