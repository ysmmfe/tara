import os


def _get_env(name: str, default: str) -> str:
    value = os.getenv(name)
    return value if value is not None else default


class Settings:
    def __init__(self) -> None:
        self.app_env = _get_env("APP_ENV", "development")
        self.secret_key = _get_env("SECRET_KEY", "dev-secret-change-me")
        self.access_token_expires_minutes = int(
            _get_env("ACCESS_TOKEN_EXPIRES_MINUTES", "15")
        )
        self.refresh_token_expires_days = int(
            _get_env("REFRESH_TOKEN_EXPIRES_DAYS", "30")
        )
        self.api_base_url = _get_env("API_BASE_URL", "http://localhost:8000")
        self.google_client_ids = [
            client_id.strip()
            for client_id in _get_env("GOOGLE_CLIENT_IDS", "").split(",")
            if client_id.strip()
        ]


settings = Settings()
