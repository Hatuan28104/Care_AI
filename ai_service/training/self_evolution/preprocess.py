import pandas as pd

def preprocess(df):
    df["steps_avg_3"] = df["steps"].rolling(3).mean()
    df["sleep_avg_3"] = df["sleep_hours"].rolling(3).mean()
    df["hr_avg_3"] = df["heart_rate"].rolling(3).mean()

    df["steps_diff"] = df["steps"] - df["steps_avg_3"]
    df["sleep_diff"] = df["sleep_hours"] - df["sleep_avg_3"]
    df["hr_diff"] = df["heart_rate"] - df["hr_avg_3"]

    return df.dropna()