# FloodHelper System Overview

## Architecture

FloodHelper is a multi-service repository:

1. Frontend (Flutter).

- Mobile/web client with Riverpod state management.
- User, benefactor, rescuer, and authority interfaces.

1. Backend (NestJS).

- REST APIs and business logic.
- Prisma ORM over PostgreSQL.
- Redis cache manager.
- JWT and role-based authorization.
- Firebase Admin integration.
- Daily scheduled jobs via NestJS Schedule.

1. MQTT Worker (Python FastAPI).

- Consumes MQTT commands/events.
- Calls backend signal APIs.
- Republishes normalized events to topics used by frontend.

## Current Backend Runtime Notes

- Cookie parser enabled for refresh token cookie flow.
- CORS enabled for development.
- ScheduleModule enabled globally in AppModule.

## Charity Lifecycle Automation

Charity module includes a scheduled job that runs at 00:00 Asia/Ho_Chi_Minh and applies date-based state transitions:

- APPROVED to DONATING.
- DONATING to DISTRIBUTING.
- DONATING to FINISHED.

Date comparison uses day boundaries in Vietnam timezone and ignores hour/minute/second semantics.

## Main Feature Domains

- Authentication and session lifecycle.
- Friend relationships and requests.
- Role request workflow.
- SOS signaling and rescuer coordination.
- Charity campaign creation/review/processing.
- User profile and visibility controls.

## Source of Truth

When docs differ from implementation, treat controller/service code and Prisma schema as authoritative.
