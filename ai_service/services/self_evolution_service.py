import joblib
import pandas as pd

model = joblib.load("models/self_evolution_model.pkl")

def calculate_diff(current, history):
    df = pd.DataFrame(history)

    steps_avg = df["steps"].mean()
    sleep_avg = df["sleep_hours"].mean()
    hr_avg = df["heart_rate"].mean()

    return (
        current["steps"] - steps_avg,
        current["sleep_hours"] - sleep_avg,
        current["heart_rate"] - hr_avg
    )


def predict(data):
    history = data["history"]

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