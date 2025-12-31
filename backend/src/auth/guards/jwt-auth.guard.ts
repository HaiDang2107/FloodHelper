import { Injectable, ExecutionContext } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  canActivate(context: ExecutionContext) {
    const request = context.switchToHttp().getRequest();
    const url = request.url;

    // Always allow for password reset endpoint
    if (url.includes('/auth/reset-password')) {
      return super.canActivate(context);
    }

    // For other endpoints, check if purpose is 'normal-service'
    return Promise.resolve(super.canActivate(context)).then((canActivate) => {
      if (!canActivate) {
        return false;
      }
      const user = request.user;
      if (user && user.purpose !== 'normal-service') {
        return false;
      }
      return true;
    });
  }
}