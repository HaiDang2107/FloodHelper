import { Body, Controller, Headers, Post } from '@nestjs/common';
import { TransactionSyncDto } from './dto';
import { VietQrService } from './vietqr.service';

@Controller('vqr')
export class VietQrWebhookController {
  constructor(private readonly vietQrService: VietQrService) {}

  @Post('api/token_generate')
  async generateTokenForParner(@Headers('authorization') authorization?: string) {
    return this.vietQrService.issuePartnerToken(authorization);
  }

  @Post('bank/api/transaction-sync')
  async syncTransaction(
    @Headers('authorization') authorization: string | undefined,
    @Body() body: TransactionSyncDto,
  ) {
    return this.vietQrService.handleVietQrTransactionSync(authorization, body);
  }
}
