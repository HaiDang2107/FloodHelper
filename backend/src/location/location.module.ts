import { Module } from '@nestjs/common';
import { LocationController } from './location.controller';
import { LocationService } from './location.service';
import { PrismaRepositoryModule } from '../prisma/repositories/prisma-repository.module';

@Module({
  imports: [PrismaRepositoryModule],
  controllers: [LocationController],
  providers: [LocationService],
  exports: [LocationService],
})
export class LocationModule {}