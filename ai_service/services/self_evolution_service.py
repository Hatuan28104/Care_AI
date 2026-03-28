import joblib
import pandas as pd
import requests

model = joblib.load("models/self_evolution_model.pkl")

# 🔥 CONFIG SUPABASE
SUPABASE_URL = "https://jwgwzzngtpclkwgiyktt.supabase.co"
SUPABASE_KEY = "sb_publishable_x6bWVlEkg1LgB_W5EnNIpQ_fNCTfaio"


# 🔥 LẤY DATA TỪ SUPABASE + PIVOT
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

    res = requests.get(url, headers=headers, params=params)

    if res.status_code != 200:
        return []

    rows = res.json()

    # 🔥 pivot dữ liệu
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

    # convert list
    data = []
    for v in pivot.values():
        if len(v) == 3:
            data.append(v)

    return data[:7]


# 🔥 CALCULATE DIFF
def calculate_diff(current, history):
    df = pd.DataFrame(history)

    df = df.fillna(method="ffill").fillna(method="bfill")

    last3 = df.tail(3)

    steps_avg = last3["steps"].mean()
    sleep_avg = last3["sleep_hours"].mean()
    hr_avg = last3["heart_rate"].mean()

    return (
        current["steps"] - steps_avg,
        current["sleep_hours"] - sleep_avg,
        current["heart_rate"] - hr_avg
    )


# 🔥 MAIN PREDICT
def predict(data):
    user_id = data["user_id"]

    history = get_history_from_db(user_id)

    if len(history) < 3:
        return "not_enough_data"

    steps_diff, sleep_diff, hr_diff = calculate_diff(data, history)

    X = [[
        data["steps"],
        data["sleep_hours"],
        data["heart_rate"],
        steps_diff,
        sleep_diff,
        hr_diff
    ]]

    result = model.predict(X)[0]

    return ["bad", "normal", "good"][result]