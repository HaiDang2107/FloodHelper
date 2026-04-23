import { Injectable } from '@nestjs/common';
import {
  BadRequestException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { CampaignState, Prisma, TransactionState } from '@prisma/client';
import {
  CreateCampaignDto,
  QueryCampaignTransactionsDto,
  UpdateCampaignLocationDto,
  UpdateCampaignDto,
} from './dto';
import { CommonCharityService } from '../common.service';
import { VietQrInternalService } from '../vietqr/vietqr-internal.service';
import { VietQrService } from '../vietqr/vietqr.service';
import { PrismaService } from '../../prisma/prisma.service';
import { formatLocation } from '../../common/location-format.util';

type ResolvedBank = {
  id: number;
  name: string;
  code: string;
  shortName: string;
};

type CharityCampaignListItemPayload = {
  campaignId: string;
  campaignName: string;
  state: CampaignState;
  createdAt: Date;
  requestedAt: Date | null;
  respondedAt: Date | null;
  organizer?: {
    userId: string;
    fullname: string;
    nickname: string | null;
    residenceProvinceCode: number | null;
    residenceWardCode: number | null;
    residenceProvince?: { code: number; name: string } | null;
    residenceWard?: { code: number; name: string } | null;
  } | null;
};

@Injectable()
export class NoruserBenefCharityService {
  private readonly allowedStates = new Set<CampaignState>([
    'CREATED',
    'PENDING',
    'APPROVED',
    'REJECTED',
    'DONATING',
    'DISTRIBUTING',
    'SUSPENDED',
    'FINISHED',
  ]);

  private static readonly ALLOWED_TRANSACTION_STATES = new Set<TransactionState>([
    'CREATED',
    'VERIFYING',
    'SUCCESS',
    'FAILED',
    'EXPIRED',
  ]);

  constructor(
    private readonly prisma: PrismaService,
    private readonly commonCharityService: CommonCharityService,
    private readonly vietQrService: VietQrService,
    private readonly vietQrInternalService: VietQrInternalService,
  ) {}

  async listExistingCampaignsByState(state: string) {
    const normalizedState = this.normalizeAndValidateState(state);
    if (normalizedState === 'CREATED') {
      return [];
    }

    const campaigns = await this.prisma.charityCampaign.findMany({
      where: {
        state: normalizedState,
      },
      select: {
        campaignId: true,
        campaignName: true,
        state: true,
        createdAt: true,
        requestedAt: true,
        respondedAt: true,
        organizer: {
          select: {
            userId: true,
            fullname: true,
            nickname: true,
            residenceProvinceCode: true,
            residenceWardCode: true,
            residenceProvince: {
              select: { code: true, name: true },
            },
            residenceWard: {
              select: { code: true, name: true },
            },
          },
        },
      },
      orderBy: this.getOrderByForState(normalizedState),
    });

    return campaigns.map((campaign) => this.mapCampaignListItem(campaign));
  }

  async listMyCampaignsByState(userId: string, state: string) {
    const normalizedState = this.normalizeAndValidateState(state);

    const campaigns = await this.prisma.charityCampaign.findMany({
      where: {
        organizedBy: userId,
        state: normalizedState,
      },
      select: {
        campaignId: true,
        campaignName: true,
        state: true,
        createdAt: true,
        requestedAt: true,
        respondedAt: true,
        organizer: {
          select: {
            userId: true,
            fullname: true,
            nickname: true,
            residenceProvinceCode: true,
            residenceWardCode: true,
            residenceProvince: {
              select: { code: true, name: true },
            },
            residenceWard: {
              select: { code: true, name: true },
            },
          },
        },
      },
      orderBy: this.getOrderByForState(normalizedState),
    });

    return campaigns.map((campaign) => this.mapCampaignListItem(campaign));
  }

  getCampaignDetail(campaignId: string) {
    return this.commonCharityService.getCampaignDetail(campaignId);
  }

  listBanks() {
    return this.commonCharityService.listBanks();
  }

  async listDistributingCampaignLocations() { // Lấy vị trí của các distributing campaign 
    const campaigns = await this.prisma.charityCampaign.findMany({
      where: {
        state: 'DISTRIBUTING',
        campaignLatitude: { not: null },
        campaignLongitude: { not: null },
      },
      select: {
        campaignId: true,
        campaignName: true,
        destinationProvinceCode: true,
        destinationWardCode: true,
        destinationDetail: true,
        campaignLatitude: true,
        campaignLongitude: true,
      },
      orderBy: [{ startedDistributionAt: 'desc' }, { createdAt: 'desc' }],
    });

    return campaigns.map((campaign) => ({
      campaignId: campaign.campaignId,
      campaignName: campaign.campaignName,
      destination: campaign.destinationDetail,
      latitude: Number(campaign.campaignLatitude),
      longitude: Number(campaign.campaignLongitude),
    }));
  }

  async listCampaignTransactions(
    campaignId: string,
    query: QueryCampaignTransactionsDto,
  ) {
    const normalizedState = (query.state ?? 'SUCCESS').trim().toUpperCase() as TransactionState;
    if (!NoruserBenefCharityService.ALLOWED_TRANSACTION_STATES.has(normalizedState)) {
      throw new BadRequestException(
        'Invalid transaction state. Allowed values: CREATED, VERIFYING, SUCCESS, FAILED, EXPIRED',
      );
    }

    const campaign = await this.prisma.charityCampaign.findUnique({
      where: { campaignId },
      select: { campaignId: true },
    });

    if (!campaign) {
      throw new NotFoundException('Charity campaign not found');
    }

    const transactions = await this.prisma.transaction.findMany({
      where: {
        campaignId,
        state: normalizedState as TransactionState,
      },
      orderBy: {
        donateAt: 'desc',
      },
    });

    const donorIds = Array.from(
      new Set(
        transactions
          .map((transaction) => transaction.donatedBy)
          .filter((value): value is string =>
            Boolean(value && value.trim().length > 0),
          ),
      ),
    );

    const donors = donorIds.length
      ? await this.prisma.user.findMany({
          where: {
            userId: {
              in: donorIds,
            },
          },
          select: {
            userId: true,
            fullname: true,
            nickname: true,
          },
        })
      : [];

    const donorNameById = new Map(
      donors.map((donor) => [donor.userId, donor.fullname]),
    );

    return transactions.map((transaction) => ({
      transactionId: transaction.transactionId,
      state: String(transaction.state).toUpperCase(),
      amount: transaction.amount,
      donorName:
        (transaction.donatedBy
          ? donorNameById.get(transaction.donatedBy)
          : undefined) || 'Anonymous',
      date: transaction.transactionTime ?? transaction.donateAt,
      message: transaction.content,
    }));
  }

  async createCampaign(userId: string, payload: CreateCampaignDto) {
    const timeline = this.parseAndValidateTimeline(payload);
    const bankAccountId = await this.resolveOrCreateBankAccountId(
      this.prisma,
      payload,
    );

    const created = await this.prisma.charityCampaign.create({
      data: {
        organizedBy: userId,
        bankAccountId,
        campaignName: payload.campaignName.trim(),
        purpose: payload.purpose.trim(),
          destinationProvinceCode: payload.destinationProvinceCode ?? null,
          destinationWardCode: payload.destinationWardCode ?? null,
          destinationDetail:
            payload.destinationDetail?.trim() || payload.destination?.trim() || null,
        charityObject: payload.charityObject.trim(),
        state: 'CREATED',
        startedDonationAt: timeline.startedDonationAt,
        finishedDonationAt: timeline.finishedDonationAt,
        startedDistributionAt: timeline.startedDistributionAt,
        finishedDistributionAt: timeline.finishedDistributionAt,
        bankStatementFileUrl: payload.bankStatementFileUrl?.trim() || null,
      },
      select: { campaignId: true },
    });

    return this.commonCharityService.getCampaignDetail(created.campaignId);
  }

  async updateCampaign(
    userId: string,
    campaignId: string,
    payload: UpdateCampaignDto,
  ) {
    const campaign = await this.prisma.charityCampaign.findUnique({
      where: { campaignId },
    });

    if (!campaign) {
      throw new NotFoundException('Charity campaign not found');
    }
    if (campaign.organizedBy !== userId) {
      throw new ForbiddenException('You are not allowed to update this campaign');
    }
    if (String(campaign.state).toUpperCase() !== 'CREATED') {
      throw new BadRequestException('Only CREATED campaigns can be updated');
    }

    const timeline = this.parseAndValidateTimeline(payload);
    const bankAccountId = await this.resolveOrCreateBankAccountId(
      this.prisma,
      payload,
    );

    await this.prisma.charityCampaign.update({
      where: { campaignId },
      data: {
        bankAccountId,
        campaignName: payload.campaignName.trim(),
        purpose: payload.purpose.trim(),
          destinationProvinceCode: payload.destinationProvinceCode ?? null,
          destinationWardCode: payload.destinationWardCode ?? null,
          destinationDetail:
            payload.destinationDetail?.trim() || payload.destination?.trim() || null,
        charityObject: payload.charityObject.trim(),
        startedDonationAt: timeline.startedDonationAt,
        finishedDonationAt: timeline.finishedDonationAt,
        startedDistributionAt: timeline.startedDistributionAt,
        finishedDistributionAt: timeline.finishedDistributionAt,
        bankStatementFileUrl: payload.bankStatementFileUrl?.trim() || null,
      },
    });

    return this.commonCharityService.getCampaignDetail(campaignId);
  }

  async updateCampaignLocation(
    userId: string,
    campaignId: string,
    payload: UpdateCampaignLocationDto,
  ) { // Update vị trí của campaign
    const campaign = await this.prisma.charityCampaign.findUnique({
      where: { campaignId },
      select: {
        campaignId: true,
        organizedBy: true,
        state: true,
          destinationDetail: true,
      },
    });

    if (!campaign) {
      throw new NotFoundException('Charity campaign not found');
    }
    if (campaign.organizedBy !== userId) {
      throw new ForbiddenException(
        'You are not allowed to check in this campaign location',
      );
    }

    const state = String(campaign.state).toUpperCase();
    if (state !== 'DISTRIBUTING') {
      throw new BadRequestException(
        'Campaign location can only be checked in when campaign is DISTRIBUTING',
      );
    }

    const updated = await this.prisma.charityCampaign.update({
      where: { campaignId },
      data: {
        campaignLatitude: payload.latitude,
        campaignLongitude: payload.longitude,
      },
      select: {
        campaignId: true,
          destinationDetail: true,
        campaignLatitude: true,
        campaignLongitude: true,
      },
    });

    return {
      campaignId: updated.campaignId,
        destination: updated.destinationDetail,
      latitude: Number(updated.campaignLatitude),
      longitude: Number(updated.campaignLongitude),
    };
  }

  async sendCampaignRequest(userId: string, campaignId: string) {
    const campaign = await this.prisma.charityCampaign.findUnique({
      where: { campaignId },
      select: {
        organizedBy: true,
        state: true,
        bankAccountId: true,
        startedDonationAt: true,
        finishedDonationAt: true,
        startedDistributionAt: true,
        finishedDistributionAt: true,
        organizer: {
          select: {
              residenceWardCode: true,
          },
        },
      },
    });

    if (!campaign) {
      throw new NotFoundException('Charity campaign not found');
    }
    if (campaign.organizedBy !== userId) {
      throw new ForbiddenException('You are not allowed to send this campaign');
    }
    if (String(campaign.state).toUpperCase() !== 'CREATED') {
      throw new BadRequestException('Only CREATED campaigns can be submitted');
    }
    if (!campaign.bankAccountId) {
      throw new BadRequestException('Campaign bank account is required');
    }
      if (!campaign.organizer?.residenceWardCode) {
      throw new BadRequestException(
          'Benefactor residence ward is required before sending campaign request',
      );
    }

    const assignedAuthority = await this.prisma.user.findFirst({
      where: {
          residenceWardCode: campaign.organizer.residenceWardCode,
        role: { has: 'AUTHORITY' },
      },
      select: {
        userId: true,
      },
    });

    if (!assignedAuthority) {
      throw new BadRequestException(
        'No authority account found for benefactor residence area',
      );
    }

    this.validateTimelineValues(
      campaign.startedDonationAt,
      campaign.finishedDonationAt,
      campaign.startedDistributionAt,
      campaign.finishedDistributionAt,
    );

    await this.prisma.charityCampaign.update({
      where: { campaignId },
      data: {
        state: 'PENDING',
        requestedAt: new Date(),
        checkedBy: assignedAuthority.userId,
      },
    });

    return this.commonCharityService.getCampaignDetail(campaignId);
  }

  createDonationQr(campaignId: string, amountInput: string, donorUserId: string) {
    return this.vietQrService.createDonationQr(
      campaignId,
      amountInput,
      donorUserId,
    );
  }

  triggerTestCallback(transactionId: string, requesterUserId: string) {
    return this.vietQrService.triggerTestCallback(
      transactionId,
      requesterUserId,
    );
  }

  createDonationQrInternal(
    campaignId: string,
    amountInput: string,
    donorUserId: string,
  ) {
    return this.vietQrInternalService.createDonationQrInternal(
      campaignId,
      amountInput,
      donorUserId,
    );
  }

  triggerTestCallbackInternal(transactionId: string, requesterUserId: string) {
    return this.vietQrInternalService.triggerTestCallbackInternal(
      transactionId,
      requesterUserId,
    );
  }

  private normalizeAndValidateState(state: string): CampaignState {
    if (!state) {
      throw new BadRequestException('state is required');
    }

    const normalized = state.trim().toUpperCase();
    const mapped: CampaignState =
      normalized === 'ACCEPTED' ? 'APPROVED' : (normalized as CampaignState);

    if (!this.allowedStates.has(mapped)) {
      throw new BadRequestException(
        'Invalid state. Allowed values: CREATED, PENDING, APPROVED, REJECTED, DONATING, DISTRIBUTING, SUSPENDED, FINISHED',
      );
    }

    return mapped as CampaignState;
  }

  private getOrderByForState(
    state: CampaignState,
  ): Prisma.CharityCampaignOrderByWithRelationInput[] {
    switch (state) {
      case 'PENDING':
        return [{ requestedAt: 'desc' }, { createdAt: 'desc' }];
      case 'APPROVED':
      case 'REJECTED':
        return [{ respondedAt: 'desc' }, { createdAt: 'desc' }];
      case 'DONATING':
        return [{ startedDonationAt: 'desc' }, { createdAt: 'desc' }];
      case 'DISTRIBUTING':
        return [{ startedDistributionAt: 'desc' }, { createdAt: 'desc' }];
      case 'FINISHED':
        return [{ finishedDistributionAt: 'desc' }, { createdAt: 'desc' }];
      case 'SUSPENDED':
        return [{ respondedAt: 'desc' }, { createdAt: 'desc' }];
      case 'CREATED':
      default:
        return [{ createdAt: 'desc' }];
    }
  }

  private mapCampaignListItem(campaign: CharityCampaignListItemPayload) {
    return {
      id: campaign.campaignId,
      name: campaign.campaignName,
      organizedBy: campaign.organizer?.userId ?? null,
      organizerResidence: formatLocation(
        campaign.organizer?.residenceWard,
        campaign.organizer?.residenceProvince,
      ),
      benefactorName:
        campaign.organizer?.fullname || campaign.organizer?.nickname || 'Unknown',
      state: String(campaign.state).toUpperCase(),
      requestedAt: campaign.requestedAt,
      respondedAt: campaign.respondedAt,
      createdAt: campaign.createdAt,
    };
  }

  private normalizeBankPayload(payload: {
    bankId?: number;
    bankName?: string;
    bankAccountNumber: string;
    bankAccountName?: string;
  }) {
    return {
      bankId: payload.bankId,
      bankName: payload.bankName?.trim(),
      bankAccountNumber: payload.bankAccountNumber.trim(),
      userBankName: payload.bankAccountName?.trim() || 'UNKNOWN',
    };
  }

  private async resolveBank(payload: {
    bankId?: number;
    bankName?: string;
  }): Promise<ResolvedBank> {
    if (payload.bankId) {
      const bank = await this.prisma.bank.findUnique({
        where: { id: payload.bankId },
        select: {
          id: true,
          name: true,
          code: true,
          shortName: true,
        },
      });

      if (!bank) {
        throw new BadRequestException('Selected bank does not exist');
      }

      return bank;
    }

    const bankName = payload.bankName?.trim();
    if (!bankName) {
      throw new BadRequestException('bankId or bankName is required');
    }

    const bank = await this.prisma.bank.findFirst({
      where: {
        OR: [
          { shortName: bankName },
          { name: bankName },
          { code: bankName },
        ],
      },
      select: {
        id: true,
        name: true,
        code: true,
        shortName: true,
      },
    });

    if (!bank) {
      throw new BadRequestException('Selected bank does not exist');
    }

    return bank;
  }

  private async resolveOrCreateBankAccountId(
    db: Prisma.TransactionClient | PrismaService,
    payload: {
      bankId?: number;
      bankName?: string;
      bankAccountNumber: string;
      bankAccountName?: string;
    },
  ) {
    const normalized = this.normalizeBankPayload(payload);
    const bank = await this.resolveBank(normalized);
    const existing = await db.bankAccount.findUnique({
      where: {
        bankId_bankAccountNumber: {
          bankId: bank.id,
          bankAccountNumber: normalized.bankAccountNumber,
        },
      },
      select: {
        bankAccountId: true,
      },
    });

    if (existing) {
      return existing.bankAccountId;
    }

    const created = await db.bankAccount.create({
      data: {
        bankId: bank.id,
        bankAccountNumber: normalized.bankAccountNumber,
        userBankName: normalized.userBankName,
      },
      select: {
        bankAccountId: true,
      },
    });

    return created.bankAccountId;
  }

  private parseAndValidateTimeline(payload: {
    startedDonationAt: string;
    finishedDonationAt: string;
    startedDistributionAt: string;
    finishedDistributionAt: string;
  }) {
    const startedDonationAt = new Date(payload.startedDonationAt);
    const finishedDonationAt = new Date(payload.finishedDonationAt);
    const startedDistributionAt = new Date(payload.startedDistributionAt);
    const finishedDistributionAt = new Date(payload.finishedDistributionAt);

    this.validateTimelineValues(
      startedDonationAt,
      finishedDonationAt,
      startedDistributionAt,
      finishedDistributionAt,
    );

    return {
      startedDonationAt,
      finishedDonationAt,
      startedDistributionAt,
      finishedDistributionAt,
    };
  }

  private validateTimelineValues(
    startedDonationAt: Date | null,
    finishedDonationAt: Date | null,
    startedDistributionAt: Date | null,
    finishedDistributionAt: Date | null,
  ) {
    if (
      !startedDonationAt ||
      !finishedDonationAt ||
      !startedDistributionAt ||
      !finishedDistributionAt
    ) {
      throw new BadRequestException('All campaign timeline fields are required');
    }

    const now = new Date();
    if (startedDonationAt.getTime() <= now.getTime()) {
      throw new BadRequestException('startedDonationAt must be after current time');
    }
    if (startedDonationAt.getTime() >= finishedDonationAt.getTime()) {
      throw new BadRequestException(
        'startedDonationAt must be earlier than finishedDonationAt',
      );
    }
    if (finishedDonationAt.getTime() >= startedDistributionAt.getTime()) {
      throw new BadRequestException(
        'finishedDonationAt must be earlier than startedDistributionAt',
      );
    }
    if (startedDistributionAt.getTime() >= finishedDistributionAt.getTime()) {
      throw new BadRequestException(
        'startedDistributionAt must be earlier than finishedDistributionAt',
      );
    }
  }
}
