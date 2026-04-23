import { Controller, Get, Param, ParseIntPipe, Query } from '@nestjs/common';
import { LocationService } from './location.service';

@Controller('locations')
export class LocationController {
  constructor(private readonly locationService: LocationService) {}

  @Get('provinces')
  async listProvinces() {
    const data = await this.locationService.listProvinces();

    return {
      success: true,
      message: 'Provinces retrieved successfully',
      data,
    };
  }

  @Get('provinces/:provinceCode/wards')
  async listWards(@Param('provinceCode', ParseIntPipe) provinceCode: number) {
    const data = await this.locationService.listWards(provinceCode);

    return {
      success: true,
      message: 'Wards retrieved successfully',
      data,
    };
  }

  @Get('wards')
  async listAllWards(@Query('provinceCode') provinceCode?: string) {
    const parsedProvinceCode = provinceCode ? Number(provinceCode) : undefined;
    const data = await this.locationService.listWards(parsedProvinceCode);

    return {
      success: true,
      message: 'Wards retrieved successfully',
      data,
    };
  }

  @Get('provinces/:provinceCode')
  async getProvince(@Param('provinceCode', ParseIntPipe) provinceCode: number) {
    const data = await this.locationService.getProvince(provinceCode);

    return {
      success: true,
      message: 'Province retrieved successfully',
      data,
    };
  }

  @Get('wards/:wardCode')
  async getWard(@Param('wardCode', ParseIntPipe) wardCode: number) {
    const data = await this.locationService.getWard(wardCode);

    return {
      success: true,
      message: 'Ward retrieved successfully',
      data,
    };
  }
}