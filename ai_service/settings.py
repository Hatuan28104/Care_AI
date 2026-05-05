import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))


def _resolve_path(env_name: str, default_relative_path: str) -> str:
    configured = os.getenv(env_name)
    if configured:
        return configured
    return os.path.join(BASE_DIR, *default_relative_path.split("/"))


class Settings:
    SUPABASE_URL: str = os.getenv("SUPABASE_URL", "https://jwgwzzngtpclkwgiyktt.supabase.co")
    SUPABASE_KEY: str = os.getenv("SUPABASE_KEY", "sb_publishable_xxx")

settings = Settings()

AI_TITLE = os.getenv("AI_TITLE", "Care_AI Unified AI Service")

# Self_evolution
SELF_EVOLUTION_MODEL_PATH = _resolve_path(
    "SELF_EVOLUTION_MODEL_PATH",
    "self_evolution/self_evolution_model.pkl",
)

# Stress prediction
STRESS_MODEL_PATH = _resolve_path(
    "STRESS_MODEL_PATH",
    "stress_prediction/igf_model.pkl",
)

STRESS_SCALER_PATH = _resolve_path(
    "STRESS_SCALER_PATH",
    "stress_prediction/igf_scaler.pkl",
)

STRESS_MODEL_NO_SLEEP_PATH = _resolve_path(
    "STRESS_MODEL_NO_SLEEP_PATH",
    "stress_prediction/igf_model_no_sleep.pkl",
)

STRESS_SCALER_NO_SLEEP_PATH = _resolve_path(
    "STRESS_SCALER_NO_SLEEP_PATH",
    "stress_prediction/igf_scaler_no_sleep.pkl",
)
