import { Module } from '@nestjs/common';
import { RolesGuard } from '../auth/guards/roles.guard';
import { AuthorityCharityController } from './authority-charity.controller';
import { CharityController } from './charity.controller';
import { CharityService } from './charity.service';

@Module({
  controllers: [CharityController, AuthorityCharityController],
  providers: [CharityService, RolesGuard],
  exports: [CharityService],
})
export class CharityModule {}