import pandas as pd

def preprocess(df):
    df = df.sort_values(by=df.columns[0])

    # 🔥 FIX WARNING
    df = df.ffill().bfill()

    # AVG
    df["steps_avg_3"] = df["steps"].rolling(3).mean()
    df["sleep_avg_3"] = df["sleep_hours"].rolling(3).mean()
    df["hr_avg_3"] = df["heart_rate"].rolling(3).mean()
    df["spo2_avg_3"] = df["spo2"].rolling(3).mean()
    df["hrv_avg_3"] = df["hrv"].rolling(3).mean()
    df["distance_avg_3"] = df["distance"].rolling(3).mean()

    # DIFF
    df["steps_diff"] = df["steps"] - df["steps_avg_3"]
    df["sleep_diff"] = df["sleep_hours"] - df["sleep_avg_3"]
    df["hr_diff"] = df["heart_rate"] - df["hr_avg_3"]
    df["spo2_diff"] = df["spo2"] - df["spo2_avg_3"]
    df["hrv_diff"] = df["hrv"] - df["hrv_avg_3"]
    df["distance_diff"] = df["distance"] - df["distance_avg_3"]

    return df.dropna()