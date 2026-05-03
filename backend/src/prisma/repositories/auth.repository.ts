import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { BaseRepository } from './base.repository';

const ACCOUNT_USER_PROFILE_SELECT = {
  userId: true,
  fullname: true,
  nickname: true,
  phoneNumber: true,
  avatarUrl: true,
  gender: true,
  dob: true,
  originProvinceCode: true,
  originWardCode: true,
  residenceProvinceCode: true,
  residenceWardCode: true,
  originProvince: {
    select: { code: true, name: true },
  },
  originWard: {
    select: { code: true, name: true },
  },
  residenceProvince: {
    select: { code: true, name: true },
  },
  residenceWard: {
    select: { code: true, name: true },
  },
  dateOfIssue: true,
  dateOfExpire: true,
  citizenId: true,
  citizenIdCardImg: true,
  jobPosition: true,
  showCharityCampaignLocations: true,
  role: true,
} as const;

@Injectable()
export class AuthRepository extends BaseRepository<any> {
  constructor(private readonly prisma: PrismaService) {
    super('Auth');
  }

  async findAccountByUsername(username: string) {
    return this.prisma.account.findUnique({ where: { username } });
  }

  async findAccountByUsernameWithDetailedUser(username: string) {
    return this.prisma.account.findUnique({
      where: { username },
      include: {
        user: {
          select: ACCOUNT_USER_PROFILE_SELECT,
        },
      },
    });
  }

  async findAccountByIdWithUser(accountId: string) {
    return this.prisma.account.findUnique({
      where: { accountId },
      include: { user: true },
    });
  }

  async findAccountByEmailOrProviderId(email: string, providerId: string) {
    return this.prisma.account.findFirst({
      where: {
        OR: [{ username: email }, { providerId }],
      },
      include: { user: true },
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
