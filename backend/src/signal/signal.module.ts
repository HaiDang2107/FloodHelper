import { Module } from '@nestjs/common';
import { SignalController } from './signal.controller';
import { SignalService } from './signal.service';
import { ServiceTokenGuard } from './guards/service-token.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { PrismaRepositoryModule } from '../prisma/repositories/prisma-repository.module';
import { FirebaseModule } from '../firebase/firebase.module';

@Module({
  imports: [PrismaRepositoryModule, FirebaseModule],
  controllers: [SignalController],
  providers: [SignalService, ServiceTokenGuard, RolesGuard],
  exports: [SignalService],
})
export class SignalModule {}
