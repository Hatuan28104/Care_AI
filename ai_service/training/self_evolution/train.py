import pandas as pd
import joblib
from sklearn.ensemble import RandomForestClassifier
from preprocess import preprocess

# ==========================
# 🔥 LOAD DATA
# ==========================
df = pd.read_csv("../../data/wearables_health_6mo_daily.csv")

# ==========================
# 🔥 RENAME (ĐÚNG DATASET)
# ==========================
rename_map = {
    "avg_hr_day_bpm": "heart_rate",
    "sleep_duration_hours": "sleep_hours",

    "spo2_avg_pct": "spo2",
    "hrv_rmssd_ms": "hrv",
    "distance_km": "distance" 
}

df = df.rename(columns=rename_map)

# ==========================
# 🔥 DEBUG RENAME
# ==========================
print("AFTER RENAME:", df.columns.tolist())

# ==========================
# 🔥 ENSURE COLUMNS
# ==========================
required_cols = [
    "steps",
    "sleep_hours",
    "heart_rate",
    "spo2",
    "hrv",
    "distance"
]

for col in required_cols:
    if col not in df.columns:
        print(f"⚠️ Missing column: {col} → fill 0")
        df[col] = 0

# ==========================
# 🔥 HANDLE MISSING (FIX WARNING)
# ==========================
df = df.ffill().bfill().fillna(0)

# ==========================
# 🔥 PREPROCESS
# ==========================
df = preprocess(df)

# ==========================
# 🔥 LABEL (THỰC TẾ HƠN)
# ==========================
def create_label(row):
    # ❌ BAD
    if (
        row["sleep_hours"] < 5 or
        row["heart_rate"] > 100 or
        row["spo2"] < 95
    ):
        return 0

    # 💪 GOOD
    if (
        row["steps"] > 8000 and
        row["sleep_hours"] >= 6 and
        row["spo2"] >= 97
    ):
        return 2

    return 1

df["label"] = df.apply(create_label, axis=1)

# ==========================
# 🔥 FEATURE
# ==========================
features = [
    "steps",
    "sleep_hours",
    "heart_rate",
    "spo2",
    "hrv",
    "distance",

    "steps_diff",
    "sleep_diff",
    "hr_diff",
    "spo2_diff",
    "hrv_diff",
    "distance_diff"
]

X = df[features]
y = df["label"]

# ==========================
# 🔥 DEBUG INFO
# ==========================
print("==== TRAIN INFO ====")
print("Shape:", df.shape)
print("Label distribution:")
print(y.value_counts())

# ==========================
# 🔥 TRAIN MODEL
# ==========================
model = RandomForestClassifier(
    n_estimators=200,
    max_depth=5,
    random_state=42
)

model.fit(X, y)

# ==========================
# 🔥 SAVE MODEL
# ==========================
joblib.dump({
    "model": model,
    "features": features
}, "../../models/self_evolution_model.pkl")

print("✅ Train xong model 6 chỉ số")