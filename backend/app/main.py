from fastapi import FastAPI
from app.routes import health, items

app = FastAPI(title="DevFest26 API", version="1.0.0")

app.include_router(health.router)
app.include_router(items.router, prefix="/api/items", tags=["items"])
