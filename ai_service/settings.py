import os

class Settings:
    SUPABASE_URL: str = os.getenv("SUPABASE_URL", "https://jwgwzzngtpclkwgiyktt.supabase.co")
    SUPABASE_KEY: str = os.getenv("SUPABASE_KEY", "sb_publishable_xxx")

settings = Settings()
