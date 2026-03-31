from typing import Any

import requests

from .settings import Settings


class BackendApiClient:
    def __init__(self, settings: Settings) -> None:
        self._settings = settings

    def _headers(self) -> dict[str, str]:
        return {
            "Authorization": f"Bearer {self._settings.mqtt_service_token}",
            "Content-Type": "application/json",
        }

    def call(self, method: str, path: str, payload: dict[str, Any] | None = None) -> dict[str, Any] | None:
        url = f"{self._settings.backend_base_url.rstrip('/')}{path}"
        try:
            response = requests.request(
                method=method,
                url=url,
                headers=self._headers(),
                json=payload,
                timeout=10,
            )
        except requests.RequestException as exc:
            print(f"API {method} {path} request error: {exc}")
            return None

        if response.status_code >= 400:
            print(f"API {method} {path} failed: {response.status_code} {response.text}")
            return None

        try:
            return response.json()
        except ValueError:
            return None
