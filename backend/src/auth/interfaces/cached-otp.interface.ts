import { Purpose } from '../../common/enum/purpose.enum';

export interface CachedOtp {
  code: string;
  type: Purpose;
}
