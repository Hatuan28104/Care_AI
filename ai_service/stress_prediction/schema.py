from pydantic import BaseModel

class StressInput(BaseModel):
    hrv_rmssd_ms: float
    resting_hr_bpm: float
    sleep_duration_hours: float
    steps: float