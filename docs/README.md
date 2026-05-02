# FloodHelper Documentation Index

This folder contains project-level documentation curated for both developers and AI assistants.

## Documents

- `SYSTEM_OVERVIEW.md`: High-level architecture, major services, and integration points.
- `CODEBASE_MAP.md`: Where key features live in the repository (frontend, backend, worker, diagrams).
- `RUNBOOK.md`: Setup, run, test, seed, and common troubleshooting commands.
- `DATA_FLOWS.md`: Runtime flows for authentication, map location sync, SOS signaling, and rescuer handling.

## Suggested Reading Order

1. `SYSTEM_OVERVIEW.md`
2. `CODEBASE_MAP.md`
3. `DATA_FLOWS.md`
4. `RUNBOOK.md`

## Scope Note

These docs are intentionally practical and repository-specific. They summarize currently observed structure and behavior from source files and existing READMEs.

## Frontend Architecture Update (Home MVVM)

The Home feature in frontend has been refactored from one large ViewModel file into a composition-root plus focused mixins, while keeping Riverpod provider behavior unchanged.

Current structure (under `frontend/lib/ui/home/view_models`):

- `home_view_model.dart`: composition root (provider class, dependency initialization, lifecycle hooks, mixin composition)
- `home_state.dart`: state contract shared by all Home modules
- `home_runtime_mixin.dart`: runtime and realtime flows (tracking, MQTT subscriptions, visibility logic, SOS lifecycle)
- `home_campaign_map_mixin.dart`: campaign/map behavior (campaign pins, map focus/select logic, campaign detail loading from map)
- `home_content_mixin.dart`: content features (posts, announcements, nearby users, camera action)
- `home_ui_feedback_mixin.dart`: UI feedback channel (event emit/clear, foreground message handling, error clear)

Design intent:

- Reduce file size and cognitive load for Home feature maintenance.
- Keep highly coupled runtime logic together to avoid fragile cross-file dependencies.
- Keep low-coupling domains separated by feature ownership (campaign/map vs content vs ui-feedback).
