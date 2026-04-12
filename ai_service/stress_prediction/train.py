import pandas as pd
import numpy as np
import joblib
import os

from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.metrics import mean_absolute_error, r2_score
from sklearn.preprocessing import StandardScaler
from xgboost import XGBRegressor

# Cấu hình để joblib sử dụng thư mục hiện tại (ổ D) làm nơi lưu file tạm
# Điều này giúp tránh lỗi "No space left on device" nếu ổ C bị đầy.
os.environ['JOBLIB_TEMP_FOLDER'] = os.path.dirname(__file__)

# ===== LOAD DATA =====
# Đảm bảo đọc file từ đúng thư mục của script
base_path = os.path.dirname(__file__)
csv_path = os.path.join(base_path, "wearables_health_6mo_daily.csv")
df = pd.read_csv(csv_path)

# Giả định CSV có cột 'date', nếu không có ta tạo giả lập hoặc bỏ qua.
# Ở đây ta thêm yếu tố 'day_of_week' nếu dữ liệu theo chuỗi thời gian
if 'date' in df.columns:
    df['date'] = pd.to_datetime(df['date'])
    df['day_of_week'] = df['date'].dt.dayofweek

    # Thêm Lag Features (Giả định dữ liệu đã sắp xếp theo thời gian cho từng User nếu có nhiều User)
    # Stress thường có tính hệ quả từ ngày hôm trước
    df['hrv_lag1'] = df['hrv_rmssd_ms'].shift(1)
    df['sleep_lag1'] = df['sleep_duration_hours'].shift(1)
    df['rolling_hr_7d'] = df['resting_hr_bpm'].rolling(window=7, min_periods=1).mean()

# ===== FEATURE ENGINEERING 🔥 =====
df['sleep_debt'] = 8 - df['sleep_duration_hours']

df['hrv_log'] = np.log1p(df['hrv_rmssd_ms'])
df['steps_log'] = np.log1p(df['steps'])

df['hrv_hr_ratio'] = df['hrv_rmssd_ms'] / (df['resting_hr_bpm'] + 1)
df['hrv_hr_product'] = df['hrv_rmssd_ms'] * df['resting_hr_bpm']

df['sleep_hr_interaction'] = df['sleep_duration_hours'] * df['resting_hr_bpm']
df['stress_index'] = df['resting_hr_bpm'] / (df['sleep_duration_hours'] + 1)

# --- NEW FEATURES ---
df['hrv_sq'] = df['hrv_rmssd_ms'] ** 2
df['is_sleep_deprived'] = (df['sleep_duration_hours'] < 6).astype(int)
df['is_active'] = (df['steps'] > 10000).astype(int)
df['is_extreme_hrv'] = ((df['hrv_rmssd_ms'] < 20) | (df['hrv_rmssd_ms'] > 100)).astype(int)
df['sleep_hrv_ratio'] = df['sleep_duration_hours'] / (df['hrv_rmssd_ms'] + 1)
df['hrv_steps_interaction'] = df['hrv_log'] * df['steps_log']
df['fatigue_index'] = (df['resting_hr_bpm'] / (df['hrv_rmssd_ms'] + 1)) * (8 / (df['sleep_duration_hours'] + 1))
df['recovery_proxy'] = df['hrv_rmssd_ms'] * df['sleep_duration_hours'] / (df['resting_hr_bpm'] + 1)

# ===== FEATURES =====
features = [
    'hrv_rmssd_ms',
    'resting_hr_bpm',
    'sleep_duration_hours',
    'steps',

    'sleep_debt',
    'hrv_log',
    'steps_log',
    'hrv_hr_ratio',
    'hrv_hr_product',
    'sleep_hr_interaction',
    'stress_index',
    
    'hrv_sq',
    'is_sleep_deprived',
    'is_active',
    'is_extreme_hrv',
    'sleep_hrv_ratio',
    'fatigue_index',
    'recovery_proxy',
    'day_of_week',
    'hrv_lag1',
    'sleep_lag1',
    'rolling_hr_7d'
]

X = df[features]
y = df['stress_score']

# ===== REMOVE OUTLIERS (OPTIONAL BUT RECOMMENDED) =====
# Giới hạn dữ liệu trong khoảng 1% - 99% để tránh nhiễu cực đoan
X = X.clip(lower=X.quantile(0.01), upper=X.quantile(0.99), axis=1)

# ===== CLEAN DATA =====
X = X.ffill().bfill().fillna(0) # Dùng ffill cho dữ liệu chuỗi thời gian hợp lý hơn


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

base_model = XGBRegressor(random_state=42, tree_method='hist') # hist giúp chạy nhanh hơn

# Thêm verbose=2 để thấy tiến trình: mỗi tổ hợp tham số sẽ được in ra khi bắt đầu thử nghiệm
grid_search = GridSearchCV(
    base_model, 
    param_grid, 
    cv=5, 
    scoring='neg_mean_absolute_error', 
    n_jobs=2, # Giảm số luồng xuống để giảm áp lực ghi đĩa
    verbose=2
)

# ===== TRAIN =====
print(" Bắt đầu quá trình tìm kiếm tham số tối ưu (Grid Search)...")
grid_search.fit(X_train, y_train)

best_model = grid_search.best_estimator_

# Hiển thị độ quan trọng của tính năng
importances = pd.Series(best_model.feature_importances_, index=features).sort_values(ascending=False)
print("\n Feature Importances:")
print(importances.head(10))

# ===== EVALUATE =====
pred = best_model.predict(X_test)

mae = mean_absolute_error(y_test, pred)
r2 = r2_score(y_test, pred)

print(f"\n Best Params: {grid_search.best_params_}")
print("\n Optimized Evaluation:")
print("MAE:", mae)
print("R2:", r2)

# ===== SAVE =====
joblib.dump(best_model, os.path.join(base_path, "igf_model.pkl"))
joblib.dump(scaler, os.path.join(base_path, "igf_scaler.pkl"))

print("\n Model saved!")