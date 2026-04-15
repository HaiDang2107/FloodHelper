# FloodHelper Codebase Map

## Top-Level

- backend: NestJS API + Prisma + Redis + Mailer + Firebase Admin
- frontend: Flutter application (user and authority flows)
- MqttClient: Python FastAPI MQTT bridge for realtime signal/location
- diagram: UML and activity/use-case assets
- docs: project documentation

## Backend Map

### Backend Entry

- backend/src/main.ts: bootstrap, cookie parser, CORS
- backend/src/app.module.ts: module composition + ScheduleModule + Cache + Mailer

### Modules

- backend/src/auth
- backend/src/user
- backend/src/friend
- backend/src/role-request
- backend/src/signal
- backend/src/charity
- backend/src/firebase

### Charity Subsystem

- backend/src/charity/charity.controller.ts: existing/mine/detail/create/update/send-request
- backend/src/charity/authority-charity.controller.ts: authority list/detail/approve/reject
- backend/src/charity/charity.service.ts: business logic + validation + pagination/sorting
- backend/src/charity/charity-campaign-state.scheduler.ts: daily state transition cron at 00:00 Asia/Ho_Chi_Minh

### Database

- backend/prisma/schema: split schema by domain
- backend/prisma/migrations: migration history
- backend/prisma/seed.ts: seed entry

## Frontend Map

### Frontend Entry

- frontend/lib/main.dart
- frontend/lib/app.dart
- frontend/lib/routing

### Key Domains

- frontend/lib/ui/auth
- frontend/lib/ui/home
- frontend/lib/ui/profile
- frontend/lib/ui/authority
- frontend/lib/ui/charity_campaign

### Data Layer

- frontend/lib/data/services
- frontend/lib/data/repositories
- frontend/lib/data/providers
- frontend/lib/domain/models

## MQTT Worker Map

- MqttClient/src/app.py
- MqttClient/src/worker.py
- MqttClient/src/settings.py
- MqttClient/src/api_client.py

## Documentation Pointers

- docs/SYSTEM_OVERVIEW.md
- docs/DATA_FLOWS.md
- docs/RUNBOOK.md
- backend/README.md
- backend/src/auth/README.md
