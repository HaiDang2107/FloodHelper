# FloodHelper Development Runbook

## Prerequisites

- Node.js + npm
- Flutter SDK
- Python 3.x
- PostgreSQL
- Redis
- Docker + Docker Compose (optional)

## Backend

Working directory: backend.

### Install and Run

```bash
npm install
npm run start:dev
```

### Build and Tests

```bash
npm run build
npm run lint
npm run test
npm run test:e2e
```

### Prisma

```bash
npx prisma generate
npx prisma migrate dev
npm run db:seed
npx prisma studio
```

### Dockerized Infra

```bash
docker-compose up -d postgres
docker-compose up -d redis
```

## Frontend

Working directory: frontend.

```bash
flutter pub get
flutter run
flutter analyze lib
```

## MQTT Worker

Working directory: MqttClient.

```bash
pip install -r requirements.txt
python main.py
```

## Daily Charity Scheduler Check

The backend runs a daily cron task at 00:00 Asia/Ho_Chi_Minh for charity state transitions.

If you need to verify behavior:

1. Prepare test campaigns with boundary dates.
1. Run backend and inspect logs from CharityCampaignStateScheduler.
1. Validate resulting states in Prisma Studio.

## Common Troubleshooting

1. Cannot connect DB/Redis.

- Check containers with docker-compose ps.
- Verify env values in backend/.env.

1. Prisma type mismatch after schema change.

- Run npx prisma generate.
- Rebuild backend.

1. Frontend API mismatch.

- Confirm backend branch and frontend mapper/model field names align.
- Re-run flutter analyze lib.
