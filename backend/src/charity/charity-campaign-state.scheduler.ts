import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class CharityCampaignStateScheduler {
  private readonly logger = new Logger(CharityCampaignStateScheduler.name);

  constructor(private readonly prisma: PrismaService) {}

  @Cron('0 0 * * *', { timeZone: 'Asia/Ho_Chi_Minh' }) // Vào lúc 0h mỗi ngày theo giờ VN, gọi hàm xử lý
  async handleDailyCampaignStateTransition() {
    await this.transitionCampaignStatesByDate();
  }

  async transitionCampaignStatesByDate(referenceDate = new Date()) {
    const { tomorrowStartUtc } = this.getVietnamDateBounds(referenceDate); // Lấy date theo giờ việt nam, mốc 0h 

    const [approvedToDonating, donatingToDistributing, donatingToFinished] =
      await this.prisma.$transaction([
        this.prisma.charityCampaign.updateMany({
          where: {
            state: 'APPROVED',
            startedDonationAt: {
              not: null,
              lt: tomorrowStartUtc,
            },
            finishedDonationAt: {
              not: null,
              gte: tomorrowStartUtc,
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
              lt: tomorrowStartUtc,
            },
            finishedDistributionAt: {
              not: null,
              gte: tomorrowStartUtc,
            },
          },
          data: {
            state: 'DISTRIBUTING',
          },
        }),
        this.prisma.charityCampaign.updateMany({
          where: {
            state: 'DONATING',
            finishedDistributionAt: {
              not: null,
              lt: tomorrowStartUtc,
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
        `DONATING->FINISHED: ${donatingToFinished.count}`,
      ].join(' | '),
    );
  }

  private getVietnamDateBounds(referenceDate: Date) { // convert từ refDate (UTC) sang giờ VN
    const vietnamOffsetMs = 7 * 60 * 60 * 1000; // +7 giờ
    const vietnamNow = new Date(referenceDate.getTime() + vietnamOffsetMs);

    const year = vietnamNow.getUTCFullYear();
    const month = vietnamNow.getUTCMonth();
    const day = vietnamNow.getUTCDate();

    const todayStartUtc = new Date(
      Date.UTC(year, month, day, 0, 0, 0, 0) - vietnamOffsetMs,
    );
    const tomorrowStartUtc = new Date(
      Date.UTC(year, month, day + 1, 0, 0, 0, 0) - vietnamOffsetMs,
    );

    return {
      todayStartUtc,
      tomorrowStartUtc,
    };
  }
}
