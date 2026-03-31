import os
from dataclasses import dataclass
from pathlib import Path

from dotenv import load_dotenv


@dataclass(frozen=True)
class Settings:
    mqtt_broker: str
    mqtt_port: int
    mqtt_username: str
    mqtt_password: str
    ca_cert_path: Path
    backend_base_url: str
    mqtt_service_token: str
    topic_current_location: str
    topic_signal: str
    topic_rescuer_handle: str
    topic_rescuer_common: str

    @classmethod
    def from_env(cls) -> "Settings":
        load_dotenv()
        base_dir = Path(__file__).resolve().parent.parent

        mqtt_broker = os.getenv("MQTT_BROKER", "").strip()
        if not mqtt_broker:
            raise ValueError("MQTT_BROKER is required")

        return cls(
            mqtt_broker=mqtt_broker,
            mqtt_port=int(os.getenv("MQTT_PORT", "8883")),
            mqtt_username=os.getenv("MQTT_USERNAME", ""),
            mqtt_password=os.getenv("MQTT_PASSWORD", ""),
            ca_cert_path=base_dir / os.getenv("CA_CERT_RELATIVE_PATH", "certs/emqxsl-ca.crt"),
            backend_base_url=os.getenv("BACKEND_BASE_URL", "http://localhost:3000"),
            mqtt_service_token=os.getenv("MQTT_SERVICE_TOKEN", ""),
            topic_current_location=os.getenv("TOPIC_CURRENT_LOCATION", "current-location"),
            topic_signal=os.getenv("TOPIC_SIGNAL", "signal"),
            topic_rescuer_handle=os.getenv("TOPIC_RESCUER_HANDLE", "rescuer/handle"),
            topic_rescuer_common=os.getenv("TOPIC_RESCUER_COMMON", "rescuer/common"),
        )
