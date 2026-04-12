from fastapi import APIRouter, Request, HTTPException
from stress_prediction.stress_service import predict_stress
from stress_prediction.schema import StressInput

router = APIRouter()

@router.post("/predict")
def predict(data: StressInput, request: Request):
    model = request.app.state.stress_model
    scaler = request.app.state.stress_scaler

    if model is None or scaler is None:
        raise HTTPException(status_code=503, detail="Stress model not available")

    return {
        "stress": predict_stress(data.model_dump(), model, scaler)
    }