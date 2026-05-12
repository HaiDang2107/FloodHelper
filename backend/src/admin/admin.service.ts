import {
  Injectable,
  BadRequestException,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { MailerService } from '@nestjs-modules/mailer';

import { AccountState } from '../common/enum/accountState.enum';
import { PasswordGenerator } from '../common/utils/password-generator';
import { formatLocation } from '../common/location-format.util';
import { UpdateUserDto } from '../user/dto/update-user.dto';
import {
  AuthRepository,
  UserRepository,
  ProfileRepository,
} from '../prisma/repositories';
import { CreateAuthorityDto, UpdateAuthorityDto } from './dto';

@Injectable()
export class AdminService {
  constructor(
    private readonly authRepository: AuthRepository,
    private readonly userRepository: UserRepository,
    private readonly profileRepository: ProfileRepository,
    private readonly mailerService: MailerService,
  ) {}

  async getProfile(userId: string) {
    const profile = await this.profileRepository.getCurrentProfileWithRelations(
      userId,
    );

    if (!profile) {
      throw new NotFoundException('User not found');
    }

    return this.formatUserResponse(this.normalizeProfile(profile));
  }

  async updateProfile(userId: string, dto: UpdateUserDto) {
    await this.applyUserUpdates(userId, dto);
    return this.getProfile(userId);
  }

  async searchUserByEmail(email: string) {
    const account = await this.authRepository.findAccountByUsernameLite(email);
    if (!account) {
      throw new NotFoundException('User not found');
    }

    return this.getProfile(account.userId);
  }

  async getUserById(userId: string) {
    return this.getProfile(userId);
  }

  async createAuthority(adminAccountId: string, dto: CreateAuthorityDto) {
    if (!dto.residenceWardCode) {
      throw new BadRequestException('Residence ward is required for authority');
    }

    const existingAccount = await this.authRepository.findAccountByUsername(
      dto.username,
    );
    if (existingAccount) {
      throw new ConflictException('Account already exists');
    }

    await this.assertWardAvailability(dto.residenceWardCode);

    // Auto-generate secure password
    const generatedPassword = PasswordGenerator.generate();
    const hashedPassword = await bcrypt.hash(generatedPassword, 10);

    const user = await this.authRepository.createUserWithAccount({
      role: ['AUTHORITY'],
      profiles: {
        create: {
          fullname: dto.fullname,
          phoneNumber: dto.phoneNumber,
          nickname: dto.nickname,
          gender: dto.gender,
          dob: dto.dob ? new Date(dto.dob) : undefined,
          originProvinceCode: dto.originProvinceCode,
          originWardCode: dto.originWardCode,
          residenceProvinceCode: dto.residenceProvinceCode,
          residenceWardCode: dto.residenceWardCode,
          dateOfIssue: dto.dateOfIssue ? new Date(dto.dateOfIssue) : undefined,
          dateOfExpire: dto.dateOfExpire ? new Date(dto.dateOfExpire) : undefined,
          citizenId: dto.citizenId,
          occupation: dto.occupation,
          isCurrent: true,
        },
      },
      account: {
        create: {
          username: dto.username,
          password: hashedPassword,
          state: AccountState.ACTIVE,
          createdByAccountId: adminAccountId,
        },
      },
    });

    // Send password via email
    try {
      await this.mailerService.sendMail({
        to: dto.username,
        subject: 'Your Authority Account Credentials',
        html: `
          <h2>Welcome to FloodHelper Admin System</h2>
          <p>Your authority account has been created.</p>
          <p><strong>Username:</strong> ${dto.username}</p>
          <p><strong>Password:</strong> ${generatedPassword}</p>
          <p>Please change your password after your first login.</p>
        `,
      });
    } catch (error) {
      console.error('Failed to send authority password email:', error);
      // Continue even if email fails - account is created
    }

    const profile = await this.profileRepository.getCurrentProfileWithRelations(
      user.userId,
    );

    return this.formatUserResponse(this.normalizeProfile(profile));
  }

  async updateAuthority(userId: string, dto: UpdateAuthorityDto) {
    const profile = await this.profileRepository.getCurrentProfileWithRelations(
      userId,
    );

    if (!profile) {
      throw new NotFoundException('User not found');
    }

    const currentRoles: string[] = profile.user?.role ?? [];
    const targetWard = dto.residenceWardCode ?? profile.residenceWardCode;
    const willBeAuthority =
      dto.isAuthority ?? currentRoles.includes('AUTHORITY');

    if (willBeAuthority) {
      if (!targetWard) {
        throw new BadRequestException(
          'Residence ward is required for authority',
        );
      }
      await this.assertWardAvailability(targetWard, userId);
    }

    if (dto.isAuthority != null) {
      const nextRoles = dto.isAuthority
        ? this.ensureRole(currentRoles, 'AUTHORITY')
        : currentRoles.filter((role) => role !== 'AUTHORITY');

      const rolesChanged =
        nextRoles.length !== currentRoles.length ||
        nextRoles.some((role) => !currentRoles.includes(role));

      if (rolesChanged) {
        await this.userRepository.updateUserFields(userId, { role: nextRoles });
      }
    }

    await this.applyUserUpdates(userId, dto);

    return this.getProfile(userId);
  }

  async banAccount(userId: string) {
    const profile = await this.profileRepository.getCurrentProfileWithRelations(userId);
    if (!profile) {
      throw new NotFoundException('User not found');
    }

    const account = await this.authRepository.findAccountByUserId(userId);
    if (!account) {
      throw new NotFoundException('Account not found');
    }

    await this.authRepository.updateAccountState(account.accountId, AccountState.BANNED);

    return this.getProfile(userId);
  }

  async unbanAccount(userId: string) {
    const profile = await this.profileRepository.getCurrentProfileWithRelations(userId);
    if (!profile) {
      throw new NotFoundException('User not found');
    }

    const account = await this.authRepository.findAccountByUserId(userId);
    if (!account) {
      throw new NotFoundException('Account not found');
    }

    await this.authRepository.updateAccountState(account.accountId, AccountState.ACTIVE);

    return this.getProfile(userId);
  }

  private async applyUserUpdates(userId: string, dto: UpdateUserDto) {
    const profileData = {
      fullname: dto.fullname,
      nickname: dto.nickname,
      gender: dto.gender,
      dob: dto.dob ? new Date(dto.dob) : undefined,
      phoneNumber: dto.phoneNumber,
      originProvinceCode: dto.originProvinceCode,
      originWardCode: dto.originWardCode,
      residenceProvinceCode: dto.residenceProvinceCode,
      residenceWardCode: dto.residenceWardCode,
      dateOfIssue: dto.dateOfIssue ? new Date(dto.dateOfIssue) : undefined,
      dateOfExpire: dto.dateOfExpire ? new Date(dto.dateOfExpire) : undefined,
      citizenId: dto.citizenId,
      occupation: dto.occupation,
    } as const;

    const hasProfileChanges = Object.values(profileData).some(
      (value) => value !== undefined,
    );

    if (hasProfileChanges) {
      const profileUpdated =
        await this.profileRepository.updateCurrentProfile(
          userId,
          profileData,
        );

      if (!profileUpdated) {
        throw new NotFoundException('User not found');
      }
    }

    const userData = {
      curLongitude: dto.curLongitude,
      curLatitude: dto.curLatitude,
      visibilityMode: dto.visibilityMode,
      showCharityCampaignLocations: dto.showCharityCampaignLocations,
    } as const;

    if (
      userData.curLongitude != null ||
      userData.curLatitude != null ||
      userData.visibilityMode != null ||
      userData.showCharityCampaignLocations != null
    ) {
      await this.userRepository.updateUserFields(userId, userData);
    }
  }

  private async assertWardAvailability(
    wardCode: number,
    currentUserId?: string,
  ) {
    const authorities = await this.userRepository.findAuthoritiesByWard(
      wardCode,
    );

    const conflict = authorities.find(
      (authority) => authority.userId !== currentUserId,
    );

    if (conflict) {
      throw new ConflictException('This ward already has an authority');
    }
  }

  private ensureRole(roles: string[], role: string) {
    if (roles.includes(role)) {
      return roles;
    }
    return [...roles, role];
  }

  private normalizeProfile(profile: any) {
    return {
      ...profile,
      role: profile.user?.role ?? profile.role ?? [],
      curLongitude: profile.user?.curLongitude ?? profile.curLongitude ?? null,
      curLatitude: profile.user?.curLatitude ?? profile.curLatitude ?? null,
      visibilityMode:
        profile.user?.visibilityMode ?? profile.visibilityMode ?? null,
      showCharityCampaignLocations:
        profile.user?.showCharityCampaignLocations ??
        profile.showCharityCampaignLocations ??
        false,
      account: profile.user?.account ?? profile.account ?? null,
    };
  }

  private formatUserResponse(user: any) {
    return {
      userId: user.userId,
      name: user.fullname,
      displayName: user.nickname,
      fullname: user.fullname,
      nickname: user.nickname,
      gender: user.gender ?? null,
      dob: user.dob ? user.dob.toISOString().split('T')[0] : null,
      placeOfOrigin: formatLocation(user.originWard, user.originProvince),
      placeOfResidence: formatLocation(
        user.residenceWard,
        user.residenceProvince,
      ),
      originProvinceCode: user.originProvinceCode ?? null,
      originProvinceName: user.originProvince?.name ?? null,
      originWardCode: user.originWardCode ?? null,
      originWardName: user.originWard?.name ?? null,
      residenceProvinceCode: user.residenceProvinceCode ?? null,
      residenceProvinceName: user.residenceProvince?.name ?? null,
      residenceWardCode: user.residenceWardCode ?? null,
      residenceWardName: user.residenceWard?.name ?? null,
      dateOfIssue: user.dateOfIssue
        ? user.dateOfIssue.toISOString().split('T')[0]
        : null,
      dateOfExpire: user.dateOfExpire
        ? user.dateOfExpire.toISOString().split('T')[0]
        : null,
      roles: user.user?.role ?? user.role ?? [],
      longitude: user.curLongitude ? Number(user.curLongitude) : null,
      latitude: user.curLatitude ? Number(user.curLatitude) : null,
      visibilityMode: user.visibilityMode,
      showCharityCampaignLocations: Boolean(user.showCharityCampaignLocations),
      avatarUrl: user.avatarUrl,
      citizenId: user.citizenId,
      phoneNumber: user.phoneNumber,
      rescuerCertificateUrl: user.rescuerCertificateUrl ?? null,
      frontCitizenIdCardImageUrl: user.frontCitizenIdCardImageUrl,
      backCitizenIdCardImageUrl: user.backCitizenIdCardImageUrl,
      occupation: user.occupation,
      account: user.account
        ? {
            username: user.account.username,
            state: user.account.state,
            createdAt: user.account.createdAt,
          }
        : null,
    };
  }
}
