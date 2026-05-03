import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { LocationRepository } from '../prisma/repositories';

@Injectable()
export class LocationService {
  constructor(private readonly locationRepository: LocationRepository) {}

  async listProvinces() {
    return this.locationRepository.listProvinces();
  }

  async listWards(provinceCode?: number) {
    const where: Prisma.WardWhereInput = provinceCode
      ? { provinceCode }
      : {};

    return this.locationRepository.listWards(where);
  }

  async getProvince(provinceCode: number) {
    const province = await this.locationRepository.getProvince(provinceCode);

    if (!province) {
      throw new NotFoundException('Province not found');
    }

    return province;
  }

  async getWard(wardCode: number) {
    const ward = await this.locationRepository.getWard(wardCode);

    if (!ward) {
      throw new NotFoundException('Ward not found');
    }

    return ward;
  }

  async assertWardExists(wardCode: number) {
    const ward = await this.locationRepository.getWardBasic(wardCode);

    if (!ward) {
      throw new BadRequestException('Ward does not exist');
    }

    return ward;
  }
}