import { CACHE_MANAGER } from '@nestjs/cache-manager';
import {
  BadRequestException,
  ForbiddenException,
  Inject,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { randomUUID } from 'crypto';
import { JwtService } from '@nestjs/jwt';
import { TransactionState } from '@prisma/client';
import type { Cache } from 'cache-manager';
import { TransactionSyncDto } from './dto';
import { PrismaService } from '../../prisma/prisma.service';

interface GenerateCustomerQrInput {
  bankCode: string;
  bankAccount: string;
  userBankName: string;
  amount: number;
  content: string;
  orderId: string;
  transType: 'C';
  qrType: 0;
}

interface GenerateCustomerQrOutput {
  qrLink: string;
  qrCode: string;
  transactionId: string;
  transactionRefId: string;
  content: string;
}

interface TestTransactionCallbackInput {
  bankAccount: string;
  content: string;
  amount: number;
  transType: 'C';
  bankCode: string;
}

interface TestTransactionCallbackOutput {
  status: string;
  message: string;
}

@Injectable()
export class VietQrService {
  private static readonly TOKEN_CACHE_KEY = 'vietqr:access-token';
  private static readonly TOKEN_TTL_MS = 250 * 1000;
  private readonly logger = new Logger(VietQrService.name);

  private readonly tokenUrl =
    process.env.VIETQR_TOKEN_URL ??
    'https://dev.vietqr.org/vqr/api/token_generate';

  private readonly generateQrUrl =
    process.env.VIETQR_GENERATE_QR_URL ??
    'https://dev.vietqr.org/vqr/api/qr/generate-customer';

  private readonly testCallbackUrl =
    process.env.VIETQR_TEST_CALLBACK_URL ??
    'https://dev.vietqr.org/vqr/bank/api/test/transaction-callback';

  constructor(
    private readonly prisma: PrismaService,
    @Inject(CACHE_MANAGER) private readonly cacheManager: Cache,
    private readonly jwtService: JwtService,
  ) {}

  triggerTestCallback(transactionId: string, requesterUserId: string) {
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
    }).then(async (transaction) => {
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
          'Only CREATED or VERIFYING transactions can trigger test callback',
        );
      }

      const amount = Number(transaction.amount);
      if (!Number.isFinite(amount) || amount <= 0) {
        throw new BadRequestException('Transaction amount is invalid');
      }

      await this.prisma.transaction.update({
        where: { transactionId },
        data: {
          state: 'VERIFYING',
        },
      });

      await this.callTestTransactionCallback({
        bankAccount: transaction.donatedBy || '',
        content: transaction.transactionId,
        amount,
        transType: 'C',
        bankCode: '970422',
      });

      return {
        transactionId,
        state: 'VERIFYING',
        message:
          'Test callback triggered successfully. Processing may take a few minutes.',
      };
    });
  }

  async callTestTransactionCallback(
    payload: TestTransactionCallbackInput,
  ): Promise<TestTransactionCallbackOutput> {
    this.logger.log(
      `callTestTransactionCallback started content=${payload.content} amount=${payload.amount}`,
    );

    const token = await this.getAccessToken();
    const response = await fetch(this.testCallbackUrl, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    });

    const body = (await response.json().catch(() => ({}))) as Record<string, unknown>;
    const status = (body.status ?? '').toString();
    const message = (body.message ?? '').toString();

    this.logger.debug(
      `callTestTransactionCallback response status=${response.status} body=${JSON.stringify(
        body,
      )}`,
    );

    if (!response.ok || !status) {
      const errorText = this.extractVietQrError(body);
      throw new BadRequestException(`Failed to call test callback: ${errorText}`);
    }

    return {
      status,
      message,
    };
  }

  async createDonationQr(
    campaignId: string,
    amountInput: string,
    donorUserId: string,
  ) {
    const amount = this.parseAmount(amountInput);
    const amountNumber = Number(amount);

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
    const formattedContent = this.buildVietQrContent(
      campaignId,
      donorUserId,
      transactionId,
    );
    const orderId = transactionId.slice(0, 10);

    const createdTransaction = await this.prisma.transaction.create({
      data: {
        transactionId,
        campaignId,
        transType: 'C',
        donateAt: new Date(),
        donatedBy: donorUserId,
        amount: amount.toString(),
        state: 'CREATED',
      },
      select: {
        transactionId: true,
      },
    });

    const qrResult = await this.generateCustomerQr({
      bankCode,
      bankAccount,
      userBankName,
      amount: amountNumber,
      content: formattedContent,
      orderId,
      transType: 'C',
      qrType: 0,
    });

    await this.prisma.transaction.update({
      where: {
        transactionId: createdTransaction.transactionId,
      },
      data: {
        transactionIdFromVietQR: qrResult.transactionId || null,
        transactionRefId: qrResult.transactionRefId || null,
        qrLink: qrResult.qrLink,
        content: qrResult.content
      },
    });

    return {
      transactionId: createdTransaction.transactionId,
      qrCode: qrResult.qrCode,
    };
  }

  async generateCustomerQr(
    payload: GenerateCustomerQrInput,
  ): Promise<GenerateCustomerQrOutput> {
    this.logger.log(
      `generateCustomerQr started orderId=${payload.orderId} amount=${payload.amount} bankCode=${payload.bankCode}`,
    );
    this.logger.debug(
      `generateCustomerQr payload=${JSON.stringify(
        this.sanitizeGeneratePayload(payload),
      )}`,
    );

    const token = await this.getAccessToken();
    return this.callGenerateQrApi(payload, token, true);
  }

  private async getAccessToken(): Promise<string> {
    const cachedToken = await this.cacheManager.get<string>(
      VietQrService.TOKEN_CACHE_KEY,
    );

    if (cachedToken && cachedToken.trim().length > 0) {
      this.logger.debug('getAccessToken cache hit');
      return cachedToken;
    }

    this.logger.debug('getAccessToken cache miss, requesting new token');

    const username = process.env.VIETQR_USERNAME;
    const password = process.env.VIETQR_PASSWORD;

    if (!username || !password) {
      this.logger.error('getAccessToken missing VIETQR_USERNAME/VIETQR_PASSWORD');
      throw new BadRequestException('VietQR credentials are not configured');
    }

    const authBase64 = Buffer.from(`${username}:${password}`).toString('base64');

    const response = await fetch(this.tokenUrl, {
      method: 'POST',
      headers: {
        Authorization: `Basic ${authBase64}`,
      },
    });

    this.logger.debug(`getAccessToken response status=${response.status}`);

    const body = (await response.json().catch(() => ({}))) as Record<string, unknown>;
    const accessToken = (body.access_token ?? '').toString();

    if (!response.ok || !accessToken) {
      this.logger.error(
        `getAccessToken failed status=${response.status} reason=${this.extractVietQrError(body)}`,
      );
      throw new BadRequestException(
        `Failed to get VietQR token: ${this.extractVietQrError(body)}`,
      );
    }

    await this.cacheManager.set(
      VietQrService.TOKEN_CACHE_KEY,
      accessToken,
      VietQrService.TOKEN_TTL_MS,
    );

    this.logger.debug('getAccessToken success and token cached');

    return accessToken;
  }

  private async callGenerateQrApi(
    payload: GenerateCustomerQrInput,
    token: string,
    allowRetry: boolean,
  ): Promise<GenerateCustomerQrOutput> {
    this.logger.debug(
      `callGenerateQrApi sending request orderId=${payload.orderId} allowRetry=${allowRetry}`,
    );
    this.logger.debug(
      `callGenerateQrApi requestBody=${JSON.stringify(
        this.sanitizeGeneratePayload(payload),
      )}`,
    );

    const response = await fetch(this.generateQrUrl, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    });

    this.logger.debug(
      `callGenerateQrApi response status=${response.status} orderId=${payload.orderId}`,
    );

    const body = (await response.json().catch(() => ({}))) as Record<string, unknown>;
    this.logger.debug(
      `callGenerateQrApi responseBody=${JSON.stringify(
        this.sanitizeResponseBody(body),
      )}`,
    );

    const qrLink = (body.qrLink ?? '').toString();
    const qrCode = (body.qrCode ?? '').toString();
    const transactionId = (body.transactionId ?? '').toString();
    const transactionRefId = (body.transactionRefId ?? '').toString();
    const content = (body.content ?? '').toString();

    if (response.ok && qrCode) {
      this.logger.log(
        `callGenerateQrApi success orderId=${payload.orderId} vietQrTransactionId=${transactionId}`,
      );
      return {
        qrLink,
        qrCode,
        transactionId,
        transactionRefId,
        content,
      };
    }

    const errorText = this.extractVietQrError(body);
    const isTokenError = errorText.includes('E74') || response.status === 401;

    if (allowRetry && isTokenError) {
      this.logger.warn(
        `callGenerateQrApi token invalid, retrying once orderId=${payload.orderId}`,
      );
      await this.cacheManager.del(VietQrService.TOKEN_CACHE_KEY);
      const refreshedToken = await this.getAccessToken();
      return this.callGenerateQrApi(payload, refreshedToken, false);
    }

    this.logger.error(
      `callGenerateQrApi failed orderId=${payload.orderId} status=${response.status} reason=${errorText}`,
    );

    throw new BadRequestException(`Failed to generate VietQR: ${errorText}`);
  }

  async issuePartnerToken(authorization?: string) {
    const [username, password] = this.extractBasicCredentials(authorization);
    const expectedUsername =
      process.env.MY_USERNAME ?? process.env.MY_USERNAME ?? '';
    const expectedPassword =
      process.env.MY_PASSWORD ?? process.env.MY_PASSWORD ?? '';

    if (!expectedUsername || !expectedPassword) {
      throw new BadRequestException('Partner credentials are not configured');
    }

    if (username != expectedUsername || password != expectedPassword) {
      throw new BadRequestException('Invalid partner credentials');
    }

    const accessToken = await this.jwtService.signAsync(
      {
        username,
        purpose: 'vietqr-transaction-sync',
      },
      {
        algorithm: 'HS512',
        expiresIn: '300s',
        secret:
          process.env.AT_SECRET ??
          'vietqr-webhook-secret',
      },
    );

    return {
      access_token: accessToken,
      token_type: 'Bearer',
      expires_in: 300,
    };
  }

  async handleVietQrTransactionSync(
    authorization: string | undefined,
    payload: TransactionSyncDto,
  ) {
    await this.verifyPartnerToken(authorization);

    const content = (payload.content || '').trim();
    if (!content) {
      throw new BadRequestException('content is required to match transaction');
    }

    const transaction = await this.prisma.transaction.findFirst({
      where: {
        content,
      },
      orderBy: {
        createdAt: 'desc',
      },
      select: {
        transactionId: true,
        state: true,
      },
    });

    if (!transaction) {
      throw new NotFoundException('Transaction not found for given content');
    }

    const amount = this.parseAmount(payload.amount);
    const transactionTime = new Date(payload.transactiontime);
    if (Number.isNaN(transactionTime.getTime())) {
      throw new BadRequestException('transactiontime is invalid');
    }

    const nextState = this.resolveSyncState(payload);
    const referenceNumber = (payload.referencenumber || payload.referencenumer || '')
      .trim();

    await this.prisma.transaction.update({
      where: {
        transactionId: transaction.transactionId,
      },
      data: {
        state: nextState,
        referencenumber: referenceNumber || null,
        transactionTime,
      },
    });

    return {
      matchedBy: 'content',
      transactionId: transaction.transactionId,
      previousState: String(transaction.state).toUpperCase(),
      newState: nextState,
      updated: true,
    };
  }

  // PRIVATE FUNCTION

  private extractVietQrError(body: Record<string, unknown>): string {
    return (
      body.message?.toString() ||
      body.errorReason?.toString() ||
      body.toastMessage?.toString() ||
      'Unknown VietQR error'
    );
  }

  private sanitizeGeneratePayload(payload: GenerateCustomerQrInput) {
    return {
      orderId: payload.orderId,
      amount: payload.amount,
      transType: payload.transType,
      qrType: payload.qrType,
      content: payload.content,
      bankCode: payload.bankCode,
      userBankName: payload.userBankName,
      bankAccount: this.maskBankAccount(payload.bankAccount),
    };
  }

  private sanitizeResponseBody(body: Record<string, unknown>) {
    return {
      code: body.code,
      message: body.message,
      errorReason: body.errorReason,
      toastMessage: body.toastMessage,
      qrLink: body.qrLink,
      qrCode: body.qrCode,
      transactionId: body.transactionId,
      transactionRefId: body.transactionRefId,
      bankCode: body.bankCode,
      amount: body.amount,
      content: body.content,
    };
  }

  private maskBankAccount(account: string): string {
    if (account.length <= 4) {
      return '****';
    }

    const suffix = account.slice(-4);
    return `****${suffix}`;
  }

  private extractBasicCredentials(authorization?: string): [string, string] {
    if (!authorization || !authorization.startsWith('Basic ')) {
      throw new BadRequestException('Missing Basic authorization header');
    }

    const encoded = authorization.slice('Basic '.length).trim();
    const decoded = Buffer.from(encoded, 'base64').toString('utf8');
    const separatorIndex = decoded.indexOf(':');

    if (separatorIndex <= 0) {
      throw new BadRequestException('Invalid Basic authorization format');
    }

    const username = decoded.slice(0, separatorIndex);
    const password = decoded.slice(separatorIndex + 1);
    return [username, password];
  }

  async verifyPartnerToken(authorization?: string) { // decode
    const token = this.extractBearerToken(authorization);
    return this.jwtService.verifyAsync(token, {
      algorithms: ['HS512'],
      secret:
        process.env.AT_SECRET ??
        'vietqr-webhook-secret',
    });
  }

  private extractBearerToken(authorization?: string): string {
    if (!authorization || !authorization.startsWith('Bearer ')) {
      throw new BadRequestException('Missing Bearer authorization header');
    }

    const token = authorization.slice('Bearer '.length).trim();
    if (!token) {
      throw new BadRequestException('Empty Bearer token');
    }

    return token;
  }

  private resolveSyncState(payload: TransactionSyncDto): TransactionState {
    const amount = this.parseAmount(payload.amount);
    if (amount > 0n) {
      return 'SUCCESS';
    }
    return 'FAILED';
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
        'amount is too large for VietQR simulation limits',
      );
    }

    return amount;
  }

  private buildVietQrContent(
    campaignId: string,
    userId: string,
    transactionId: string,
  ): string {
    const c4 = this.sanitizeSegment(campaignId, 4);
    const u4 = this.sanitizeSegment(userId, 4);
    const t5 = this.sanitizeSegment(transactionId, 5);

    return `FHx${c4}x${u4}x${t5}`;
  }

  private sanitizeSegment(raw: string, length: number): string {
    const compact = (raw || '').replace(/[^a-zA-Z0-9]/g, '').toUpperCase();
    if (compact.length >= length) {
      return compact.slice(0, length);
    }
    return compact.padEnd(length, '0');
  }
}
