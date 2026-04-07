import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma, PrismaClient } from '@prisma/client';

type CharityCampaignListItemPayload = Prisma.CharityCampaignGetPayload<{
  select: {
    campaignId: true;
    campaignName: true;
    state: true;
    createdAt: true;
    organizer: {
      select: {
        fullname: true;
        nickname: true;
      };
    };
  };
}>;

type CharityCampaignDetailPayload = Prisma.CharityCampaignGetPayload<{
  include: {
    organizer: {
      select: {
        userId: true;
        fullname: true;
        nickname: true;
      };
    };
    bankAccounts: true;
    transactions: true;
    supplies: true;
  };
}>;

@Injectable()
export class CharityService {
  private readonly prisma: PrismaClient;

  private readonly allowedStates = new Set([
    'PENDING',
    'APPROVED',
    'REJECTED',
    'DONATING',
    'DISTRIBUTING',
    'FINISHED',
  ]);

  constructor() {
    this.prisma = new PrismaClient();
  }

  async listExistingCampaignsByState(state: string) {
    const normalizedState = this.normalizeAndValidateState(state);

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
        organizer: {
          select: {
            fullname: true,
            nickname: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
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
        organizer: {
          select: {
            fullname: true,
            nickname: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return campaigns.map((campaign) => this.mapCampaignListItem(campaign));
  }

  async getCampaignDetail(campaignId: string) {
    const campaign = await this.prisma.charityCampaign.findUnique({
      where: { campaignId },
      include: {
        organizer: {
          select: {
            userId: true,
            fullname: true,
            nickname: true,
          },
        },
        bankAccounts: {
          orderBy: { bankAccountId: 'asc' },
        },
        transactions: {
          orderBy: { donateAt: 'desc' },
        },
        supplies: {
          orderBy: { boughtAt: 'desc' },
        },
      },
    });

    if (!campaign) {
      throw new NotFoundException('Charity campaign not found');
    }

    const announcements = await this.prisma.announcementFromBenefactor.findMany({
      where: { campaignId },
      orderBy: { announcementId: 'desc' },
    });

    return this.mapCampaignDetail(campaign, announcements);
  }

  private normalizeAndValidateState(state: string): string {
    if (!state) {
      throw new BadRequestException('state is required');
    }

    const normalized = state.trim().toUpperCase();
    const mapped = normalized === 'ACCEPTED' ? 'APPROVED' : normalized;

    if (!this.allowedStates.has(mapped)) {
      throw new BadRequestException(
        'Invalid state. Allowed values: PENDING, APPROVED, REJECTED, DONATING, DISTRIBUTING, FINISHED',
      );
    }

    return mapped;
  }

  private mapCampaignListItem(campaign: CharityCampaignListItemPayload) {
    return {
      id: campaign.campaignId,
      name: campaign.campaignName,
      benefactorName:
        campaign.organizer?.fullname || campaign.organizer?.nickname || 'Unknown',
      state: String(campaign.state).toUpperCase(),
      createdAt: campaign.createdAt,
    };
  }

  private mapCampaignDetail(
    campaign: CharityCampaignDetailPayload,
    announcements: Array<{ textContent: string | null; imageUrl: string | null }>,
  ) {
    const firstBank = campaign.bankAccounts?.[0];

    const startDate =
      campaign.startDonationAt ?? campaign.startDistributionAt ?? campaign.createdAt;
    const endDate =
      campaign.finishDistributionAt ?? campaign.finishDonationAt ?? startDate;

    return {
      id: campaign.campaignId,
      organizedBy: campaign.organizer?.userId,
      checkedBy: null,
      name: campaign.campaignName,
      benefactorName:
        campaign.organizer?.fullname || campaign.organizer?.nickname || 'Unknown',
      purpose: campaign.purpose,
      charityObject: campaign.charityObject,
      state:
        String(campaign.state).toUpperCase() === 'ACCEPTED'
          ? 'APPROVED'
          : String(campaign.state).toUpperCase(),
      bankInfo: {
        accountNumber: firstBank?.bankAccountNumber ?? '',
        bankName: firstBank?.bankName ?? '',
        accountHolder: firstBank?.bankAccountName ?? null,
      },
      reliefLocation: campaign.destination,
      startDonationAt: campaign.startDonationAt,
      finishDonationAt: campaign.finishDonationAt,
      startDistributionAt: campaign.startDistributionAt,
      finishDistributionAt: campaign.finishDistributionAt,
      bankStatementFileUrl: campaign.bankStatementFileUrl,
      period: {
        startDate,
        endDate,
      },
      announcements: announcements.map((announcement) => ({
        textContent: announcement.textContent,
        imageUrl: announcement.imageUrl,
        createdAt: campaign.createdAt,
      })),
      purchasedSupplies: campaign.supplies.map((supply) => ({
        supplyName: supply.supplyName,
        quantity: supply.quantity,
        unitPrice: supply.unitPrice,
        price: supply.price,
      })),
      donations: campaign.transactions.map((transaction) => ({
        transferType: transaction.transferType,
        transferAmount: transaction.transferAmount,
        transferBy: transaction.transferBy,
        donateAt: transaction.donateAt,
        message: transaction.message,
      })),
      createdAt: campaign.createdAt,
    };
  }
}