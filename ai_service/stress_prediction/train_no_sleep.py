import pandas as pd
import numpy as np
import joblib
import os

from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.metrics import mean_absolute_error, r2_score
from sklearn.preprocessing import StandardScaler
from xgboost import XGBRegressor

# Cấu hình để joblib sử dụng thư mục hiện tại làm nơi lưu file tạm
os.environ['JOBLIB_TEMP_FOLDER'] = os.path.dirname(__file__)

# ===== LOAD DATA =====
# File CSV được để ở thư mục gốc (CareAI) để dùng chung cho nhiều service
base_path = os.path.dirname(__file__)
ai_service_path = os.path.abspath(os.path.join(base_path, ".."))
csv_path = os.path.join(ai_service_path, "wearables_health_6mo_daily.csv")

if not os.path.exists(csv_path):
    print(f"\n❌ ERROR: Dataset file not found at: {csv_path}")
    print(f"   Please ensure 'wearables_health_6mo_daily.csv' exists in: {ai_service_path}\n")
    exit(1)

df = pd.read_csv(csv_path)

# Day of week
if 'date' in df.columns:
    df['date'] = pd.to_datetime(df['date'])
    
    # Sắp xếp để đảm bảo tính toán thời gian đúng
    sort_cols = ['user_id', 'date'] if 'user_id' in df.columns else ['date']
    df = df.sort_values(sort_cols)
    
    df['day_of_week'] = df['date'].dt.dayofweek

    # Lag Features (chỉ HRV, không có sleep) 
    # Lưu ý: Nếu có nhiều User, hãy dùng groupby('user_id') trước khi shift/rolling
    df['hrv_lag1'] = df['hrv_rmssd_ms'].shift(1)
    df['rolling_hr_7d'] = df['resting_hr_bpm'].rolling(window=7, min_periods=1).mean()
    # Lag Features (Dùng groupby nếu có nhiều người dùng trong file chung)
    if 'user_id' in df.columns:
        df['hrv_lag1'] = df.groupby('user_id')['hrv_rmssd_ms'].shift(1)
        df['rolling_hr_7d'] = df.groupby('user_id')['resting_hr_bpm'].transform(lambda x: x.rolling(7, min_periods=1).mean())
    else:
        df['hrv_lag1'] = df['hrv_rmssd_ms'].shift(1)
        df['rolling_hr_7d'] = df['resting_hr_bpm'].rolling(window=7, min_periods=1).mean()

# ===== FEATURE ENGINEERING (chỉ HR/HRV/Steps) =====
df['hrv_log'] = np.log1p(df['hrv_rmssd_ms'])
df['steps_log'] = np.log1p(df['steps'])

df['hrv_hr_ratio'] = df['hrv_rmssd_ms'] / (df['resting_hr_bpm'] + 1)
df['hrv_hr_product'] = df['hrv_rmssd_ms'] * df['resting_hr_bpm']

df['hrv_sq'] = df['hrv_rmssd_ms'] ** 2
df['is_active'] = (df['steps'] > 10000).astype(int)
df['is_extreme_hrv'] = ((df['hrv_rmssd_ms'] < 20) | (df['hrv_rmssd_ms'] > 100)).astype(int)

# ===== FEATURES (13 — chỉ từ HR, HRV, Steps) =====
features = [
    'hrv_rmssd_ms',
    'resting_hr_bpm',
    'steps',

    'hrv_log',
    'steps_log',
    'hrv_hr_ratio',
    'hrv_hr_product',

    'hrv_sq',
    'is_active',
    'is_extreme_hrv',

    'day_of_week',
    'hrv_lag1',
    'rolling_hr_7d',
]

X = df[features]
y = df['stress_score']

# ===== REMOVE OUTLIERS =====
X = X.clip(lower=X.quantile(0.01), upper=X.quantile(0.99), axis=1)

# ===== CLEAN DATA =====
X = X.ffill().bfill().fillna(0)

# ===== SPLIT =====
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# ===== SCALE =====
scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)
X_test = scaler.transform(X_test)

# ===== HYPERPARAMETER TUNING =====
param_grid = {
    'n_estimators': [1000, 2000],
    'learning_rate': [0.01, 0.05],
    'max_depth': [3, 5, 7],
    'min_child_weight': [1, 3],
    'subsample': [0.7, 0.9],
    'colsample_bytree': [0.8, 1.0]
}

base_model = XGBRegressor(random_state=42, tree_method='hist')

grid_search = GridSearchCV(
    base_model,
    param_grid,
    cv=5,
    scoring='neg_mean_absolute_error',
    n_jobs=2,
    verbose=2
)

# ===== TRAIN =====
print("🔍 Training NO-SLEEP model (13 features: HR/HRV/Steps only)...")
grid_search.fit(X_train, y_train)

best_model = grid_search.best_estimator_

# Feature importances
importances = pd.Series(best_model.feature_importances_, index=features).sort_values(ascending=False)
print("\n📊 Feature Importances (No Sleep):")
print(importances)

# ===== EVALUATE =====
pred = best_model.predict(X_test)

mae = mean_absolute_error(y_test, pred)
r2 = r2_score(y_test, pred)

print(f"\n🏆 Best Params: {grid_search.best_params_}")
print("\n📈 Evaluation:")
print("MAE:", mae)
print("R2:", r2)

# ===== SAVE =====
joblib.dump(best_model, os.path.join(base_path, "igf_model_no_sleep.pkl"))
joblib.dump(scaler, os.path.join(base_path, "igf_scaler_no_sleep.pkl"))

print("\n✅ No-sleep model saved: igf_model_no_sleep.pkl + igf_scaler_no_sleep.pkl")
