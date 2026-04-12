import logging
from contextlib import asynccontextmanager

import joblib
from fastapi import FastAPI

from settings import (
    AI_TITLE,
    SELF_EVOLUTION_MODEL_PATH,
    STRESS_MODEL_PATH,
    STRESS_SCALER_PATH,
)
from self_evolution.self_evolution_router import router as self_router
from stress_prediction.stress_route import router as stress_router

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        app.state.model_bundle = joblib.load(SELF_EVOLUTION_MODEL_PATH)
        logger.info("Self Evolution model loaded")
    except Exception as e:
        logger.warning(f"self_evolution load failed ({e}) -> fallback mode")
        app.state.model_bundle = None

    try:
        app.state.stress_model = joblib.load(STRESS_MODEL_PATH)
        app.state.stress_scaler = joblib.load(STRESS_SCALER_PATH)
        logger.info("Stress model + scaler loaded")
    except Exception as e:
        logger.warning(f"Stress model load failed ({e})")
        app.state.stress_model = None
        app.state.stress_scaler = None

    yield

    app.state.model_bundle = None
    app.state.stress_model = None
    app.state.stress_scaler = None


app = FastAPI(title=AI_TITLE, lifespan=lifespan)

# self router already has prefix="/self"
app.include_router(self_router)

# stress endpoint: /stress/predict
app.include_router(stress_router, prefix="/stress", tags=["Stress"])
