# FloodHelper System Overview

## Monorepo Structure

FloodHelper is organized as a single repository with multiple application layers:

- `frontend/`: Flutter mobile/web client.
- `backend/`: NestJS REST API + Prisma + Redis cache + Mailer + Firebase admin integration.
- `MqttClient/`: Python FastAPI process that bridges MQTT topics and backend signal APIs.
- `diagram/`: UML and activity/use-case assets.
- `docs/`: Curated operational and architectural documentation (this folder).

## Core Technology Stack

### Frontend

- Flutter + Dart
- Riverpod state management
- `flutter_map` for map rendering
- Firebase (core + messaging)
- MQTT client for realtime location/signal topic communication
- Background service on Android for location tracking/publishing

### Backend

- NestJS (TypeScript)
- Prisma ORM + PostgreSQL
- Redis (cache manager)
- JWT auth + role guards
- Firebase Admin SDK (notifications)
- Mailer module

### MQTT Worker Service

- Python + FastAPI
- Paho MQTT client
- Requests-based backend API calls
- TLS connection to broker
- Subscribes to:
  - `current-location`
  - `signal`
  - `rescuer/handle`

## Runtime Topology

1. Client app obtains user session from backend (JWT/cookies depending flow).
2. Client publishes location and signal commands to MQTT topics.
3. Python worker consumes MQTT, normalizes payloads, and calls backend signal endpoints.
4. Worker republishes derived events to rescuer/common or user-specific reply topics.
5. Frontend map and sheets react to these events to render friend/victim pins and state.

## Feature Domains (Observed)

- Authentication and session management
- Friend requests and friend map visibility
- Map presence and location sharing modes
- SOS broadcasting and rescuer handling
- Profile and role request flows
- Posts/announcements/charity related UI domains

## Key Constraints and Patterns

- Backend modules are centralized in `backend/src/app.module.ts`.
- Signal and MQTT integration depend on strict topic + payload contract.
- Frontend logic uses ViewModel-style Riverpod notifiers and sheet-based interaction patterns.
- Some docs under backend are generic Nest starter docs; source code should be treated as canonical behavior.
