import { Module } from '@nestjs/common';
import { RoleRequestController } from './role-request.controller';
import { RoleRequestService } from './role-request.service';
import { RolesGuard } from '../auth/guards/roles.guard';

@Module({
  controllers: [RoleRequestController],
  providers: [RoleRequestService, RolesGuard],
  exports: [RoleRequestService],
})
export class RoleRequestModule {}
