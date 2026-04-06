from pydantic import BaseModel, ConfigDict
from typing import Optional, List, Dict, Any


class DailyHealthRecord(BaseModel):
    date: str  # YYYY-MM-DD
    steps: float = 0.0
    sleep_hours: float = 0.0
    heart_rate: float = 0.0
    spo2: float = 0.0
    hrv: float = 0.0
    distance: float = 0.0
    model_config = ConfigDict(extra="ignore")


class HealthDataInput(BaseModel):
    nguoidung_id: str
    current_metrics: DailyHealthRecord
    history: List[DailyHealthRecord] = []


class HealthEvaluationResponse(BaseModel):
    status: str  # xấu | bình thường | tốt
    message: str
    advice: str
    compare: Optional[Dict[str, Any]] = None
