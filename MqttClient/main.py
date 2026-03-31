import json
import os
import ssl
from contextlib import asynccontextmanager

import paho.mqtt.client as mqtt
import requests
from dotenv import load_dotenv
from fastapi import FastAPI

load_dotenv()

MQTT_BROKER = os.getenv("MQTT_BROKER")
MQTT_PORT = int(os.getenv("MQTT_PORT", 8883))
MQTT_USERNAME = os.getenv("MQTT_USERNAME", "")
MQTT_PASSWORD = os.getenv("MQTT_PASSWORD", "")
CA_CERT_RELATIVE_PATH = "certs/emqxsl-ca.crt"

BACKEND_BASE_URL = os.getenv("BACKEND_BASE_URL", "http://localhost:3000")
MQTT_SERVICE_TOKEN = os.getenv("MQTT_SERVICE_TOKEN", "")

TOPIC_CURRENT_LOCATION = os.getenv("TOPIC_CURRENT_LOCATION", "current-location")
TOPIC_SIGNAL = os.getenv("TOPIC_SIGNAL", "signal")
TOPIC_RESCUER_HANDLE = os.getenv("TOPIC_RESCUER_HANDLE", "rescuer/handle")
TOPIC_RESCUER_COMMON = os.getenv("TOPIC_RESCUER_COMMON", "rescuer/common")


def _http_headers() -> dict:
    return {
        "Authorization": f"Bearer {MQTT_SERVICE_TOKEN}",
        "Content-Type": "application/json",
    }


def _api_call(method: str, path: str, payload: dict | None = None) -> dict | None:
    url = f"{BACKEND_BASE_URL.rstrip('/')}{path}"
    response = requests.request(
        method=method,
        url=url,
        headers=_http_headers(),
        json=payload,
        timeout=10,
    )

    if response.status_code >= 400:
        print(f"⚠️ API {method} {path} failed: {response.status_code} {response.text}")
        return None

    try:
        return response.json()
    except ValueError:
        return None


mqtt_client = mqtt.Client(
    mqtt.CallbackAPIVersion.VERSION1,
    client_id="FastAPI_Location_Worker",
    clean_session=True,
)


def _handle_current_location(client: mqtt.Client, data: dict):
    lat = data.get("lat")
    lng = data.get("lng")
    sender_user = data.get("user")
    allowed_friends = data.get("allowed_friends", [])
    is_sos = bool(data.get("isSoS", False))

    if lat is None or lng is None or not sender_user:
        print("⚠️ Invalid current-location payload")
        return

    location_payload = json.dumps({"lat": lat, "lng": lng})
    for friend_id in allowed_friends:
        target_topic = f"{sender_user}/to_{friend_id}/last-location"
        result = client.publish(
            target_topic,
            payload=location_payload,
            qos=0,
            retain=True,
        )
        if result.rc != mqtt.MQTT_ERR_SUCCESS:
            print(f"❌ Failed to publish to {target_topic}")

    if is_sos:
        rescuer_payload = json.dumps(
            {
                "userId": sender_user,
                "lat": lat,
                "long": lng,
            }
        )
        client.publish(TOPIC_RESCUER_COMMON, payload=rescuer_payload, qos=0, retain=False)


def _handle_signal_command(data: dict):
    command = str(data.get("command", "")).upper()

    if command == "CREATE":
        created_by = data.get("created_by")
        payload = dict(data.get("data") or {})
        if not created_by:
            print("⚠️ CREATE signal missing created_by")
            return
        payload["createdBy"] = created_by
        _api_call("POST", "/signal", payload)
        return

    if command == "UPDATE-INFO":
        updated_by = data.get("updated_by")
        payload = dict(data.get("data") or {})
        if not updated_by:
            print("⚠️ UPDATE-INFO missing updated_by")
            return

        # Backend resolves active BROADCASTING signal from updatedBy.
        payload["updatedBy"] = updated_by
        _api_call("PATCH", "/signal/info/update-by-user", payload)
        return

    if command in {"STOP", "STOPPED"}:
        stopped_by = data.get("stopped_by")
        _api_call(
            "PATCH",
            "/signal/state/stop-by-user",
            {
                "createdBy": stopped_by,
            },
        )
        return

    print(f"⚠️ Unsupported signal command: {command}")


def _handle_rescuer_handle(client: mqtt.Client, data: dict):
    handled_by = data.get("handled_by")
    user_id = data.get("userId")

    if not handled_by or not user_id:
        print("⚠️ rescuer/handle missing handled_by or userId")
        return

    response = _api_call(
        "PATCH",
        "/signal/state/handle-by-user",
        {
            "userId": user_id,
            "handledBy": handled_by,
        },
    )

    if response is None:
        print(f"⚠️ Failed to mark broadcasting signal as handled for user {user_id}")
        return

    reply_topic = f"{user_id}/rescuer-reply"
    client.publish(
        reply_topic,
        payload=json.dumps({"handled_by": handled_by}),
        qos=1,
        retain=False,
    )


def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print(f"✅ MQTT connected at port {MQTT_PORT}")
        client.subscribe(TOPIC_CURRENT_LOCATION, qos=0)
        client.subscribe(TOPIC_SIGNAL, qos=0)
        client.subscribe(TOPIC_RESCUER_HANDLE, qos=0)
        print(
            f"🎧 Subscribed: {TOPIC_CURRENT_LOCATION}, {TOPIC_SIGNAL}, {TOPIC_RESCUER_HANDLE}"
        )
    else:
        print(f"❌ MQTT connect failed with rc={rc}")


def on_message(client, userdata, msg):
    try:
        payload_raw = msg.payload.decode("utf-8")
        data = json.loads(payload_raw)

        if msg.topic == TOPIC_CURRENT_LOCATION:
            _handle_current_location(client, data)
            return

        if msg.topic == TOPIC_SIGNAL:
            _handle_signal_command(data)
            return

        if msg.topic == TOPIC_RESCUER_HANDLE:
            _handle_rescuer_handle(client, data)
            return

        print(f"⚠️ Received message on unsupported topic {msg.topic}")
    except json.JSONDecodeError:
        print("⚠️ Invalid JSON payload")
    except Exception as exc:
        print(f"⚠️ Message processing error: {exc}")


@asynccontextmanager
async def lifespan(app: FastAPI):
    print("\nStarting FastAPI MQTT Worker...")

    mqtt_client.on_connect = on_connect
    mqtt_client.on_message = on_message
    mqtt_client.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD)

    base_path = os.path.dirname(os.path.abspath(__file__))
    ca_cert_absolute_path = os.path.join(base_path, CA_CERT_RELATIVE_PATH)

    try:
        mqtt_client.tls_set(
            ca_certs=ca_cert_absolute_path,
            tls_version=ssl.PROTOCOL_TLSv1_2,
        )
    except FileNotFoundError:
        print(f"❌ CA cert not found at: {ca_cert_absolute_path}")
        os._exit(1)

    mqtt_client.connect_async(MQTT_BROKER, MQTT_PORT, keepalive=60)
    mqtt_client.loop_start()

    yield

    print("\nStopping FastAPI MQTT Worker...")
    mqtt_client.loop_stop()
    mqtt_client.disconnect()
    print("MQTT client disconnected")


app = FastAPI(lifespan=lifespan)


@app.get("/")
async def health_check():
    mqtt_status = "Connected" if mqtt_client.is_connected() else "Disconnected"
    return {
        "status": "API Server runs",
        "mqtt_worker": mqtt_status,
    }