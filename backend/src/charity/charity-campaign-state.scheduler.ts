import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class CharityCampaignStateScheduler {
  private readonly logger = new Logger(CharityCampaignStateScheduler.name);

  constructor(private readonly prisma: PrismaService) {}

  // Chạy vào lúc 00:00:05 mỗi ngày theo giờ VN
  @Cron('5 0 * * *', { timeZone: 'Asia/Ho_Chi_Minh' }) 
  async handleDailyCampaignStateTransition() {
    await this.transitionCampaignStatesByDate();
  }

  // referenceDate mặc định là new Date() - thời điểm hàm được gọi (UTC)
  async transitionCampaignStatesByDate(referenceDate = new Date()) { 
    const [approvedToDonating, donatingToDistributing, distributingToFinished] =
      await this.prisma.$transaction([
        this.prisma.charityCampaign.updateMany({
          where: {
            state: 'APPROVED',
            startedDonationAt: {
              not: null,
              lte: referenceDate, // Nhỏ hơn hoặc bằng thời điểm hiện tại
            },
            finishedDonationAt: {
              not: null,
              gt: referenceDate,  // Lớn hơn thời điểm hiện tại
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

    this.logger.log(
      [
        'Daily charity state transition completed',
        `APPROVED->DONATING: ${approvedToDonating.count}`,
        `DONATING->DISTRIBUTING: ${donatingToDistributing.count}`,
        `DISTRIBUTING->FINISHED: ${distributingToFinished.count}`,
      ].join(' | '),
    );
  }
}