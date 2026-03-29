import pandas as pd
import requests
import joblib

# ==============================
# 🔥 LOAD MODEL (OPTIONAL)
# ==============================
try:
    bundle = joblib.load("models/self_evolution_model.pkl")
    model = bundle["model"]
    features = bundle["features"]
    USE_MODEL = True
except:
    print("⚠️ Không load được model → dùng rule-based")
    USE_MODEL = False


# ==============================
# 🔥 CONFIG SUPABASE
# ==============================
SUPABASE_URL = "https://jwgwzzngtpclkwgiyktt.supabase.co"
SUPABASE_KEY = "sb_publishable_xxx"


# ==============================
# 🔥 NORMALIZE INPUT
# ==============================
def normalize_input(data):
    return {
        "user_id": data.get("user_id"),
        "steps": data.get("steps"),
        "sleep_hours": data.get("sleep_hours") or data.get("sleep"),
        "heart_rate": data.get("heart_rate") or data.get("hr"),
        "spo2": data.get("spo2"),
        "hrv": data.get("hrv"),
        "distance": data.get("distance", 0)
    }


# ==============================
# 🔥 BUILD RESPONSE
# ==============================
def build_response(status):
    if status == "bad":
        return {
            "status": "bad",
            "message": "Chỉ số sức khỏe hôm nay không ổn 😟",
            "advice": "Bạn nên nghỉ ngơi, ngủ đủ và giảm căng thẳng"
        }
    elif status == "good":
        return {
            "status": "good",
            "message": "Sức khỏe hôm nay rất tốt 💪",
            "advice": "Tiếp tục duy trì thói quen hiện tại"
        }
    elif status == "normal":
        return {
            "status": "normal",
            "message": "Sức khỏe ổn định 👍",
            "advice": "Giữ nhịp sinh hoạt đều đặn"
        }
    else:
        return {
            "status": "not_enough_data",
            "message": "Chưa đủ dữ liệu để phân tích",
            "advice": "Hãy sử dụng thêm vài ngày"
        }


# ==============================
# 🔥 GET DATA
# ==============================
def get_history_from_db(user_id):
    url = f"{SUPABASE_URL}/rest/v1/dulieusuckhoe"

    headers = {
        "apikey": SUPABASE_KEY,
        "Authorization": f"Bearer {SUPABASE_KEY}"
    }

    params = {
        "nguoidung_id": f"eq.{user_id}",
        "select": "thoigiancapnhat,loaichiso_id,giatri",
        "order": "thoigiancapnhat.desc",
        "limit": "50"
    }

    try:
        res = requests.get(url, headers=headers, params=params)

        if res.status_code != 200:
            return []

        rows = res.json()
        pivot = {}

        for r in rows:
            time = r["thoigiancapnhat"]

            if time not in pivot:
                pivot[time] = {}

            cid = r["loaichiso_id"]
            val = r["giatri"]

            if cid == "CS004":
                pivot[time]["steps"] = val
            elif cid == "CS037":
                pivot[time]["sleep_hours"] = val
            elif cid == "CS001":
                pivot[time]["heart_rate"] = val
            elif cid == "CS018":
                pivot[time]["spo2"] = val
            elif cid == "CS008":
                pivot[time]["hrv"] = val
            elif cid == "CS023":
                pivot[time]["distance"] = val

        return list(pivot.values())[:7]

    except:
        return []


# ==============================
# 🔥 BUILD FEATURE
# ==============================
def build_features(current, history):
    df = pd.DataFrame(history)
    df = df.ffill().bfill().fillna(0)

    last3 = df.tail(3)

    return {
        "steps": current["steps"],
        "sleep_hours": current["sleep_hours"],
        "heart_rate": current["heart_rate"],
        "spo2": current["spo2"],
        "hrv": current["hrv"],
        "distance": current["distance"],

        "steps_diff": current["steps"] - last3["steps"].mean(),
        "sleep_diff": current["sleep_hours"] - last3["sleep_hours"].mean(),
        "hr_diff": current["heart_rate"] - last3["heart_rate"].mean(),
        "spo2_diff": current["spo2"] - last3["spo2"].mean(),
        "hrv_diff": current["hrv"] - last3["hrv"].mean(),
        "distance_diff": current["distance"] - last3["distance"].mean()
    }


# ==============================
# 🔥 FORMAT CHANGE
# ==============================
def hr_level(hr):
    if hr > 100:
        return "⚠️ cao"
    elif hr < 60:
        return "⚠️ thấp"
    return "✔ bình thường"


def format_change(val, current, unit=""):
    if val > 0:
        return f"+{val} (tăng) → {current}{unit}"
    elif val < 0:
        return f"{val} (giảm) → {current}{unit}"
    else:
        return f"0 (không đổi) → {current}{unit}"


# ==============================
# 🔥 COMPARE DAILY (UPGRADE)
# ==============================
def compare_daily(history):
    df = pd.DataFrame(history)
    df = df.ffill().bfill().fillna(0)

    if len(df) < 2:
        return {}

    today = df.iloc[-1]
    yesterday = df.iloc[-2]

    return {
        "steps": format_change(today["steps"] - yesterday["steps"], today["steps"], " bước"),
        "sleep": format_change(today["sleep_hours"] - yesterday["sleep_hours"], today["sleep_hours"], " giờ"),
        "heart_rate": format_change(
            today["heart_rate"] - yesterday["heart_rate"],
            today["heart_rate"],
            " bpm"
        ) + f" ({hr_level(today['heart_rate'])})",
        "spo2": format_change(today["spo2"] - yesterday["spo2"], today["spo2"], "%"),
        "hrv": format_change(today["hrv"] - yesterday["hrv"], today["hrv"], "")
    }


# ==============================
# 🔥 RULE-BASED
# ==============================
def evaluate_health(f):
    if f["sleep_diff"] < -1 or f["hr_diff"] > 10 or f["spo2_diff"] < -2:
        return "bad"

    if f["steps_diff"] > 1000 and f["sleep_diff"] > 0 and f["hrv_diff"] > 5:
        return "good"

    return "normal"


# ==============================
# 🔥 MAIN
# ==============================
def predict(data):
    try:
        data = normalize_input(data)
        history = get_history_from_db(data["user_id"])

        if len(history) < 3:
            return build_response("not_enough_data")

        f = build_features(data, history)

        if USE_MODEL:
            X = [[f[col] for col in features]]
            result = model.predict(X)[0]
            status = ["bad", "normal", "good"][result]
        else:
            status = evaluate_health(f)

        compare = compare_daily(history)

        response = build_response(status)
        response["compare"] = compare

        return response

    except Exception as e:
        print(e)
        return {
            "status": "error",
            "message": "Lỗi hệ thống AI",
            "advice": "Thử lại sau"
        }
