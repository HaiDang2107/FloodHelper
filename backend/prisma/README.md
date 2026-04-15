# Prisma Guide

This backend uses Prisma with a split schema layout under prisma/schema.

## Current Prisma Structure

- prisma/schema: domain-based schema files
  - user.prisma
  - charity.prisma
  - social.prisma
  - chat.prisma
  - rescue.prisma
  - admin_action.prisma
  - weather_map.prisma
  - base.prisma
- prisma/migrations: migration history
- prisma/seed.ts: main seed entry used by npm run db:seed
- prisma/charity_seed.ts: charity-specific seed helper
- prisma/signal_seed.ts: signal-specific seed helper
- prisma/account_seed.ts: account/user seed helper

## Common Commands

```bash
npx prisma generate
npx prisma migrate dev
npx prisma migrate deploy
npx prisma studio
npm run db:seed
```

## Charity Timeline Fields

Current campaign timeline naming (hard cutover):

- startedDonationAt
- finishedDonationAt
- startedDistributionAt
- finishedDistributionAt

These names are used consistently across Prisma schema, backend DTO/service, and frontend mapping.

## Scheduler Dependency

Daily state transition scheduler reads these timeline fields and updates campaign state at 00:00 Asia/Ho_Chi_Minh.
