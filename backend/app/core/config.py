from pydantic_settings import BaseSettings
from pydantic import AnyHttpUrl
from typing import List
import os


class Settings(BaseSettings):
    # App
    APP_NAME: str = "Awala RealEstate API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    SECRET_KEY: str = "change_me"
    ALLOWED_ORIGINS: List[str] = ["http://localhost:3000", "http://localhost:8080", "http://localhost:61859"]
    ALLOW_ORIGIN_REGEX: str = r"^http://localhost(:[0-9]+)?$"

    # Database
    DATABASE_URL: str
    DATABASE_URL_SYNC: str

    # JWT
    JWT_SECRET_KEY: str = "change_me_jwt"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"

    # Meilisearch
    MEILI_URL: str = "http://localhost:7700"
    MEILI_MASTER_KEY: str = "awala_meili_key"

    # Cloudinary
    CLOUDINARY_CLOUD_NAME: str = ""
    CLOUDINARY_API_KEY: str = ""
    CLOUDINARY_API_SECRET: str = ""

    # Firebase
    FIREBASE_CREDENTIALS_PATH: str = "./firebase-credentials.json"

    # Local file uploads (offline-friendly dev storage)
    UPLOAD_DIR: str = "/app/uploads"
    PUBLIC_BASE_URL: str = "http://localhost:8001"

    # Geospatial — Molyko Junction, Buea
    MOLYKO_JUNCTION_LAT: float = 4.1527
    MOLYKO_JUNCTION_LNG: float = 9.2345

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
