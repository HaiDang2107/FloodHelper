import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { formatLocation } from '../common/location-format.util';

type CharityCampaignDetailPayload = Prisma.CharityCampaignGetPayload<{
  include: {
    organizer: {
      select: {
        userId: true;
        fullname: true;
        nickname: true;
        residenceProvinceCode: true;
        residenceWardCode: true;
        residenceProvince: {
          select: {
            code: true;
            name: true;
          };
        };
        residenceWard: {
          select: {
            code: true;
            name: true;
          };
        };
      };
    };
    destinationProvince: {
      select: {
        code: true;
        name: true;
      };
    };
    destinationWard: {
      select: {
        code: true;
        name: true;
      };
    };
    bankAccount: {
      include: {
        bank: true;
      };
    };
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
            residenceProvinceCode: true,
            residenceWardCode: true,
            residenceProvince: {
              select: {
                code: true,
                name: true,
              },
            },
            residenceWard: {
              select: {
                code: true,
                name: true,
              },
            },
          },
        },
        destinationProvince: {
          select: { code: true, name: true },
        },
        destinationWard: {
          select: { code: true, name: true },
        },
        bankAccount: {
          include: {
            bank: true,
          },
        },
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
      orderBy: [{ postedAt: 'desc' }, { announcementId: 'desc' }],
    });

    return this.mapCampaignDetail(campaign, announcements);
  }

  async listBanks() {
    const banks = await this.prisma.bank.findMany({
      select: {
        id: true,
        shortName: true,
      },
      orderBy: [{ shortName: 'asc' }, { name: 'asc' }],
    });

    return banks.map((bank) => ({
      id: bank.id,
      shortName: bank.shortName,
    }));
  }

  private mapCampaignDetail(
    campaign: CharityCampaignDetailPayload,
    announcements: Array<{
      caption: string | null;
      imageUrl: string | null;
      postedAt: Date;
    }>,
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
        bankId: bank?.bankId ?? null,
        accountNumber: bank?.bankAccountNumber ?? '',
        bankName: bank?.bank?.name ?? bank?.bank?.shortName ?? '',
        bankCode: bank?.bank?.code ?? '',
        bankShortName: bank?.bank?.shortName ?? '',
        accountHolder: bank?.userBankName ?? null,
      },
      destinationProvinceCode: campaign.destinationProvinceCode ?? null,
      destinationProvinceName: campaign.destinationProvince?.name ?? null,
      destinationWardCode: campaign.destinationWardCode ?? null,
      destinationWardName: campaign.destinationWard?.name ?? null,
      destinationDetail: campaign.destinationDetail ?? null,
      reliefLocation: formatLocation(
        campaign.destinationWard,
        campaign.destinationProvince,
        campaign.destinationDetail,
      ) ?? '',
      latitude: campaign.campaignLatitude ? Number(campaign.campaignLatitude) : null,
      longitude: campaign.campaignLongitude
        ? Number(campaign.campaignLongitude)
        : null,
      startedDonationAt: campaign.startedDonationAt,
      finishedDonationAt: campaign.finishedDonationAt,
      startedDistributionAt: campaign.startedDistributionAt,
      finishedDistributionAt: campaign.finishedDistributionAt,
      bankStatementFileUrl: campaign.bankStatementFileUrl,
      requestedAt: campaign.requestedAt,
      respondedAt: campaign.respondedAt,
      suspendedAt: campaign.suspendedAt,
      noteForResponse: campaign.noteForResponse,
      noteForSuspension: campaign.noteForSuspension,
      period: {
        startDate,
        endDate,
      },
      announcements: announcements.map((announcement) => ({
        caption: announcement.caption,
        textContent: announcement.caption,
        imageUrl: announcement.imageUrl,
        postedAt: announcement.postedAt,
        createdAt: announcement.postedAt,
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
