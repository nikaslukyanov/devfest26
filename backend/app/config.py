import os
from pathlib import Path

from dotenv import load_dotenv

# Load .env from backend dir first, then project root (where FEATHERLESS_API_KEY may live)
_backend_dir = Path(__file__).resolve().parent.parent
_project_root = _backend_dir.parent
load_dotenv(_backend_dir / ".env")
load_dotenv(_project_root / ".env")

API_HOST = os.getenv("API_HOST", "0.0.0.0")
API_PORT = int(os.getenv("API_PORT", "8000"))
FEATHERLESS_API_KEY = os.getenv("FEATHERLESS_API_KEY", "")

