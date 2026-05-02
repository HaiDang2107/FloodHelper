import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import {
  CreateFinancialSupportDto,
  CreateSupplyDto,
  UpdateFinancialSupportDto,
  UpdateSupplyDto,
} from './dto';

@Injectable()
export class NoruserBenefAllocationService {
  constructor(private readonly prisma: PrismaService) {}

  async listSupplies(campaignId: string) {
    const supplies = await this.prisma.supply.findMany({
      where: { campaignId },
      orderBy: { boughtAt: 'desc' },
    });

    return supplies.map((item) => ({
      supplyId: item.supplyId,
      supplyName: item.supplyName,
      quantity: item.quantity,
      unitPrice: Number(item.unitPrice),
      price: Number(item.price),
      boughtAt: item.boughtAt,
    }));
  }

  async createSupply(userId: string, campaignId: string, payload: CreateSupplyDto) {
    await this.assertCampaignEditableByOwner(userId, campaignId);

    const supply = await this.prisma.supply.create({
      data: {
        campaignId,
        supplyName: payload.supplyName.trim(),
        quantity: payload.quantity,
        unitPrice: payload.unitPrice,
        price: payload.quantity * payload.unitPrice,
        boughtAt: payload.boughtAt ? new Date(payload.boughtAt) : new Date(),
      },
    });

    return {
      supplyId: supply.supplyId,
      supplyName: supply.supplyName,
      quantity: supply.quantity,
      unitPrice: Number(supply.unitPrice),
      price: Number(supply.price),
      boughtAt: supply.boughtAt,
    };
  }

  async updateSupply(
    userId: string,
    campaignId: string,
    supplyId: string,
    payload: UpdateSupplyDto,
  ) {
    await this.assertCampaignEditableByOwner(userId, campaignId);

    const current = await this.prisma.supply.findFirst({
      where: { supplyId, campaignId },
    });
    if (!current) {
      throw new NotFoundException('Supply not found');
    }

    const nextQuantity = payload.quantity ?? current.quantity;
    const nextUnitPrice = payload.unitPrice ?? Number(current.unitPrice);

    const updated = await this.prisma.supply.update({
      where: { supplyId },
      data: {
        supplyName: payload.supplyName?.trim() ?? current.supplyName,
        quantity: nextQuantity,
        unitPrice: nextUnitPrice,
        price: nextQuantity * nextUnitPrice,
        boughtAt: payload.boughtAt ? new Date(payload.boughtAt) : current.boughtAt,
      },
    });

    return {
      supplyId: updated.supplyId,
      supplyName: updated.supplyName,
      quantity: updated.quantity,
      unitPrice: Number(updated.unitPrice),
      price: Number(updated.price),
      boughtAt: updated.boughtAt,
    };
  }

  async deleteSupply(userId: string, campaignId: string, supplyId: string) {
    await this.assertCampaignEditableByOwner(userId, campaignId);

    const deleted = await this.prisma.supply.deleteMany({
      where: { supplyId, campaignId },
    });

    if (deleted.count === 0) {
      throw new NotFoundException('Supply not found');
    }

    return { supplyId };
  }

  async listFinancialSupports(campaignId: string) {
    const supports = await this.prisma.financialSupport.findMany({
      where: { campaignId },
      orderBy: { allocatedAt: 'desc' },
    });

    return supports.map((item) => ({
      financialSupportId: item.financialSupportId,
      householdName: item.householdName,
      amount: Number(item.amount),
      allocatedAt: item.allocatedAt,
    }));
  }

  async createFinancialSupport(
    userId: string,
    campaignId: string,
    payload: CreateFinancialSupportDto,
  ) {
    await this.assertCampaignEditableByOwner(userId, campaignId);

    const support = await this.prisma.financialSupport.create({
      data: {
        campaignId,
        householdName: payload.householdName.trim(),
        amount: payload.amount,
        allocatedAt: payload.allocatedAt ? new Date(payload.allocatedAt) : new Date(),
      },
    });

    return {
      financialSupportId: support.financialSupportId,
      householdName: support.householdName,
      amount: Number(support.amount),
      allocatedAt: support.allocatedAt,
    };
  }

  async updateFinancialSupport(
    userId: string,
    campaignId: string,
    financialSupportId: string,
    payload: UpdateFinancialSupportDto,
  ) {
    await this.assertCampaignEditableByOwner(userId, campaignId);

    const current = await this.prisma.financialSupport.findFirst({
      where: { financialSupportId, campaignId },
    });
    if (!current) {
      throw new NotFoundException('Financial support not found');
    }

    const updated = await this.prisma.financialSupport.update({
      where: { financialSupportId },
      data: {
        householdName: payload.householdName?.trim() ?? current.householdName,
        amount: payload.amount ?? Number(current.amount),
        allocatedAt: payload.allocatedAt
          ? new Date(payload.allocatedAt)
          : current.allocatedAt,
      },
    });

    return {
      financialSupportId: updated.financialSupportId,
      householdName: updated.householdName,
      amount: Number(updated.amount),
      allocatedAt: updated.allocatedAt,
    };
  }

  async deleteFinancialSupport(
    userId: string,
    campaignId: string,
    financialSupportId: string,
  ) {
    await this.assertCampaignEditableByOwner(userId, campaignId);

    const deleted = await this.prisma.financialSupport.deleteMany({
      where: { financialSupportId, campaignId },
    });

    if (deleted.count === 0) {
      throw new NotFoundException('Financial support not found');
    }

    return { financialSupportId };
  }

  private async assertCampaignEditableByOwner(userId: string, campaignId: string) { // Đây đơn giản là guard bảo vệ service
    const campaign = await this.prisma.charityCampaign.findUnique({
      where: { campaignId },
      select: {
        campaignId: true,
        organizedBy: true,
        state: true,
      },
    });

    if (!campaign) {
      throw new NotFoundException('Charity campaign not found');
    }

    if (campaign.organizedBy !== userId) {
      throw new ForbiddenException('You are not allowed to modify this campaign allocation');
    }

    const state = String(campaign.state).toUpperCase();
    if (state !== 'DISTRIBUTING' && state !== 'FINISHED') {
      throw new BadRequestException(
        'Allocation can only be modified when campaign is DISTRIBUTING or FINISHED',
      );
    }
  }
}