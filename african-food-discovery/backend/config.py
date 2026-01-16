"""
Configuration settings for the application
Load from environment variables
"""

from pydantic_settings import BaseSettings
import os

class Settings(BaseSettings):
    # Database Configuration
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "postgresql://postgres@localhost:5432/african_food_us"
    )
    
    # JWT Security Configuration
    SECRET_KEY: str = os.getenv(
        "SECRET_KEY",
        "change-this-to-a-long-random-string-in-production"
    )
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # Cloudinary Configuration (for image uploads)
    CLOUDINARY_CLOUD_NAME: str = os.getenv("CLOUDINARY_CLOUD_NAME", "")
    CLOUDINARY_API_KEY: str = os.getenv("CLOUDINARY_API_KEY", "")
    CLOUDINARY_API_SECRET: str = os.getenv("CLOUDINARY_API_SECRET", "")
    
    # Application Settings
    APP_NAME: str = "African Food Discovery Platform"
    DEBUG: bool = os.getenv("DEBUG", "True").lower() == "true"
    ALLOWED_ORIGINS: str = os.getenv(
        "ALLOWED_ORIGINS",
        "http://localhost:5173,http://localhost:3000"
    )
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
