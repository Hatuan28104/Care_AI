import pandas as pd
import joblib
from sklearn.ensemble import RandomForestClassifier
from preprocess import preprocess

# load data
df = pd.read_csv("../../data/wearables_health_6mo_daily.csv")

# ✅ rename đúng theo dataset
df = df.rename(columns={
    "avg_hr_day_bpm": "heart_rate",
    "sleep_duration_hours": "sleep_hours"
})

# preprocess
df = preprocess(df)

# label
def create_label(row):
    if row["sleep_diff"] < -1 or row["hr_diff"] > 10:
        return 0
    elif row["steps_diff"] > 1000 and row["sleep_diff"] > 0:
        return 2
    return 1

df["label"] = df.apply(create_label, axis=1)

# feature
X = df[[
    "steps",
    "sleep_hours",
    "heart_rate",
    "steps_diff",
    "sleep_diff",
    "hr_diff"
]]

y = df["label"]

# train
model = RandomForestClassifier(n_estimators=100)
model.fit(X, y)

# save
joblib.dump(model, "../../models/self_evolution_model.pkl")

print("✅ Train xong")