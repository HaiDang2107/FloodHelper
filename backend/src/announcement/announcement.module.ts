import { Module } from '@nestjs/common';
import { CommonModule } from '../common/common.module';
import { FirebaseModule } from '../firebase/firebase.module';
import { PrismaModule } from '../prisma/prisma.module';
import { RolesGuard } from '../auth/guards/roles.guard';
import { AnnouncementController } from './announcement.controller';
import { AnnouncementService } from './announcement.service';

@Module({
  imports: [CommonModule, PrismaModule, FirebaseModule],
  controllers: [AnnouncementController],
  providers: [AnnouncementService, RolesGuard],
  exports: [AnnouncementService],
})
export class AnnouncementModule {}