import { CanActivate, ExecutionContext, Injectable, UnauthorizedException } from '@nestjs/common';

@Injectable()
export class ServiceTokenGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const authHeader: string | undefined = request.headers?.authorization;

    if (!authHeader?.startsWith('Bearer ')) {
      throw new UnauthorizedException('Missing service token');
    }

    const token = authHeader.slice('Bearer '.length).trim();
    const expectedToken = process.env.MQTT_SERVICE_TOKEN;

    if (!expectedToken) {
      throw new UnauthorizedException('Service token not configured');
    }

    if (token !== expectedToken) {
      throw new UnauthorizedException('Invalid service token');
    }

    return true;
  }
}
