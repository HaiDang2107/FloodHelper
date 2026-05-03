import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { CharityRepository } from '../prisma/repositories';

@Injectable()
export class CharityCampaignStateScheduler {
  private readonly logger = new Logger(CharityCampaignStateScheduler.name);

  constructor(private readonly charityRepository: CharityRepository) {}

  // Chạy vào lúc 00:00:05 mỗi ngày theo giờ VN
  @Cron('5 0 * * *', { timeZone: 'Asia/Ho_Chi_Minh' }) 
  async handleDailyCampaignStateTransition() {
    await this.transitionCampaignStatesByDate();
  }

  // referenceDate mặc định là new Date() - thời điểm hàm được gọi (UTC)
  async transitionCampaignStatesByDate(referenceDate = new Date()) { 
    const [approvedToDonating, donatingToDistributing, distributingToFinished] =
      await this.charityRepository.transitionCampaignStatesByDate(referenceDate);

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