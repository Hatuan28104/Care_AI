from pydantic import BaseModel
from typing import Optional, List


class StressInput(BaseModel):
    hrv_rmssd_ms: float
    resting_hr_bpm: float
    sleep_duration_hours: Optional[float] = None
    steps: float
    hrv_history: Optional[List[float]] = None
    sleep_history: Optional[List[float]] = None
    hr_history: Optional[List[float]] = None
    calibration_days: Optional[int] = None
    sleep_warning: Optional[str] = None