# FloodHelper Data Flows

## 1) Authentication Flow (Frontend <-> Backend)

1. Frontend auth screens call backend auth endpoints.
2. Backend validates account/session and returns tokens/session payload.
3. Frontend updates global session provider state.
4. Protected feature providers consume current user/session from global provider.

## 2) Map Location Flow (Friend Visibility)

1. Frontend location tracking service receives device location updates.
2. Frontend publishes to `current-location` topic with:
   - user id
   - coordinates
   - allowed friend ids
   - SOS flag
3. MQTT worker receives `current-location` and republishes retained per-friend location topics.
4. Frontend subscribes to allowed friend topics and updates map pins.

## 3) SOS Signal Flow (Create / Update / Stop)

1. Frontend publishes command payload to `signal` topic (`CREATE`, `UPDATE-INFO`, `STOPPED`).
2. MQTT worker normalizes payload and calls backend signal endpoints:
   - `POST /signal`
   - `PATCH /signal/info/update-by-user`
   - `PATCH /signal/state/stop-by-user`
3. On stop, worker publishes `STOPPED` event to `rescuer/common`.
4. Frontend state updates remove/clear SOS indicators accordingly.

## 4) Rescuer Handle Flow

1. Rescuer action publishes to `rescuer/handle`.
2. MQTT worker calls `PATCH /signal/state/handle-by-user`.
3. Worker publishes:
   - user-specific reply topic `{userId}/rescuer-reply`
   - common event to `rescuer/common` (`HANDLED`)
4. Victim-side frontend consumes reply and clears active SOS state.

## 5) Broadcasting Signals Sheet Flow

1. Rescuer opens broadcasting sheet in frontend.
2. ViewModel calls backend `GET /signal/rescuer/broadcasting`.
3. Signals are sorted by user-defined criteria priority (persisted per rescuer).
4. Selecting a signal attempts map focus on victim pin.
5. If pin not available, sheet displays in-context message.

## Payload/Contract Notes

- Worker supports both legacy and new key aliases in signal data normalization.
- Topic names are env-driven in worker settings; maintain consistency across frontend/worker/backend.
- Signal state transitions in backend are authoritative and should drive UI truth over optimistic assumptions.
