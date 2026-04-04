import logging
import joblib
from fastapi import FastAPI
from contextlib import asynccontextmanager
from routers import ai_router

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        app.state.model_bundle = joblib.load("models/self_evolution_model.pkl")
        logger.info("Self Evolution model loaded successfully")
    except Exception as e:
        logger.warning(f"Failed to load model ({e}) -> Run with Rule-based mode")
        app.state.model_bundle = None
    yield
    app.state.model_bundle = None

app = FastAPI(title="Care_AI AI Server", lifespan=lifespan)
app.include_router(ai_router.router)