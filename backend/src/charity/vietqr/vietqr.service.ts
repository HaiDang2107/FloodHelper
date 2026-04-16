import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { BadRequestException, Inject, Injectable, Logger } from '@nestjs/common';
import type { Cache } from 'cache-manager';

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
  transactionId: string;
  transactionRefId: string;
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

  constructor(@Inject(CACHE_MANAGER) private readonly cacheManager: Cache) {}

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
    const transactionId = (body.transactionId ?? '').toString();
    const transactionRefId = (body.transactionRefId ?? '').toString();

    if (response.ok && qrLink) {
      this.logger.log(
        `callGenerateQrApi success orderId=${payload.orderId} vietQrTransactionId=${transactionId}`,
      );
      return {
        qrLink,
        transactionId,
        transactionRefId,
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
      transactionId: body.transactionId,
      transactionRefId: body.transactionRefId,
      merchantName: body.merchantName,
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
}
