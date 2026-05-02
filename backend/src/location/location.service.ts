import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class LocationService {
  constructor(private readonly prisma: PrismaService) {}

  async listProvinces() {
    return this.prisma.province.findMany({
      select: {
        code: true,
        name: true,
        divisionType: true,
        codename: true,
        phoneCode: true,
      },
      orderBy: [{ name: 'asc' }],
    });
  }

  async listWards(provinceCode?: number) {
    const where: Prisma.WardWhereInput = provinceCode
      ? { provinceCode }
      : {};

    return this.prisma.ward.findMany({
      where,
      select: {
        code: true,
        name: true,
        divisionType: true,
        codename: true,
        provinceCode: true,
      },
      orderBy: [{ name: 'asc' }],
    });
  }

  async getProvince(provinceCode: number) {
    const province = await this.prisma.province.findUnique({
      where: { code: provinceCode },
      select: {
        code: true,
        name: true,
        divisionType: true,
        codename: true,
        phoneCode: true,
      },
    });

    if (!province) {
      throw new NotFoundException('Province not found');
    }

    return province;
  }

  async getWard(wardCode: number) {
    const ward = await this.prisma.ward.findUnique({
      where: { code: wardCode },
      select: {
        code: true,
        name: true,
        divisionType: true,
        codename: true,
        provinceCode: true,
      },
    });

    if (!ward) {
      throw new NotFoundException('Ward not found');
    }

    return ward;
  }

  async assertWardExists(wardCode: number) {
    const ward = await this.prisma.ward.findUnique({
      where: { code: wardCode },
      select: {
        code: true,
        provinceCode: true,
      },
    });

    if (!ward) {
      throw new BadRequestException('Ward does not exist');
    }

    return ward;
  }
}