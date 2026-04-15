# FloodHelper Backend

NestJS backend for FloodHelper, using Prisma + PostgreSQL, Redis cache, JWT auth, role guards, Firebase Admin integration, and scheduled tasks.

## Current Module Structure

- src/auth: signup/signin/refresh/password/auth guards
- src/user: profile and user-related operations
- src/friend: friend requests and friendships
- src/role-request: role escalation workflow
- src/signal: SOS signal lifecycle and rescuer handling
- src/charity: charity campaigns for benefactor, authority review, and daily state transitions
- src/firebase: Firebase Admin utilities
- src/common: shared middleware and enums

## Charity Highlights

- Benefactor flow: create, update, send request
- Authority flow: list/detail/approve/reject
- Daily scheduler at 00:00 Asia/Ho_Chi_Minh transitions campaign states by date:
  - APPROVED to DONATING
  - DONATING to DISTRIBUTING
  - DONATING to FINISHED

Implementation files:

- src/charity/charity.service.ts
- src/charity/authority-charity.controller.ts
- src/charity/charity.controller.ts
- src/charity/charity-campaign-state.scheduler.ts

## Setup

1. Install dependencies.

```bash
npm install
```

1. Configure environment.

```bash
cp .env.example .env
```

1. Prepare database.

```bash
npx prisma generate
npx prisma migrate dev
npm run db:seed
```

1. Run backend.

```bash
npm run start:dev
```

## Useful Commands

```bash
npm run build
npm run lint
npm run test
npm run test:e2e
npx prisma studio
```

## Notes

- CORS is enabled for development in src/main.ts.
- Refresh token is delivered via httpOnly cookie on signin flow.
- Source code is the canonical contract. Keep docs in sync with controller/service behavior.
