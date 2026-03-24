import { Injectable, ExecutionContext } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Purpose } from '../../common/enum/purpose.enum';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  canActivate(context: ExecutionContext) {
    const request = context.switchToHttp().getRequest();
    const url = request.url;

    // First, authenticate the JWT token
    return Promise.resolve(super.canActivate(context)).then((canActivate) => {
      if (!canActivate) {
        return false;
      }

      // Now user is populated by passport
      const user = request.user;

      // For password reset endpoint, allow RESET_PASSWORD or USE_OTHER_SERVICES tokens
      if (url.includes('/auth/password/reset')) {
        return (
          user &&
          (user.purpose === Purpose.RESET_PASSWORD ||
            user.purpose === Purpose.USE_OTHER_SERVICES)
        );
      }

      // For other endpoints, RESET_PASSWORD tokens are NOT allowed
      if (user && user.purpose === Purpose.RESET_PASSWORD) {
        return false;
      }

      return true;
    });
  }
}
