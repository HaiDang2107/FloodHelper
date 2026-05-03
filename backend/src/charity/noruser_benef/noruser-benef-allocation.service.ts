import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { CharityRepository } from '../../prisma/repositories';
import {
  CreateFinancialSupportDto,
  CreateSupplyDto,
  UpdateFinancialSupportDto,
  UpdateSupplyDto,
} from './dto';

@Injectable()
export class NoruserBenefAllocationService {
  constructor(private readonly charityRepository: CharityRepository) {}

  async listSupplies(campaignId: string) {
    const supplies = await this.charityRepository.getCampaignSupplies(campaignId);

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

    const supply = await this.charityRepository.createSupply(campaignId, payload);

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

    const current = await this.charityRepository.findSupply(supplyId, campaignId);
    if (!current) {
      throw new NotFoundException('Supply not found');
    }

    const nextQuantity = payload.quantity ?? current.quantity;
    const nextUnitPrice = payload.unitPrice ?? Number(current.unitPrice);

    const updated = await this.charityRepository.updateSupply(supplyId, campaignId, {
      supplyName: payload.supplyName?.trim() ?? current.supplyName,
      quantity: nextQuantity,
      unitPrice: nextUnitPrice,
      price: nextQuantity * nextUnitPrice,
      boughtAt: payload.boughtAt ? new Date(payload.boughtAt) : current.boughtAt,
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

    const deleted = await this.charityRepository.deleteSupply(supplyId, campaignId);

    if (deleted.count === 0) {
      throw new NotFoundException('Supply not found');
    }

    return { supplyId };
  }

  async listFinancialSupports(campaignId: string) {
    const supports = await this.charityRepository.listFinancialSupports(campaignId);

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

    const support = await this.charityRepository.createFinancialSupport(campaignId, payload);

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

    const current = await this.charityRepository.findFinancialSupport(financialSupportId, campaignId);
    if (!current) {
      throw new NotFoundException('Financial support not found');
    }

    const updated = await this.charityRepository.updateFinancialSupport(
      financialSupportId,
      campaignId,
      {
        householdName: payload.householdName?.trim() ?? current.householdName,
        amount: payload.amount ?? Number(current.amount),
        allocatedAt: payload.allocatedAt
          ? new Date(payload.allocatedAt)
          : current.allocatedAt,
      },
    );

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

    const deleted = await this.charityRepository.deleteFinancialSupport(financialSupportId, campaignId);

    if (deleted.count === 0) {
      throw new NotFoundException('Financial support not found');
    }

    return { financialSupportId };
  }

  private async assertCampaignEditableByOwner(userId: string, campaignId: string) { // Đây đơn giản là guard bảo vệ service
    const campaign = await this.charityRepository.getCampaignOwnership(campaignId);

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