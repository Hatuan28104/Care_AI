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
        last3 = pd.DataFrame([current])
    else:
        last3 = df.tail(3)
        
    return {
        "steps": current.get("steps", 0),
        "sleep_hours": current.get("sleep_hours", 0),
        "heart_rate": current.get("heart_rate", 0),
        "spo2": current.get("spo2", 0),
        "hrv": current.get("hrv", 0),
        "distance": current.get("distance", 0),
        
        "steps_diff": current.get("steps", 0) - (last3["steps"].mean() if not last3.empty else 0),
        "sleep_diff": current.get("sleep_hours", 0) - (last3["sleep_hours"].mean() if not last3.empty else 0),
        "hr_diff": current.get("heart_rate", 0) - (last3["heart_rate"].mean() if not last3.empty else 0),
        "spo2_diff": current.get("spo2", 0) - (last3["spo2"].mean() if not last3.empty else 0),
        "hrv_diff": current.get("hrv", 0) - (last3["hrv"].mean() if not last3.empty else 0),
        "distance_diff": current.get("distance", 0) - (last3["distance"].mean() if not last3.empty else 0)
    }

def format_number(val: float) -> str:
    if val == int(val):
        return f"{int(val):,}".replace(",", ".")
    return f"{val:,.1f}".replace(",", "X").replace(".", ",").replace("X", ".")

def format_change(diff: float, current: float, unit: str = "", positive_good: bool = True) -> str:
    curr_str = format_number(current)
    diff_str = format_number(abs(diff))
    
    if diff > 0:
        icon = "👍" if positive_good else "⚠️"
        action = "tăng"
        return f"{curr_str}{unit} ({action} {diff_str} so với hôm qua {icon})"
    elif diff < 0:
        icon = "⚠️" if positive_good else "👍"
        action = "giảm"
        return f"{curr_str}{unit} ({action} {diff_str} so với hôm qua {icon})"
    
    return f"{curr_str}{unit} (duy trì ổn định)"

def compare_daily(current: dict, history: list) -> dict:
    df = process_history(history)
    if df.empty:
        return {}
        
    if "date" in current and current["date"]:
        target_date = pd.to_datetime(current["date"]).date()
    else:
        target_date = datetime.utcnow().date()
        
    yesterday_date = target_date - timedelta(days=1)
    yesterday_df = df[df['date'].dt.date == yesterday_date]
    
    if yesterday_df.empty:
        yesterday = df.iloc[-1]
    else:
        yesterday = yesterday_df.iloc[-1]
        
    today = current
    
    compare = {}
    metrics = {
        "steps": (" bước", True),         
        "sleep_hours": (" giờ", True),   
        "heart_rate": (" bpm", False),    
        "spo2": ("%", True),             
        "hrv": (" ms", True),          
        "distance": (" km", True)
    }
    
    for key, (unit, is_good_when_up) in metrics.items():
        val_today = today.get(key, 0)
        if val_today > 0:
            val_yesterday = yesterday.get(key, 0)
            if val_yesterday > 0:
                diff = val_today - val_yesterday
                compare[key] = format_change(diff, val_today, unit, is_good_when_up)
            else:
                compare[key] = f"{format_number(val_today)}{unit}"
                
    if "sleep_hours" in compare:
        compare["sleep"] = compare.pop("sleep_hours")
        
    return compare
