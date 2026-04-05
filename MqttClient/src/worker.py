import json
import ssl
from typing import Any

import paho.mqtt.client as mqtt

from .api_client import BackendApiClient
from .settings import Settings


class MqttWorker:
    def __init__(self, settings: Settings, api_client: BackendApiClient) -> None:
        self.settings = settings
        self.api_client = api_client
        self.client = mqtt.Client(
            mqtt.CallbackAPIVersion.VERSION2,
            client_id="FastAPI_Location_Worker",
            clean_session=True,
        )

    @staticmethod
    def _debug(message: str) -> None:
        print(f"[MQTT-WORKER] {message}")

    def _publish(self, topic: str, payload: str, qos: int = 0, retain: bool = False) -> None:
        self._debug(
            f"Publishing topic={topic} qos={qos} retain={retain} payload={payload}"
        )
        result = self.client.publish(topic, payload=payload, qos=qos, retain=retain)
        if result.rc == mqtt.MQTT_ERR_SUCCESS:
            self._debug(f"Publish success topic={topic} rc={result.rc}")
        else:
            self._debug(f"Publish failed topic={topic} rc={result.rc}")

    @staticmethod
    def _normalize_signal_data(raw_data: dict[str, Any]) -> dict[str, Any]:
        return {
            "trappedCount": raw_data.get("trappedCount", raw_data.get("trappedCounts")),
            "childrenNum": raw_data.get("childrenNum", raw_data.get("childrenNumbers")),
            "elderlyNum": raw_data.get("elderlyNum", raw_data.get("elderlyNumbers")),
            "hasFood": raw_data.get("hasFood"),
            "hasWater": raw_data.get("hasWater"),
            "note": raw_data.get("note", raw_data.get("other")),
        }

    def _handle_current_location(self, data: dict[str, Any]) -> None:
        lat = data.get("lat")
        lng = data.get("lng")
        sender_user = data.get("user")
        fullname = data.get("fullname")
        allowed_friends = data.get("allowed_friends", [])
        is_sos = bool(data.get("isSoS", False))

        if lat is None or lng is None or not sender_user:
            # self._debug(f"Invalid current-location payload: {data}")
            return

        location_payload = json.dumps({"lat": lat, "lng": lng})
        for friend_id in allowed_friends:
            target_topic = f"{sender_user}/to_{friend_id}/last-location"
            self._publish(
                target_topic,
                payload=location_payload,
                qos=0,
                retain=True,
            )

        if is_sos:
            rescuer_payload = json.dumps(
                {
                    "userId": sender_user,
                    "fullname": fullname,
                    "lat": lat,
                    "long": lng,
                }
            )
            self._publish(
                self.settings.topic_rescuer_common,
                payload=rescuer_payload,
                qos=0,
                retain=False,
            )

    def _handle_signal_command(self, data: dict[str, Any]) -> None:
        command = str(data.get("command", "")).upper()

        if command == "CREATE":
            created_by = data.get("created_by")
            payload = self._normalize_signal_data(dict(data.get("data") or {}))
            if not created_by:
                self._debug("CREATE signal missing created_by")
                return
            payload["createdBy"] = created_by
            self.api_client.call("POST", "/signal", payload)
            return

        if command == "UPDATE-INFO":
            updated_by = data.get("updated_by")
            payload = self._normalize_signal_data(dict(data.get("data") or {}))
            if not updated_by:
                self._debug("UPDATE-INFO missing updated_by")
                return
            payload["updatedBy"] = updated_by
            self.api_client.call("PATCH", "/signal/info/update-by-user", payload)
            return

        if command in {"STOP", "STOPPED"}:
            stopped_by = data.get("stopped_by")
            if not stopped_by:
                self._debug("STOPPED signal missing stopped_by")
                return

            response = self.api_client.call(
                "PATCH",
                "/signal/state/stop-by-user",
                {
                    "createdBy": stopped_by,
                },
            )

            if response is None:
                self._debug(f"Failed to stop broadcasting signal for user {stopped_by}")
                return

            signal = response.get("data") if isinstance(response, dict) else None
            user = signal.get("user") if isinstance(signal, dict) else None

            self._publish(
                self.settings.topic_rescuer_common,
                payload=json.dumps(
                    {
                        "type": "STOPPED",
                        "userId": stopped_by,
                        "fullname": (
                            user.get("fullname")
                            if isinstance(user, dict)
                            else None
                        ),
                    }
                ),
                qos=1,
                retain=False,
            )
            return

        self._debug(f"Unsupported signal command: {command}")

    def _handle_rescuer_handle(self, data: dict[str, Any]) -> None:
        handled_by = data.get("handled_by") or data.get("handledBy")
        user_id = data.get("userId") or data.get("created_by")

        if not handled_by or not user_id:
            self._debug("rescuer/handle missing handled_by or userId")
            return

        response = self.api_client.call(
            "PATCH",
            "/signal/state/handle-by-user",
            {
                "userId": user_id,
                "handledBy": handled_by,
            },
        )

        if response is None:
            self._debug(f"Failed to mark broadcasting signal as handled for user {user_id}")
            return

        signal = response.get("data") if isinstance(response, dict) else None
        handled_by_user = (
            signal.get("handledByUser") if isinstance(signal, dict) else None
        )
        handled_fullname = (
            handled_by_user.get("fullname")
            if isinstance(handled_by_user, dict)
            else None
        )

        reply_topic = f"{user_id}/rescuer-reply"
        self._publish(
            reply_topic,
            payload=json.dumps(
                {
                    "rescuer_fullname": handled_fullname,
                    "handled_by": handled_by,
                }
            ),
            qos=1,
            retain=False,
        )

        self._publish(
            self.settings.topic_rescuer_common,
            payload=json.dumps(
                {
                    "type": "HANDLED",
                    "userId": user_id,
                    "handled_by": handled_by,
                    "rescuer_fullname": handled_fullname,
                }
            ),
            qos=1,
            retain=False,
        )

    def on_connect(self, client, userdata, flags, reason_code, properties) -> None:
        if reason_code == 0:
            self._debug(f"MQTT connected at port {self.settings.mqtt_port}")
            client.subscribe(self.settings.topic_current_location, qos=0)
            client.subscribe(self.settings.topic_signal, qos=1)
            client.subscribe(self.settings.topic_rescuer_handle, qos=1)
            self._debug(
                "Subscribed: "
                f"{self.settings.topic_current_location}, "
                f"{self.settings.topic_signal}, "
                f"{self.settings.topic_rescuer_handle}"
            )
        else:
            self._debug(f"MQTT connect failed with rc={reason_code}")

    def on_message(self, client, userdata, msg) -> None:
        try:
            data = json.loads(msg.payload.decode("utf-8"))
            self._debug(f"Received topic={msg.topic} payload={data}")

            if msg.topic == self.settings.topic_current_location:
                self._handle_current_location(data)
                return

            self._debug(f"Received topic={msg.topic} payload={data}")

            if msg.topic == self.settings.topic_signal:
                self._handle_signal_command(data)
                return

            if msg.topic == self.settings.topic_rescuer_handle:
                self._handle_rescuer_handle(data)
                return

            self._debug(f"Received message on unsupported topic {msg.topic}")
        except json.JSONDecodeError:
            self._debug(f"Invalid JSON payload on topic={msg.topic}: {msg.payload!r}")
        except Exception as exc:
            self._debug(f"Message processing error: {exc}")

    def start(self) -> None:
        if not self.settings.ca_cert_path.exists():
            raise FileNotFoundError(f"CA cert not found at: {self.settings.ca_cert_path}")

        self.client.on_connect = self.on_connect
        self.client.on_message = self.on_message
        self.client.username_pw_set(self.settings.mqtt_username, self.settings.mqtt_password)
        self.client.tls_set(
            ca_certs=str(self.settings.ca_cert_path),
            tls_version=ssl.PROTOCOL_TLSv1_2,
        )
        self.client.connect_async(self.settings.mqtt_broker, self.settings.mqtt_port, keepalive=60)
        self.client.loop_start()

    def stop(self) -> None:
        self.client.loop_stop()
        self.client.disconnect()

    def is_connected(self) -> bool:
        return self.client.is_connected()
