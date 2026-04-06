# FloodHelper Codebase Map

## Top-Level Directory Guide

- `backend/`: API server and database layer.
- `frontend/`: Flutter app.
- `MqttClient/`: MQTT-to-backend bridge service.
- `diagram/`: Design diagrams.
- `docs/`: Project documentation.

## Backend Map

### Entry and Composition

- `backend/src/main.ts`: NestJS bootstrap.
- `backend/src/app.module.ts`: Main module imports and global infra wiring.

### Notable Modules (Observed from app module + tree)

- `auth/`: authentication, guards, strategies, DTOs.
- `user/`: user profile and visibility operations.
- `friend/`: friendship and friend request flows.
- `signal/`: distress signal APIs (create/update/stop/handle/list).
- `firebase/`: Firebase admin service integration.
- `role-request/`: role escalation/request management.

### Data Layer

- `backend/prisma/schema/`: split Prisma schema files by domain.
- `backend/prisma/seed.ts`: seed script entry.
- `backend/prisma/migrations/`: migration history.

### Backend Docs

- `backend/docs/AUTH_API_DOCUMENTATION.md`: auth endpoint contract notes.
- `backend/DOCKER_README.md`: dockerized backend setup guidance.

## Frontend Map

### App Entry

- `frontend/lib/main.dart`: Flutter app bootstrap + Firebase init + background service init.
- `frontend/lib/app.dart`: root `MaterialApp` configuration.
- `frontend/lib/routing/routes.dart`: route table.

### UI Domains

- `frontend/lib/ui/home/`: map-centric main experience (pins, sheets, actions).
- `frontend/lib/ui/auth/`: sign in/up/forgot password.
- `frontend/lib/ui/profile/`: user profile and role request UI.
- `frontend/lib/ui/authority/`: authority-facing flows.
- `frontend/lib/ui/charity_campaign/`: charity features.

### Data + State

- `frontend/lib/data/services/`: API clients, MQTT/location services, storage helpers.
- `frontend/lib/data/repositories/`: repository abstraction.
- `frontend/lib/data/providers/`: Riverpod providers and session state.
- `frontend/lib/ui/**/view_models/`: feature-level ViewModel notifiers and state.

## MQTT Worker Map

### Entry and Runtime

- `MqttClient/main.py`: uvicorn launcher.
- `MqttClient/src/app.py`: FastAPI app lifecycle; starts/stops MQTT worker.

### MQTT Bridge

- `MqttClient/src/worker.py`: MQTT topic handlers and publish/call orchestration.
- `MqttClient/src/settings.py`: env-based settings and topic names.
- `MqttClient/src/api_client.py`: backend HTTP caller.

### Config

- `MqttClient/.env.example`: required MQTT/backend env variables.
- `MqttClient/docker-compose.yml`: worker container setup.

## Useful Navigation Heuristics

- Search for `@Controller('signal')` for rescue signal APIs.
- Search for `topic_rescuer_common` to follow rescuer event fanout.
- Search for `homeViewModelProvider` for home map orchestration.
- Search for `BroadcastingSignals` for rescuer broadcasting sheet/sort flow.
