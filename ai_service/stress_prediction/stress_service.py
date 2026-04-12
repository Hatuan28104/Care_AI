import joblib
import numpy as np
import os
from datetime import datetime

base_path = os.path.dirname(__file__)


def predict_stress(data, model, scaler):
    """
    data = {
        "hrv_rmssd_ms": 35,
        "resting_hr_bpm": 70,
        "sleep_duration_hours": 5,
        "steps": 3000,

        # optional (future - từ DB)
        "hrv_history": [30, 32, 34],
        "sleep_history": [6, 5.5, 5],
        "hr_history": [72, 71, 70]
    }
    """

    hrv = data["hrv_rmssd_ms"]
    hr = data["resting_hr_bpm"]
    sleep = data["sleep_duration_hours"]
    steps = data["steps"]

    # ===== SAFE HISTORY HANDLING =====
    hrv_history = data.get("hrv_history", [])
    sleep_history = data.get("sleep_history", [])
    hr_history = data.get("hr_history", [])

    # lag1 (ngày trước đó)
    hrv_lag1 = hrv_history[-1] if len(hrv_history) > 0 else hrv
    sleep_lag1 = sleep_history[-1] if len(sleep_history) > 0 else sleep

    # rolling HR 7 ngày
    if len(hr_history) > 0:
        rolling_hr_7d = np.mean(hr_history[-7:])
    else:
        rolling_hr_7d = hr

    # ===== FEATURE ENGINEERING =====
    hrv_log = np.log1p(hrv)
    steps_log = np.log1p(steps)

    features = [
        hrv,
        hr,
        sleep,
        steps,

        8 - sleep,
        hrv_log,
        steps_log,
        hrv / (hr + 1),
        hrv * hr,
        sleep * hr,
        hr / (sleep + 1),

        hrv ** 2,
        1 if sleep < 6 else 0,
        1 if steps > 10000 else 0,
        1 if (hrv < 20 or hrv > 100) else 0,
        sleep / (hrv + 1),

        (hr / (hrv + 1)) * (8 / (sleep + 1)),
        (hrv * sleep) / (hr + 1),
        datetime.now().weekday(),

        hrv_lag1,
        sleep_lag1,
        rolling_hr_7d
    ]

    values = np.array([features])
    values = scaler.transform(values)
    stress = model.predict(values)[0]

    return float(stress)