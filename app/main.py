import os
import socket

from fastapi import FastAPI

app = FastAPI(title="ai-assistant")


@app.get("/")
def root():
    return {
        "service": "ai-assistant",
        "version": os.getenv("APP_VERSION", "dev"),
        "host": socket.gethostname(),
        "message": "Deployed automatically by GitHub Actions",
    }


@app.get("/health")
def health():
    return {"status": "ok"}
