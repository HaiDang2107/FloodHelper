import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

type CharityCampaignDetailPayload = Prisma.CharityCampaignGetPayload<{
  include: {
    organizer: {
      select: {
        userId: true;
        fullname: true;
        nickname: true;
      };
    };
    bankAccount: true;
    transactions: true;
  };
}>;

@Injectable()
export class CommonCharityService {
  constructor(private readonly prisma: PrismaService) {}

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
        bankAccount: true,
        transactions: {
          orderBy: { donateAt: 'desc' },
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

  private mapCampaignDetail(
    campaign: CharityCampaignDetailPayload,
    announcements: Array<{ textContent: string | null; imageUrl: string | null }>,
  ) {
    const bank = campaign.bankAccount;

    const startDate =
      campaign.startedDonationAt ?? campaign.startedDistributionAt ?? campaign.createdAt;
    const endDate =
      campaign.finishedDistributionAt ?? campaign.finishedDonationAt ?? startDate;

    return {
      id: campaign.campaignId,
      organizedBy: campaign.organizer?.userId,
      checkedBy: campaign.checkedBy,
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
        accountNumber: bank?.bankAccountNumber ?? '',
        bankName: bank?.bankName ?? '',
        accountHolder: bank?.userBankName ?? null,
      },
      reliefLocation: campaign.destination,
      startedDonationAt: campaign.startedDonationAt,
      finishedDonationAt: campaign.finishedDonationAt,
      startedDistributionAt: campaign.startedDistributionAt,
      finishedDistributionAt: campaign.finishedDistributionAt,
      bankStatementFileUrl: campaign.bankStatementFileUrl,
      requestedAt: campaign.requestedAt,
      respondedAt: campaign.respondedAt,
      noteByAuthority: campaign.noteByAuthority,
      period: {
        startDate,
        endDate,
      },
      announcements: announcements.map((announcement) => ({
        textContent: announcement.textContent,
        imageUrl: announcement.imageUrl,
        createdAt: campaign.createdAt,
      })),
      donations: campaign.transactions.map((transaction) => ({
        transferType: transaction.transType,
        transferAmount: transaction.amount,
        transferBy: transaction.donatedBy,
        donateAt: transaction.donateAt,
        message: transaction.content,
      })),
      createdAt: campaign.createdAt,
    };
  }
}
