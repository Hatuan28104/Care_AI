import pandas as pd

def preprocess(df):
    df = df.sort_values(by=df.columns[0])

    # 🔥 FIX WARNING
    df = df.ffill().bfill()

    # Use last record as baseline for diffs
    df["steps_last"] = df["steps"].shift(1)
    df["sleep_last"] = df["sleep_hours"].shift(1)
    df["hr_last"] = df["heart_rate"].shift(1)
    df["spo2_last"] = df["spo2"].shift(1)
    df["hrv_last"] = df["hrv"].shift(1)
    df["distance_last"] = df["distance"].shift(1)

    # DIFF from last record
    df["steps_diff"] = df["steps"] - df["steps_last"]
    df["sleep_diff"] = df["sleep_hours"] - df["sleep_last"]
    df["hr_diff"] = df["heart_rate"] - df["hr_last"]
    df["spo2_diff"] = df["spo2"] - df["spo2_last"]
    df["hrv_diff"] = df["hrv"] - df["hrv_last"]
    df["distance_diff"] = df["distance"] - df["distance_last"]

    return df.dropna()