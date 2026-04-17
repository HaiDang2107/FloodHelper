import { Injectable } from '@nestjs/common';
import {
  BadRequestException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { Prisma, TransactionState } from '@prisma/client';
import {
  CreateCampaignDto,
  QueryCampaignTransactionsDto,
  UpdateCampaignDto,
} from './dto';
import { CommonCharityService } from '../common.service';
import { VietQrInternalService } from '../vietqr/vietqr-internal.service';
import { VietQrService } from '../vietqr/vietqr.service';
import { PrismaService } from '../../prisma/prisma.service';

type CharityCampaignListItemPayload = Prisma.CharityCampaignGetPayload<{
  select: {
    campaignId: true;
    campaignName: true;
    state: true;
    createdAt: true;
    requestedAt: true;
    respondedAt: true;
    organizer: {
      select: {
        userId: true;
        fullname: true;
        nickname: true;
        placeOfResidence: true;
      };
    };
  };
}>;

@Injectable()
export class NoruserBenefCharityService {
  private readonly allowedStates = new Set([
    'CREATED',
    'PENDING',
    'APPROVED',
    'REJECTED',
    'DONATING',
    'DISTRIBUTING',
    'FINISHED',
  ]);

  private static readonly ALLOWED_TRANSACTION_STATES = new Set([
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
        state: {
          equals: normalizedState,
          mode: 'insensitive',
        },
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
            placeOfResidence: true,
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
        state: {
          equals: normalizedState,
          mode: 'insensitive',
        },
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
            placeOfResidence: true,
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

  async listCampaignTransactions(
    campaignId: string,
    query: QueryCampaignTransactionsDto,
  ) {
    const normalizedState = (query.state ?? 'SUCCESS').trim().toUpperCase();
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
        destination: payload.destination.trim(),
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
        destination: payload.destination.trim(),
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
            placeOfResidence: true,
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
    if (!campaign.organizer?.placeOfResidence) {
      throw new BadRequestException(
        'Benefactor placeOfResidence is required before sending campaign request',
      );
    }

    const assignedAuthority = await this.prisma.user.findFirst({
      where: {
        placeOfResidence: campaign.organizer.placeOfResidence,
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

  private normalizeAndValidateState(state: string): string {
    if (!state) {
      throw new BadRequestException('state is required');
    }

    const normalized = state.trim().toUpperCase();
    const mapped = normalized === 'ACCEPTED' ? 'APPROVED' : normalized;

    if (!this.allowedStates.has(mapped)) {
      throw new BadRequestException(
        'Invalid state. Allowed values: CREATED, PENDING, APPROVED, REJECTED, DONATING, DISTRIBUTING, FINISHED',
      );
    }

    return mapped;
  }

  private getOrderByForState(
    state: string,
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
      case 'CREATED':
      default:
        return [{ createdAt: 'desc' }];
    }
  }

  private mapCampaignListItem(campaign: CharityCampaignListItemPayload) {
    return {
      id: campaign.campaignId,
      name: campaign.campaignName,
      organizedBy: campaign.organizer?.userId,
      organizerResidence: campaign.organizer?.placeOfResidence ?? null,
      benefactorName:
        campaign.organizer?.fullname || campaign.organizer?.nickname || 'Unknown',
      state: String(campaign.state).toUpperCase(),
      requestedAt: campaign.requestedAt,
      respondedAt: campaign.respondedAt,
      createdAt: campaign.createdAt,
    };
  }

  private normalizeBankPayload(payload: {
    bankName: string;
    bankAccountNumber: string;
    bankAccountName?: string;
  }) {
    return {
      bankName: payload.bankName.trim(),
      bankAccountNumber: payload.bankAccountNumber.trim(),
      userBankName: payload.bankAccountName?.trim() || 'UNKNOWN',
      bankCode: 'UNKNOWN',
    };
  }

  private async resolveOrCreateBankAccountId(
    db: Prisma.TransactionClient | PrismaService,
    payload: {
      bankName: string;
      bankAccountNumber: string;
      bankAccountName?: string;
    },
  ) {
    const normalized = this.normalizeBankPayload(payload);
    const existing = await db.bankAccount.findUnique({
      where: {
        bankName_bankAccountNumber: {
          bankName: normalized.bankName,
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
        bankName: normalized.bankName,
        bankAccountNumber: normalized.bankAccountNumber,
        userBankName: normalized.userBankName,
        bankCode: normalized.bankCode,
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
