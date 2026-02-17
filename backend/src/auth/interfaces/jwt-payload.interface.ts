import { Purpose } from '../../common/enum/purpose.enum'; 

export interface JwtPayload {
  sub: string; // accountId
  deviceId: string;
  username: string;
  roles: string[];
  purpose: Purpose;
}