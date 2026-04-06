# FloodHelper Development Runbook

## Prerequisites

- Node.js + npm
- Flutter SDK
- Python 3.x (for MQTT worker)
- Docker + Docker Compose (optional/local infra)
- PostgreSQL + Redis (or Dockerized equivalents)

## Backend Runbook

Working directory: `backend/`

### Install and Start

```bash
npm install
npm run start:dev
```

### Database

```bash
npx prisma generate
npx prisma migrate dev
npm run db:seed
```

### Tests and Lint

```bash
npm run test
npm run test:e2e
npm run lint
```

### Dockerized Infra (postgres + redis)

```bash
docker-compose up -d postgres
docker-compose up -d redis
```

## Frontend Runbook

Working directory: `frontend/`

### Install and Run

```bash
flutter pub get
flutter run
```

### Static Analysis and Formatting

```bash
flutter analyze
dart format lib
```

## MQTT Worker Runbook

Working directory: `MqttClient/`

### Install and Run Locally

```bash
pip install -r requirements.txt
python main.py
```

### Env Setup

Copy `.env.example` to `.env`, then configure:

- `MQTT_BROKER`, `MQTT_PORT`, `MQTT_USERNAME`, `MQTT_PASSWORD`
- `BACKEND_BASE_URL`
- `MQTT_SERVICE_TOKEN`
- Topics:
  - `TOPIC_CURRENT_LOCATION`
  - `TOPIC_SIGNAL`
  - `TOPIC_RESCUER_HANDLE`
  - `TOPIC_RESCUER_COMMON`

### Docker

```bash
docker-compose up --build
```

## Common Troubleshooting

### Backend cannot reach DB/Redis

- Verify containers are up: `docker-compose ps` in `backend/`.
- Check `.env` host/port values.
- Re-run `npx prisma migrate dev`.

### Worker starts but no signal updates

- Verify MQTT topic names match frontend/backend expectations.
- Check `MQTT_SERVICE_TOKEN` for backend protected endpoints.
- Confirm broker TLS cert path and credentials.
- Inspect worker logs for payload normalization or unsupported command output.

### Frontend map/sheet behavior mismatch

- Run `flutter analyze` on changed files.
- Validate callback contracts between Home screen and sheet widgets.
- Confirm local storage keys are cleared on sign out when testing per-user preferences.

## Quick Start Sequence (End-to-End)

1. Start postgres + redis.
2. Run backend migrations + seed.
3. Start backend in dev mode.
4. Start MQTT worker.
5. Run Flutter app.
