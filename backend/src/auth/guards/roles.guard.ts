import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY } from '../decorators/roles.decorator';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<string[]>(
      ROLES_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (!requiredRoles || requiredRoles.length === 0) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;
    const userRoles = this.extractUserRoles(user);

    const requiredRoleSet = new Set(
      requiredRoles.map((role) => role.toUpperCase()),
    );

    const allowed = userRoles.some((role) => requiredRoleSet.has(role));
    if (!allowed) {
      throw new ForbiddenException('Insufficient role to access this resource');
    }

    return true;
  }

  private extractUserRoles(user: unknown): string[] {
    if (!user || typeof user !== 'object') {
      return [];
    }

    const candidate = user as { role?: unknown; roles?: unknown };
    const fromRoles = this.normalizeRoles(candidate.roles);
    if (fromRoles.length > 0) {
      return fromRoles;
    }

    return this.normalizeRoles(candidate.role);
  }

  private normalizeRoles(value: unknown): string[] {
    if (Array.isArray(value)) {
      return value
        .map((item) => item?.toString().trim().toUpperCase())
        .filter((item): item is string => Boolean(item));
    }

    if (typeof value === 'string') {
      return value
        .split(',')
        .map((item) => item.trim().toUpperCase())
        .filter((item) => item.length > 0);
    }

    return [];
  }
}
