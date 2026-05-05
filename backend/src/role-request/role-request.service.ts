import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  CreateRoleRequestDto,
  ListRoleRequestsDto,
  RespondRoleRequestDto,
} from './dto';
import {
  UserRepository,
  RoleRequestRepository,
  ProfileRequestRepository,
} from '../prisma/repositories';

@Injectable()
export class RoleRequestService {
  constructor(
    private readonly userRepository: UserRepository,
    private readonly roleRequestRepository: RoleRequestRepository,
    private readonly profileRequestRepository: ProfileRequestRepository,
  ) {}

  async createRequest(userId: string, dto: CreateRoleRequestDto) {
    const user = await this.roleRequestRepository.getRequestForCreation(userId);

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const missingFields = this.getMissingProfileFields(user);
    if (missingFields.length > 0) {
      throw new BadRequestException(
        `Profile is incomplete. Missing required fields: ${missingFields.join(', ')}`,
      );
    }

    if (dto.type === 'RESCUER' && !user.rescuerCertificateUrl) {
      throw new BadRequestException('Rescuer certificate is required');
    }

    if (user.role.includes(dto.type)) {
      throw new ConflictException(`User already has role ${dto.type}`);
    }

    const existingPending = await this.roleRequestRepository.findAnyPendingRequest(userId);
    const pendingProfile = await this.profileRequestRepository.findPendingForUser(userId);

    if (existingPending || pendingProfile) {
      throw new ConflictException('Exist pending requests. Please revoke them to update your roles.');
    }

    const authorities = await this.userRepository.findAuthoritiesByWard(
      user.residenceWardCode!,
    );
    const authority = authorities[0];

    if (!authority) {
      throw new NotFoundException(
        'No authority found for your residence ward',
      );
    }

    const request = await this.roleRequestRepository.createRequest({
      profileId: user.profileId,
      checkBy: authority.userId,
      type: dto.type,
      state: 'PENDING',
    });

    return request;
  }
  
  async listForRequester(requesterUserId: string, _dto: ListRoleRequestsDto) {
    const items = await this.roleRequestRepository.listRequestsForRequester(
      requesterUserId,
    );

    return { items };
  }

  async listForAuthority(authorityUserId: string, dto: ListRoleRequestsDto) {
    await this.assertAuthorityUser(authorityUserId);

    const rawLimit = Number(dto.limit ?? 10);
    const limit = Number.isFinite(rawLimit)
      ? Math.min(Math.max(Math.floor(rawLimit), 1), 50)
      : 10;
    const beforeCreatedAt = dto.beforeCreatedAt
      ? new Date(dto.beforeCreatedAt)
      : null;

    const { items, hasMore, nextCursor } =
      await this.roleRequestRepository.listRequestsForAuthority(
        authorityUserId,
        limit,
        beforeCreatedAt ?? undefined,
      );

    return {
      items,
      pagination: {
        hasMore,
        nextCursor,
      },
    };
  }

  private async assertAuthorityUser(authorityUserId: string) {
    const authority = await this.userRepository.getPublicProfile(authorityUserId);

    if (!authority) {
      throw new NotFoundException('Authority account not found');
    }

    if (!authority.role.includes('AUTHORITY')) {
      throw new ForbiddenException('Only authority users can access this resource');
    }
  }

  async approve(
    authorityUserId: string,
    requestId: string,
    dto: RespondRoleRequestDto,
  ) {
    return this.respond(authorityUserId, requestId, 'APPROVED', dto);
  }

  async reject(
    authorityUserId: string,
    requestId: string,
    dto: RespondRoleRequestDto,
  ) {
    return this.respond(authorityUserId, requestId, 'REJECTED', dto);
  }

  async revoke(requesterUserId: string, requestId: string) {
    const existing = await this.roleRequestRepository.getRequestWithUser(requestId);

    if (!existing) {
      throw new NotFoundException('Role request not found');
    }

    if (existing.profile.userId !== requesterUserId) {
      throw new ForbiddenException('You are not allowed to revoke this request');
    }

    if (existing.state !== ('PENDING' as any)) {
      throw new ConflictException('Only pending requests can be revoked');
    }

    return this.roleRequestRepository.updateRequestState(
      requestId,
      'REVOKED',
      existing.note ?? undefined,
    );
  }

  private async respond(
    authorityUserId: string,
    requestId: string,
    nextState: 'APPROVED' | 'REJECTED',
    dto: RespondRoleRequestDto,
  ) {
    const existing = await this.roleRequestRepository.getRequestWithUser(requestId);

    if (!existing) {
      throw new NotFoundException('Role request not found');
    }

    if (existing.checkBy && existing.checkBy !== authorityUserId) {
      throw new ForbiddenException('You are not assigned to this request');
    }

    if (existing.state !== ('PENDING' as any)) {
      throw new ConflictException('Only pending requests can be processed');
    }

    const result = await this.roleRequestRepository.respondRequest(
      authorityUserId,
      requestId,
      nextState,
      dto.note ?? existing.note ?? undefined,
    );

    return result;
  }

  private getMissingProfileFields(user: any): string[] {
    const required: Record<string, any> = {
      fullname: user.fullname,
      dob: user.dob,
      gender: user.gender,
      phoneNumber: user.phoneNumber,
      occupation: user.occupation,
      citizenId: user.citizenId,
      avatarUrl: user.avatarUrl,
      frontCitizenIdCardImageUrl: user.frontCitizenIdCardImageUrl,
      backCitizenIdCardImageUrl: user.backCitizenIdCardImageUrl,
      originProvinceCode: user.originProvinceCode,
      originWardCode: user.originWardCode,
      residenceProvinceCode: user.residenceProvinceCode,
      residenceWardCode: user.residenceWardCode,
      dateOfIssue: user.dateOfIssue,
      dateOfExpire: user.dateOfExpire,
    };

    return Object.entries(required)
      .filter(([, value]) => {
        if (value === null || value === undefined) return true;
        if (typeof value === 'string' && value.trim().length === 0) return true;
        return false;
      })
      .map(([field]) => field);
  }
}
