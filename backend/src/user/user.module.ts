import { Module } from '@nestjs/common';
import { UserService } from './user.service';
import { UserController } from './user.controller';
import { CloudinaryService } from '../common/cloudinary.service';
import { PrismaRepositoryModule } from '../prisma/repositories/prisma-repository.module';

@Module({
  imports: [PrismaRepositoryModule],
  controllers: [UserController],
  providers: [UserService, CloudinaryService],
  exports: [UserService],
})
export class UserModule {}
