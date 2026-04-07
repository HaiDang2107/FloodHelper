import { Module } from '@nestjs/common';
import { RolesGuard } from '../auth/guards/roles.guard';
import { CharityController } from './charity.controller';
import { CharityService } from './charity.service';

@Module({
  controllers: [CharityController],
  providers: [CharityService, RolesGuard],
  exports: [CharityService],
})
export class CharityModule {}