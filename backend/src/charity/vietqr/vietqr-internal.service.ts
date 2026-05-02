import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { randomUUID } from 'crypto';
import { VietQR } from 'vietqr';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class VietQrInternalService {
  private readonly logger = new Logger(VietQrInternalService.name);
  private readonly vietQr: any;

  constructor(private readonly prisma: PrismaService) {
    this.vietQr = new VietQR({
      clientID: process.env.VIETQR_CLIENT_ID ?? 'internal-simulator-client',
      apiKey: process.env.VIETQR_API_KEY ?? 'internal-simulator-key',
    });
  }

  async createDonationQrInternal(
    campaignId: string,
    amountInput: string,
    donorUserId: string,
  ) {
    const amount = this.parseAmount(amountInput);

    const campaign = await this.prisma.charityCampaign.findUnique({
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

    if (!campaign) {
      throw new NotFoundException('Charity campaign not found');
    }

    if (String(campaign.state).toUpperCase() !== 'DONATING') {
      throw new BadRequestException(
        'Campaign is not in DONATING state, cannot create donation QR',
      );
    }

    const bankCode = campaign.bankAccount?.bank?.code?.trim();
    const bankAccount = campaign.bankAccount?.bankAccountNumber?.trim();
    const userBankName = campaign.bankAccount?.userBankName?.trim();

    if (!bankCode || !bankAccount || !userBankName) {
      throw new BadRequestException('Campaign bank information is incomplete');
    }

    const transactionId = randomUUID();
    const content = this.buildVietQrContent(campaignId, donorUserId, transactionId);

    const quickLink = this.vietQr.genQuickLink({ //Ảnh QR được lưu ở server của VietQR
      bank: bankCode,
      accountName: userBankName,
      accountNumber: bankAccount,
      amount: amount.toString(),
      memo: content,
      template: 'qr_only',
      media: '.png',
    });

    if (!quickLink || typeof quickLink !== 'string') {
      throw new BadRequestException('Failed to generate internal VietQR quick link');
    }

    await this.prisma.transaction.create({
      data: {
        transactionId,
        campaignId,
        transType: 'C',
        donateAt: new Date(),
        donatedBy: donorUserId,
        amount: amount.toString(),
        state: 'CREATED',
        content,
        qrLink: quickLink,
      },
      select: {
        transactionId: true,
      },
    });

    this.logger.log(
      `createDonationQrInternal success transactionId=${transactionId} campaignId=${campaignId}`,
    );

    return {
      transactionId,
      qrLink: quickLink,
    };
  }

  async triggerTestCallbackInternal(
    transactionId: string,
    requesterUserId: string,
  ) {
    const transaction = await this.prisma.transaction.findUnique({
      where: { transactionId },
      select: {
        transactionId: true,
        state: true,
        campaign: {
          select: {
            organizedBy: true,
          },
        },
      },
    });

    if (!transaction) {
      throw new NotFoundException('Transaction not found');
    }

    if (transaction.campaign?.organizedBy !== requesterUserId) {
      throw new ForbiddenException(
        'You are not allowed to trigger callback for this transaction',
      );
    }

    const state = String(transaction.state).toUpperCase();
    if (state !== 'CREATED' && state !== 'VERIFYING') {
      throw new BadRequestException(
        'Only CREATED or VERIFYING transactions can trigger internal callback',
      );
    }

    await this.prisma.transaction.update({
      where: { transactionId },
      data: {
        state: 'SUCCESS',
        transactionTime: new Date(),
        referencenumber: `INTERNAL-${Date.now()}`,
      },
    });

    this.logger.log(
      `triggerTestCallbackInternal success transactionId=${transactionId} newState=SUCCESS`,
    );

    return {
      transactionId,
      state: 'SUCCESS',
      message: 'Internal callback simulated successfully.',
    };
  }

  private buildVietQrContent(
    campaignId: string,
    userId: string,
    transactionId: string,
  ): string {
    const compactCampaign = this.toUpperAlphaNumeric(campaignId).slice(0, 4);
    const compactUser = this.toUpperAlphaNumeric(userId).slice(0, 4);
    const compactTransaction = this.toUpperAlphaNumeric(transactionId).slice(0, 5);

    return `FHx${compactCampaign}x${compactUser}x${compactTransaction}`;
  }

  private toUpperAlphaNumeric(value: string): string {
    const normalized = (value || '').replace(/[^a-zA-Z0-9]/g, '').toUpperCase();
    return normalized || '0000';
  }

  private parseAmount(rawAmount: string): bigint {
    const raw = (rawAmount || '').trim();
    if (!raw) {
      throw new BadRequestException('amount must be a non-empty integer string');
    }

    if (!/^\d+$/.test(raw)) {
      throw new BadRequestException('amount must contain digits only');
    }

    const amount = BigInt(raw);
    if (amount <= 0n) {
      throw new BadRequestException('amount must be greater than 0');
    }

    if (amount > BigInt(Number.MAX_SAFE_INTEGER)) {
      throw new BadRequestException(
        'amount is too large for internal simulation limits',
      );
    }

    return amount;
  }
}
