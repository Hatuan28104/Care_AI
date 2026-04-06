import pandas as pd
from datetime import datetime, timedelta

def process_history(history: list) -> pd.DataFrame:
    records = []
    for item in history:
        d = item.model_dump() if hasattr(item, "model_dump") else (item.dict() if hasattr(item, "dict") else item)
        records.append(d)
        
    df = pd.DataFrame(records)
    if df.empty:
        return df
        
    df['date'] = pd.to_datetime(df['date'])
    df = df.sort_values(by='date').reset_index(drop=True)
    return df

def build_features(current: dict, history: list) -> dict:
    df = process_history(history)
    
    if df.empty:
        last_record = {}
    else:
        last_record = df.iloc[-1].to_dict()
        
    return {
        "steps": current.get("steps", 0),
        "sleep_hours": current.get("sleep_hours", 0),
        "heart_rate": current.get("heart_rate", 0),
        "spo2": current.get("spo2", 0),
        "hrv": current.get("hrv", 0),
        "distance": current.get("distance", 0),
        
        "steps_diff": current.get("steps", 0) - last_record.get("steps", 0),
        "sleep_diff": current.get("sleep_hours", 0) - last_record.get("sleep_hours", 0),
        "hr_diff": current.get("heart_rate", 0) - last_record.get("heart_rate", 0),
        "spo2_diff": current.get("spo2", 0) - last_record.get("spo2", 0),
        "hrv_diff": current.get("hrv", 0) - last_record.get("hrv", 0),
        "distance_diff": current.get("distance", 0) - last_record.get("distance", 0)
    }

def format_number(val: float) -> str:
    if val == int(val):
        return f"{int(val):,}".replace(",", ".")
    return f"{val:,.1f}".replace(",", "X").replace(".", ",").replace("X", ".")

def format_change(diff: float, current: float, unit: str = "", positive_good: bool = True, threshold: float = 0.0) -> str:
    curr_str = format_number(current)
    diff_str = format_number(abs(diff))
    
    if abs(diff) < threshold:
        return f"{curr_str}{unit} (duy trì ổn định)"
    
    if diff > 0:
        action = "tăng"
        return f"{curr_str}{unit} ({action} {diff_str} so với lần đo gần nhất)"
    elif diff < 0:
        action = "giảm"
        return f"{curr_str}{unit} ({action} {diff_str} so với lần đo gần nhất)"
    
    return f"{curr_str}{unit} (duy trì ổn định)"

def compare_daily(current: dict, history: list) -> dict:
    df = process_history(history)
    if df.empty:
        return {}

    # Use last record as baseline
    last_record = df.iloc[-1]
    today = current

    compare = {}
    # format: key -> (unit, is_good_when_up, threshold)
    metrics = {
        "steps": (" bước", True, 1500),
        "sleep_hours": (" giờ", True, 1.0),
        "heart_rate": (" bpm", False, 5),
        "spo2": ("%", True, 2),
        "hrv": (" ms", True, 5),
        "distance": (" km", True, 0.5)
    }

    for key, (unit, is_good_when_up, threshold) in metrics.items():
        val_today = today.get(key, 0)
        if val_today <= 0:
            continue

        val_last = last_record.get(key, 0)
        if val_last <= 0:
            compare[key] = f"{format_number(val_today)}{unit}"
            continue

        diff = val_today - val_last

        # Absolute-aware compare for critical vitals
        if key == "spo2" and val_today < 90:
            action = "tăng" if diff > 0 else "giảm" if diff < 0 else "không đổi"
            if diff == 0:
                compare[key] = f"{format_number(val_today)}{unit} (rất thấp)"
            else:
                compare[key] = (
                    f"{format_number(val_today)}{unit} "
                    f"({action} {format_number(abs(diff))} nhưng vẫn rất thấp)"
                )
            continue

        if key == "heart_rate" and val_today > 130:
            action = "tăng" if diff > 0 else "giảm" if diff < 0 else "không đổi"
            if diff == 0:
                compare[key] = f"{format_number(val_today)}{unit} (rất cao)"
            else:
                compare[key] = (
                    f"{format_number(val_today)}{unit} "
                    f"({action} {format_number(abs(diff))} nhưng vẫn rất cao)"
                )
            continue

        if key == "heart_rate" and val_today > 110:
            action = "tăng" if diff > 0 else "giảm" if diff < 0 else "không đổi"
            if diff == 0:
                compare[key] = f"{format_number(val_today)}{unit} (cao)"
            else:
                compare[key] = (
                    f"{format_number(val_today)}{unit} "
                    f"({action} {format_number(abs(diff))} nhưng vẫn cao)"
                )
            continue

        compare[key] = format_change(diff, val_today, unit, is_good_when_up, threshold)

    if "sleep_hours" in compare:
        compare["sleep"] = compare.pop("sleep_hours")

    return compare
