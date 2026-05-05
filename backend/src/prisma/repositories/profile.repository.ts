import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { BaseRepository } from './base.repository';

import { Profile, Prisma } from '@prisma/client';

@Injectable()
export class ProfileRepository extends BaseRepository<Profile> {

  constructor(private readonly prisma: PrismaService) {
    super('Profile');
  }

  async findById(id: string) {
    return this.getCurrentProfileWithRelations(id);
  }

  async findAll() {
    return this.prisma.profile.findMany({ where: { isCurrent: true } });
  }

  async create(data: Prisma.ProfileCreateInput) {

    return this.prisma.profile.create({ data });
  }

  async update(id: string, data: any) {

    const current = await this.getCurrentProfile(id);
    if (!current) throw new Error(`Profile not found: ${id}`);
    return this.prisma.profile.update({
      where: { profileId: current.profileId },
      data,
    });
  }

  async delete(id: string) {
    return this.prisma.profile.delete({ where: { profileId: id } });
  }

  async count() {
    return this.prisma.profile.count({ where: { isCurrent: true } });
  }

  // lấy ra hồ sơ (profile) hiện tại của một người dùng kèm theo toàn bộ thông tin chi tiết liên quan
  async getCurrentProfileWithRelations(userId: string) {
    return this.prisma.profile.findFirst({
      where: { userId, isCurrent: true },
      include: {
        originProvince: true,
        originWard: true,
        residenceProvince: true,
        residenceWard: true,
        user: {
          select: {
            userId: true,
            role: true,
            curLongitude: true,
            curLatitude: true,
            visibilityMode: true,
            showCharityCampaignLocations: true,
            account: {
              select: {
                username: true,
                state: true,
                createdAt: true,
              },
            },
          },
        },
      },
    });
  }

  async getCurrentProfile(userId: string) {
    return this.prisma.profile.findFirst({
      where: { userId, isCurrent: true },
    });
  }

  async updateCurrentProfile(userId: string, data: Prisma.ProfileUpdateInput) {
    const current = await this.prisma.profile.findFirst({
      where: { userId, isCurrent: true },
      select: { profileId: true },
    });

    if (!current) {
      return null;
    }

    return this.prisma.profile.update({
      where: { profileId: current.profileId },
      data,
      include: {
        originProvince: true,
        originWard: true,
        residenceProvince: true,
        residenceWard: true,
        user: {
          select: {
            userId: true,
            role: true,
            curLongitude: true,
            curLatitude: true,
            visibilityMode: true,
            showCharityCampaignLocations: true,
            account: {
              select: {
                username: true,
                state: true,
                createdAt: true,
              },
            },
          },
        },
      },
    });
  }

  async createProfile(data: Prisma.ProfileUncheckedCreateInput) {
    return this.prisma.profile.create({
      data,
    });
  }

  async findCurrentProfileSummary(userId: string) {
    return this.prisma.profile.findFirst({
      where: { userId, isCurrent: true },
      select: {
        profileId: true,
        userId: true,
        fullname: true,
        nickname: true,
        dob: true,
        gender: true,
        phoneNumber: true,
        occupation: true,
        citizenId: true,
        avatarUrl: true,
        frontCitizenIdCardImageUrl: true,
        backCitizenIdCardImageUrl: true,
        rescuerCertificateUrl: true,
        originProvinceCode: true,
        originWardCode: true,
        residenceProvinceCode: true,
        residenceWardCode: true,
        dateOfIssue: true,
        dateOfExpire: true,
        originProvince: { select: { code: true, name: true } },
        originWard: { select: { code: true, name: true } },
        residenceProvince: { select: { code: true, name: true } },
        residenceWard: { select: { code: true, name: true } },
        user: {
          select: {
            role: true,
            visibilityMode: true,
            curLongitude: true,
            curLatitude: true,
          },
        },
      },
    });
  }
}
