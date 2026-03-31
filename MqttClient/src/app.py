from contextlib import asynccontextmanager

from fastapi import FastAPI

from .api_client import BackendApiClient
from .settings import Settings
from .worker import MqttWorker

settings = Settings.from_env()
api_client = BackendApiClient(settings)
worker = MqttWorker(settings, api_client)


@asynccontextmanager
async def lifespan(app: FastAPI):
    print("Starting FastAPI MQTT Worker...")
    worker.start()
    yield
    print("Stopping FastAPI MQTT Worker...")
    worker.stop()
    print("MQTT client disconnected")


app = FastAPI(lifespan=lifespan)


@app.get("/")
async def health_check():
    mqtt_status = "Connected" if worker.is_connected() else "Disconnected"
    return {
        "status": "API Server runs",
        "mqtt_worker": mqtt_status,
    }
