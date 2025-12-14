import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { UserModule } from '../user/user.module';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Account } from './entities/account.entity';
import { Session } from './entities/session.entity';
import { Provider } from './entities/provider.entity';
import { AccountStateLog } from './entities/accountStateLog.entity'; 

@Module({
  imports: [
    UserModule,
    TypeOrmModule.forFeature([Account, Session, Provider, AccountStateLog]),
  ],
  controllers: [AuthController],
  providers: [AuthService],
})
export class AuthModule {}
