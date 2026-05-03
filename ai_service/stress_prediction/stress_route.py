from fastapi import APIRouter, Request, HTTPException
from stress_prediction.stress_service import predict_stress, predict_stress_no_sleep
from stress_prediction.schema import StressInput

router = APIRouter()

@router.post("/predict")
def predict(data: StressInput, request: Request):
    raw = data.model_dump()

    if raw.get("sleep_duration_hours") is not None:
        # ✅ Có sleep → dùng model đầy đủ (22 features)
        model = request.app.state.stress_model
        scaler = request.app.state.stress_scaler

        if model is None or scaler is None:
            raise HTTPException(status_code=503, detail="Stress model not available")

        return {
            "stress": predict_stress(raw, model, scaler)
        }
    else:
        # ⚠️ Không có sleep → dùng model no-sleep (13 features)
        model = request.app.state.stress_model_no_sleep
        scaler = request.app.state.stress_scaler_no_sleep

        if model is None or scaler is None:
            raise HTTPException(status_code=503, detail="Stress no-sleep model not available")

        return {
            "stress": predict_stress_no_sleep(raw, model, scaler)
        }