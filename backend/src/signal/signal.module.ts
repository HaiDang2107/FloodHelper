import { Module } from '@nestjs/common';
import { SignalController } from './signal.controller';
import { SignalService } from './signal.service';
import { ServiceTokenGuard } from './guards/service-token.guard';
import { RolesGuard } from '../auth/guards/roles.guard';

@Module({
  controllers: [SignalController],
  providers: [SignalService, ServiceTokenGuard, RolesGuard],
  exports: [SignalService],
})
export class SignalModule {}
