import { Module } from '@nestjs/common';
import { CommonModule } from '../common/common.module';
import { FirebaseModule } from '../firebase/firebase.module';
import { PrismaModule } from '../prisma/prisma.module';
import { PrismaRepositoryModule } from '../prisma/repositories/prisma-repository.module';
import { RolesGuard } from '../auth/guards/roles.guard';
import { AnnouncementController } from './announcement.controller';
import { AnnouncementAuthorityService } from './announcement-authority.service';
import { AnnouncementNoruserService } from './announcement-noruser.service';

@Module({
  imports: [CommonModule, PrismaModule, PrismaRepositoryModule, FirebaseModule],
  controllers: [AnnouncementController],
  providers: [AnnouncementAuthorityService, AnnouncementNoruserService, RolesGuard],
  exports: [AnnouncementAuthorityService, AnnouncementNoruserService],
})
export class AnnouncementModule {}