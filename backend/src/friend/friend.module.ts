import { Module } from '@nestjs/common';
import { FriendController } from './friend.controller';
import { FriendService } from './friend.service';
import { PrismaRepositoryModule } from '../prisma/repositories/prisma-repository.module';

@Module({
  imports: [PrismaRepositoryModule],
  controllers: [FriendController],
  providers: [FriendService],
  exports: [FriendService],
})
export class FriendModule {}
