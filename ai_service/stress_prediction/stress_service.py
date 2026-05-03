import joblib
import numpy as np
import os
from datetime import datetime

base_path = os.path.dirname(__file__)


def predict_stress(data, model, scaler):
    """
    Model ĐẦY ĐỦ — 22 features (có sleep)
    """

    hrv = data["hrv_rmssd_ms"]
    hr = data["resting_hr_bpm"]
    sleep = data["sleep_duration_hours"]
    steps = data["steps"]

    # ===== SAFE HISTORY HANDLING =====
    hrv_history = data.get("hrv_history") or []
    sleep_history = data.get("sleep_history") or []
    hr_history = data.get("hr_history") or []

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
        rolling_hr_7d,
    ]

    values = np.array([features])
    values = scaler.transform(values)
    stress = model.predict(values)[0]

    return float(stress)


def predict_stress_no_sleep(data, model, scaler):
    """
    Model KHÔNG CÓ SLEEP — 13 features (chỉ HR/HRV/Steps)
    Dùng khi không có dữ liệu giấc ngủ.
    """

    hrv = data["hrv_rmssd_ms"]
    hr = data["resting_hr_bpm"]
    steps = data["steps"]

    # ===== SAFE HISTORY HANDLING =====
    hrv_history = data.get("hrv_history") or []
    hr_history = data.get("hr_history") or []

    hrv_lag1 = hrv_history[-1] if len(hrv_history) > 0 else hrv

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
        steps,

        hrv_log,
        steps_log,
        hrv / (hr + 1),        # hrv_hr_ratio
        hrv * hr,               # hrv_hr_product

        hrv ** 2,               # hrv_sq
        1 if steps > 10000 else 0,                     # is_active
        1 if (hrv < 20 or hrv > 100) else 0,           # is_extreme_hrv

        datetime.now().weekday(),  # day_of_week
        hrv_lag1,
        rolling_hr_7d,
    ]

    values = np.array([features])
    values = scaler.transform(values)
    stress = model.predict(values)[0]

    return float(stress)