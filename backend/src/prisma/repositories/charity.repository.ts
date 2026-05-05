import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { BaseRepository } from './base.repository';

/**
 * CharityRepository - Handles CharityCampaign and related queries
 * Manages campaigns, transactions, donations, supplies distribution
 */
@Injectable()
export class CharityRepository extends BaseRepository<any> {
  constructor(private readonly prisma: PrismaService) {
    super('Charity');
  }

  /**
   * Create charity campaign
   */
  async createCampaign(organizedBy: string, data: any) {
    return this.prisma.charityCampaign.create({
      data: {
        campaignName: data.campaignName,
        purpose: data.purpose,
        charityObject: data.charityObject,
        organizedBy,
        destinationProvinceCode: data.destinationProvinceCode,
        destinationWardCode: data.destinationWardCode,
        destinationDetail: data.destinationDetail,
        campaignLatitude: data.campaignLatitude,
        campaignLongitude: data.campaignLongitude,
        state: 'CREATED' as any,
      },


    });
  }

  /**
   * Get campaign with full details
   */
  async getCampaignDetail(campaignId: string) {
    return this.prisma.charityCampaign.findUnique({
      where: { campaignId },
      select: {
        campaignId: true,
        campaignName: true,
        purpose: true,
        charityObject: true,
        organizedBy: true,
        destinationProvinceCode: true,
        destinationWardCode: true,
        destinationDetail: true,
        campaignLatitude: true,
        campaignLongitude: true,
        state: true,
        createdAt: true,
        requestedAt: true,
        respondedAt: true,
        suspendedAt: true,
        checkedBy: true,
        noteForResponse: true,
        noteForSuspension: true,
        startedDonationAt: true,
        finishedDonationAt: true,
        startedDistributionAt: true,
        finishedDistributionAt: true,
        bankStatementFileUrl: true,
        bankAccountId: true,
        organizer: {
          include: {
            profiles: {
              where: { isCurrent: true },
              select: {
                fullname: true,
                nickname: true,
                avatarUrl: true,
                residenceProvinceCode: true,
                residenceWardCode: true,
                residenceProvince: { select: { code: true, name: true } },
                residenceWard: { select: { code: true, name: true } },
              }
            }
          },
          select: {
            userId: true,
            role: true,
          },
        },

        destinationProvince: {
          select: {
            code: true,
            name: true,
          },
        },
        destinationWard: {
          select: {
            code: true,
            name: true,
          },
        },
        checker: {
          select: {
            userId: true,
            profiles: {
              where: { isCurrent: true },
              select: { fullname: true },
            },
          },
        },
        bankAccount: {
          select: {
            bankAccountId: true,
            userBankName: true,
            bankId: true,
            bankAccountNumber: true,
            bank: {
              select: { id: true, name: true, code: true, shortName: true },
            },
          },
        },
        transactions: true,
        supplies: true,
        financialSupports: true,
      },
    });
  }

  /**
   * List campaigns by state
   */
  async listCampaignsByState(state: string, limit: number = 50) {
    return this.prisma.charityCampaign.findMany({
      where: { state: state as any },
      include: {
        organizer: {
          select: {
            userId: true,
            profiles: {
              where: { isCurrent: true },
              select: { fullname: true, avatarUrl: true },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
  }

  /**
   * List campaigns by organizer
   */
  async listCampaignsByOrganizer(userId: string) {
    return this.prisma.charityCampaign.findMany({
      where: { organizedBy: userId },
      include: {
        organizer: {
          select: {
            userId: true,
            profiles: {
              where: { isCurrent: true },
              select: { fullname: true, avatarUrl: true },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  /**
   * Update campaign
   */
  async updateCampaign(campaignId: string, data: any) {
    return this.prisma.charityCampaign.update({
      where: { campaignId },
      data,
    });
  }

  /**
   * Update campaign state
   */
  async updateCampaignState(campaignId: string, state: string, checkBy?: string) {
    return this.prisma.charityCampaign.update({
      where: { campaignId },
      data: {
        state: state as any,
        checkedBy: checkBy,
        respondedAt: new Date(),
      },
    });
  }

  /**
   * Record donation transaction
   */
  async recordTransaction(campaignId: string, data: any) {
    return this.prisma.transaction.create({
      data: {
        campaignId,
        donateAt: data.donateAt || new Date(),
        donatedBy: data.donatedBy,
        amount: data.amount,
        content: data.content,
        transType: data.transType || 'C',
        state: 'CREATED' as any,
      },
    });
  }

  /**
   * Get transactions for campaign
   */
  async getCampaignTransactions(campaignId: string) {
    return this.prisma.transaction.findMany({
      where: { campaignId },
      orderBy: { donateAt: 'desc' },
    });
  }

  /**
   * Record supply distribution
   */
  async recordSupplyDistribution(campaignId: string, data: any) {
    return this.prisma.supply.create({
      data: {
        campaignId,
        supplyName: data.supplyName,
        quantity: data.quantity,
        price: data.price,
        boughtAt: data.boughtAt || new Date(),
      },
    });
  }

  /**
   * Get supplies for campaign
   */
  async getCampaignSupplies(campaignId: string) {
    return this.prisma.supply.findMany({
      where: { campaignId },
    });
  }

  async getCampaignOwnership(campaignId: string) {
    return this.prisma.charityCampaign.findUnique({
      where: { campaignId },
      select: {
        campaignId: true,
        organizedBy: true,
        state: true,
      },
    });
  }

  async createSupply(campaignId: string, data: any) {
    return this.prisma.supply.create({
      data: {
        campaignId,
        supplyName: data.supplyName.trim(),
        quantity: data.quantity,
        unitPrice: data.unitPrice,
        price: data.quantity * data.unitPrice,
        boughtAt: data.boughtAt ? new Date(data.boughtAt) : new Date(),
      },
    });
  }

  async findSupply(supplyId: string, campaignId: string) {
    return this.prisma.supply.findFirst({
      where: { supplyId, campaignId },
    });
  }

  async updateSupply(supplyId: string, campaignId: string, data: any) {
    return this.prisma.supply.update({
      where: { supplyId },
      data: {
        supplyName: data.supplyName,
        quantity: data.quantity,
        unitPrice: data.unitPrice,
        price: data.price,
        boughtAt: data.boughtAt,
      },
    });
  }

  async deleteSupply(supplyId: string, campaignId: string) {
    return this.prisma.supply.deleteMany({
      where: { supplyId, campaignId },
    });
  }

  async listFinancialSupports(campaignId: string) {
    return this.prisma.financialSupport.findMany({
      where: { campaignId },
      orderBy: { allocatedAt: 'desc' },
    });
  }

  async createFinancialSupport(campaignId: string, data: any) {
    return this.prisma.financialSupport.create({
      data: {
        campaignId,
        householdName: data.householdName.trim(),
        amount: data.amount,
        allocatedAt: data.allocatedAt ? new Date(data.allocatedAt) : new Date(),
      },
    });
  }

  async findFinancialSupport(financialSupportId: string, campaignId: string) {
    return this.prisma.financialSupport.findFirst({
      where: { financialSupportId, campaignId },
    });
  }

  async updateFinancialSupport(financialSupportId: string, campaignId: string, data: any) {
    return this.prisma.financialSupport.update({
      where: { financialSupportId },
      data: {
        householdName: data.householdName,
        amount: data.amount,
        allocatedAt: data.allocatedAt,
      },
    });
  }

  async deleteFinancialSupport(financialSupportId: string, campaignId: string) {
    return this.prisma.financialSupport.deleteMany({
      where: { financialSupportId, campaignId },
    });
  }

  async listBanks() {
    return this.prisma.bank.findMany({
      select: {
        id: true,
        shortName: true,
      },
      orderBy: [{ shortName: 'asc' }, { name: 'asc' }],
    });
  }

  async listAnnouncementsByCampaign(campaignId: string) {
    return this.prisma.announcementFromBenefactor.findMany({
      where: { campaignId },
      orderBy: [{ postedAt: 'desc' }, { announcementId: 'desc' }],
    });
  }

  async createAnnouncementFromBenefactor(campaignId: string, data: any) {
    return this.prisma.announcementFromBenefactor.create({
      data: {
        campaignId,
        caption: data.caption,
        imageUrl: data.imageUrl,
        postedAt: data.postedAt || new Date(),
      },
    });
  }

  async ensureBankAccount(payload: { bankId?: number; bankName?: string; bankAccountNumber: string; bankAccountName?: string }) {
    // Resolve bank
    if (payload.bankId) {
      const bank = await this.prisma.bank.findUnique({ where: { id: payload.bankId }, select: { id: true } });
      if (!bank) throw new Error('BANK_NOT_FOUND');
    }

    if (!payload.bankId && payload.bankName) {
      const bank = await this.prisma.bank.findFirst({ where: { OR: [{ shortName: payload.bankName }, { name: payload.bankName }, { code: payload.bankName }] }, select: { id: true } });
      if (!bank) throw new Error('BANK_NOT_FOUND');
      payload.bankId = bank.id;
    }

    if (!payload.bankId) {
      throw new Error('BANK_ID_REQUIRED');
    }

    const existing = await this.prisma.bankAccount.findUnique({
      where: {
        bankId_bankAccountNumber: {
          bankId: payload.bankId,
          bankAccountNumber: payload.bankAccountNumber,
        },
      },
      select: { bankAccountId: true },
    });

    if (existing) return existing.bankAccountId;

    const created = await this.prisma.bankAccount.create({
      data: {
        bankId: payload.bankId,
        bankAccountNumber: payload.bankAccountNumber,
        userBankName: payload.bankAccountName || 'UNKNOWN',
      },
      select: { bankAccountId: true },
    });

    return created.bankAccountId;
  }

  async transitionCampaignStatesByDate(referenceDate = new Date()) {
    return this.prisma.$transaction([
      this.prisma.charityCampaign.updateMany({
        where: {
          state: 'APPROVED',
          startedDonationAt: {
            not: null,
            lte: referenceDate,
          },
          finishedDonationAt: {
            not: null,
            gt: referenceDate,
          },
        },
        data: {
          state: 'DONATING',
        },
      }),
      this.prisma.charityCampaign.updateMany({
        where: {
          state: 'DONATING',
          startedDistributionAt: {
            not: null,
            lte: referenceDate,
          },
          finishedDistributionAt: {
            not: null,
            gt: referenceDate,
          },
        },
        data: {
          state: 'DISTRIBUTING',
        },
      }),
      this.prisma.charityCampaign.updateMany({
        where: {
          state: 'DISTRIBUTING',
          finishedDistributionAt: {
            not: null,
            lte: referenceDate,
          },
        },
        data: {
          state: 'FINISHED',
        },
      }),
    ]);
  }

  async listCampaignsForAuthority(authorityResidenceWardCode: number, stateFilter?: string, limit: number = 20, cursorTime = new Date()) {
    const allowedStates = stateFilter
      ? [stateFilter as any]
      : [
          'PENDING',
          'APPROVED',
          'REJECTED',
          'DONATING',
          'DISTRIBUTING',
          'FINISHED',
          'SUSPENDED',
        ];

    const cursorField = this.getAuthorityCursorField(stateFilter);

    return this.prisma.charityCampaign.findMany({
      where: {
        AND: [
          { state: { in: allowedStates } },
          { organizer: { profiles: { some: { isCurrent: true, residenceWardCode: authorityResidenceWardCode } } } },
          {
            [cursorField]: {
              not: null,
              lte: cursorTime,
            },
          },
        ],
      },
      select: {
        campaignId: true,
        campaignName: true,
        state: true,
        createdAt: true,
        requestedAt: true,
        respondedAt: true,
        suspendedAt: true,
        noteForResponse: true,
        noteForSuspension: true,
        startedDonationAt: true,
        startedDistributionAt: true,
        finishedDistributionAt: true,
        organizer: {
          select: {
            userId: true,
            profiles: {
              where: { isCurrent: true },
              select: {
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
        },
      },
      orderBy: [{ [cursorField]: 'desc' }, { createdAt: 'desc' }],
      take: limit + 1,
    });
  }

  async getCampaignReviewTarget(campaignId: string) {
    return this.prisma.charityCampaign.findUnique({
      where: { campaignId },
      select: {
        campaignId: true,
        checkedBy: true,
        state: true,
        respondedAt: true,
        suspendedAt: true,
        noteForResponse: true,
        noteForSuspension: true,
        organizer: {
          select: {
            profiles: {
              where: { isCurrent: true },
              select: {
                residenceWardCode: true,
              },
            },
          },
        },
      },
    });
  }

  async getCampaignBankInfoForQr(campaignId: string) {
    return this.prisma.charityCampaign.findUnique({
      where: { campaignId },
      select: {
        campaignId: true,
        state: true,
        bankAccount: {
          include: {
            bank: {
              select: {
                code: true,
              },
            },
          },
        },
      },
    });
  }

  async getCampaignBankInfoForQrByState(campaignId: string, state: string) {
    const campaign = await this.getCampaignBankInfoForQr(campaignId);
    if (!campaign || String(campaign.state).toUpperCase() !== state) {
      return null;
    }

    return campaign;
  }

  async createTransaction(data: any) {
    return this.prisma.transaction.create({
      data,
      select: {
        transactionId: true,
      },
    });
  }

  async findTransactionById(transactionId: string) {
    return this.prisma.transaction.findUnique({
      where: { transactionId },
      select: {
        transactionId: true,
        state: true,
        amount: true,
        donatedBy: true,
        campaign: {
          select: {
            organizedBy: true,
          },
        },
      },
    });
  }

  async findTransactionByContent(content: string) {
    return this.prisma.transaction.findFirst({
      where: { content },
      orderBy: { createdAt: 'desc' },
      select: {
        transactionId: true,
        state: true,
      },
    });
  }

  async updateTransaction(transactionId: string, data: any) {
    return this.prisma.transaction.update({
      where: { transactionId },
      data,
    });
  }

  async updateCampaignReviewState(campaignId: string, data: any) {
    return this.prisma.charityCampaign.update({
      where: { campaignId },
      data,
    });
  }

  private getAuthorityCursorField(
    stateFilter?: string,
  ): 'createdAt' | 'requestedAt' | 'respondedAt' | 'suspendedAt' | 'startedDonationAt' | 'startedDistributionAt' | 'finishedDistributionAt' {
    switch (stateFilter) {
      case 'PENDING':
        return 'requestedAt';
      case 'APPROVED':
      case 'REJECTED':
        return 'respondedAt';
      case 'SUSPENDED':
        return 'suspendedAt';
      case 'DONATING':
        return 'startedDonationAt';
      case 'DISTRIBUTING':
        return 'startedDistributionAt';
      case 'FINISHED':
        return 'finishedDistributionAt';
      default:
        return 'createdAt';
    }
  }

  // Base CRUD methods
  async findById(id: string) {
    return this.getCampaignDetail(id);
  }

  async findAll() {
    return this.prisma.charityCampaign.findMany({
      include: {
        organizer: {
          select: {
            userId: true,
            profiles: {
              where: { isCurrent: true },
              select: { fullname: true, avatarUrl: true },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async create(data: any) {
    return this.createCampaign(data.organizedBy, data);
  }

  async update(id: string, data: any) {
    return this.updateCampaign(id, data);
  }

  async delete(id: string) {
    return this.prisma.charityCampaign.delete({
      where: { campaignId: id },
    });
  }

  async count() {
    return this.prisma.charityCampaign.count();
  }
}
