import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma.module';
import {
  UserRepository,
  FriendRepository,
  SignalRepository,
  AnnouncementRepository,
  CharityRepository,
  RoleRequestRepository,
  ChatRepository,
  AuthRepository,
  LocationRepository,
} from './index';

const repositories = [
  UserRepository,
  FriendRepository,
  SignalRepository,
  AnnouncementRepository,
  CharityRepository,
  RoleRequestRepository,
  ChatRepository,
  AuthRepository,
  LocationRepository,
];

/**
 * PrismaRepositoryModule
 * 
 * Centralized module that provides all repository services
 * for database access. This module should replace direct
 * Prisma usage in service files.
 * 
 * Usage:
 * @Module({
 *   imports: [PrismaRepositoryModule],
 * })
 */
@Module({
  imports: [PrismaModule],
  providers: repositories,
  exports: repositories,
})
export class PrismaRepositoryModule {}
