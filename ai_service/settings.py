import os

class Settings:
    SUPABASE_URL: str = os.getenv("SUPABASE_URL", "https://jwgwzzngtpclkwgiyktt.supabase.co")
    SUPABASE_KEY: str = os.getenv("SUPABASE_KEY", "sb_publishable_xxx")

settings = Settings()

AI_TITLE = os.getenv("AI_TITLE", "Care_AI Unified AI Service")

# Self_evolution
SELF_EVOLUTION_MODEL_PATH = os.getenv(
    "SELF_EVOLUTION_MODEL_PATH",
    "self_evolution/self_evolution_model.pkl",
)

# Stress prediction
STRESS_MODEL_PATH = os.getenv(
    "STRESS_MODEL_PATH",
    "stress_prediction/igf_model.pkl",
)
STRESS_SCALER_PATH = os.getenv(
    "STRESS_SCALER_PATH",
    "stress_prediction/igf_scaler.pkl",
)
