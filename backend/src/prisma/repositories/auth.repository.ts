import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { BaseRepository } from './base.repository';

@Injectable()
export class AuthRepository extends BaseRepository<any> {
  constructor(private readonly prisma: PrismaService) {
    super('Auth');
  }

  async findAccountByUsername(username: string) {
    return this.prisma.account.findUnique({ where: { username } });
  }

  async findAccountByUsernameWithDetailedUser(username: string) {
    const account = await this.prisma.account.findUnique({
      where: { username },
      include: {
        user: {
          select: {
            userId: true,
            role: true,
            curLongitude: true,
            curLatitude: true,
            visibilityMode: true,
            showCharityCampaignLocations: true,
            fcmToken: true,
            profiles: {
              where: { isCurrent: true },
              include: {
                originProvince: {
                  select: { code: true, name: true }
                },
                originWard: {
                  select: { code: true, name: true }
                },
                residenceProvince: {
                  select: { code: true, name: true }
                },
                residenceWard: {
                  select: { code: true, name: true }
                }
              }
            }
          }
        },
      },
    });

    if (!account || !account.user || !account.user.profiles || account.user.profiles.length === 0) {
      return null;
    }

    const profile = account.user.profiles[0];

    // Flatten profile data for backward compatibility
    return {
      ...account,
      user: {
        ...account.user,
        fullname: profile.fullname,
        nickname: profile.nickname || profile.fullname,
        phoneNumber: profile.phoneNumber,
        avatarUrl: profile.avatarUrl,
        gender: profile.gender,
        dob: profile.dob,
        originProvinceCode: profile.originProvinceCode,
        originWardCode: profile.originWardCode,
        residenceProvinceCode: profile.residenceProvinceCode,
        residenceWardCode: profile.residenceWardCode,
        originProvince: profile.originProvince,
        originWard: profile.originWard,
        residenceProvince: profile.residenceProvince,
        residenceWard: profile.residenceWard,
        dateOfIssue: profile.dateOfIssue,
        dateOfExpire: profile.dateOfExpire,


        citizenId: profile.citizenId ?? null,
        citizenIdCardImg: (profile as any).citizenIdCardImg ?? null,
        occupation: (profile as any).occupation ?? null,
      }
    };
  }



  async findAccountByIdWithUser(accountId: string) {
    return this.prisma.account.findUnique({
      where: { accountId },
      include: {
        user: {
          include: {
            profiles: {
              where: { isCurrent: true },
            },
          },
        },
      },
    });
  }

  async findAccountByEmailOrProviderId(email: string, providerId: string) {
    return this.prisma.account.findFirst({
      where: {
        OR: [{ username: email }, { providerId }],
      },
      include: {
        user: {
          include: {
            profiles: {
              where: { isCurrent: true },
            },
          },
        },
      },
    });
  }

  async createUserWithAccount(data: any) {
    return this.prisma.user.create({
      data,
      include: {
        account: true,
      },
    });
  }

  async activateAccount(accountId: string) {
    return this.prisma.account.update({
      where: { accountId },
      data: { state: 'ACTIVE' as any },
    });
  }

  async updateAccountPassword(accountId: string, password: string) {
    return this.prisma.account.update({
      where: { accountId },
      data: { password },
    });
  }

  async upsertSession(data: {
    accountId: string;
    deviceId: string;
    refreshToken: string;
    expireAt: Date;
    role: string;
  }) {
    return this.prisma.session.upsert({
      where: {
        accountId_deviceId: {
          accountId: data.accountId,
          deviceId: data.deviceId,
        },
      },
      update: {
        refreshToken: data.refreshToken,
        expireAt: data.expireAt,
        role: data.role,
      },
      create: {
        accountId: data.accountId,
        deviceId: data.deviceId,
        refreshToken: data.refreshToken,
        expireAt: data.expireAt,
        role: data.role,
      },
    });
  }

  async deleteSessionsByAccount(accountId: string) {
    return this.prisma.session.deleteMany({
      where: { accountId },
    });
  }

  async deleteSessionByAccountAndDevice(accountId: string, deviceId: string) {
    return this.prisma.session.deleteMany({
      where: { accountId, deviceId },
    });
  }

  async findSessionForRefresh(accountId: string, deviceId: string) {
    return this.prisma.session.findFirst({
      where: {
        accountId,
        deviceId,
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
  }

  async findById(id: string) {
    return this.findAccountByIdWithUser(id);
  }

  async findAll() {
    return this.prisma.account.findMany();
  }

  async create(data: any) {
    return this.prisma.account.create({ data });
  }

  async update(id: string, data: any) {
    return this.prisma.account.update({ where: { accountId: id }, data });
  }

  async delete(id: string) {
    return this.prisma.account.delete({ where: { accountId: id } });
  }

  async count() {
    return this.prisma.account.count();
  }
}

