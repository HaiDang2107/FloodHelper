import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma.service';
import { BaseRepository } from './base.repository';

@Injectable()
export class LocationRepository extends BaseRepository<any> {
  constructor(private readonly prisma: PrismaService) {
    super('Location');
  }

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

  async listWards(where: Prisma.WardWhereInput) {
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
    return this.prisma.province.findUnique({
      where: { code: provinceCode },
      select: {
        code: true,
        name: true,
        divisionType: true,
        codename: true,
        phoneCode: true,
      },
    });
  }

  async getWard(wardCode: number) {
    return this.prisma.ward.findUnique({
      where: { code: wardCode },
      select: {
        code: true,
        name: true,
        divisionType: true,
        codename: true,
        provinceCode: true,
      },
    });
  }

  async getWardBasic(wardCode: number) {
    return this.prisma.ward.findUnique({
      where: { code: wardCode },
      select: {
        code: true,
        provinceCode: true,
      },
    });
  }

  async findById(id: string) {
    return this.getWard(Number(id));
  }

  async findAll() {
    return this.listProvinces();
  }

  async create(data: any) {
    throw new Error('Location entities are read-only');
  }

  async update(id: string, data: any) {
    throw new Error('Location entities are read-only');
  }

  async delete(id: string) {
    throw new Error('Location entities are read-only');
  }

  async count() {
    return this.prisma.ward.count();
  }
}
