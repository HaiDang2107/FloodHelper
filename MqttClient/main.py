import os
from src.app import app


if __name__ == "__main__":
    import uvicorn

    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", "8000"))
    reload_enabled = os.getenv("RELOAD", "false").lower() in {"1", "true", "yes"}

    uvicorn.run(
        "main:app",
        host=host,
        port=port,
        reload=reload_enabled,
    )