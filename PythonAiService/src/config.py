from pydantic_settings import BaseSettings
from pydantic import Field
from typing import Optional

class Settings(BaseSettings):
    """
    Настройки приложения с GigaChat
    """
    # Единственный обязательный ключ для авторизации
    GIGACHAT_AUTH_KEY: str = Field(..., description="Authorization key from Sber studio")
    
    # Эти поля больше не обязательны. Можно оставить для обратной совместимости,
    # сделав их необязательными (Optional), или просто удалить.
    GIGACHAT_CLIENT_ID: Optional[str] = Field(None, description="Client ID (not needed)")
    
    GIGACHAT_CLIENT_SECRET: Optional[str] = Field(None, description="Client Secret (not needed)")
    
    # Модель и инструкция
    MODEL: str = Field(default="GigaChat", description="AI model name")
    SYSTEM_INSTRUCTION: str = Field(
        default="Ты - полезный ассистент. Отвечай на русском языке четко и по делу.",
        description="System instruction for AI"
    )
    
    # Серверные настройки
    HOST: str = Field(default="127.0.0.1", description="Host to bind")
    PORT: int = Field(default=8000, description="Port to bind")
    DEBUG: bool = Field(default=True, description="Debug mode")
    
    # SSL и логирование
    VERIFY_SSL: bool = Field(default=False, description="Verify SSL certificates")
    LOG_LEVEL: str = Field(default="INFO", description="Logging level")
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True
        extra = "ignore"  # Игнорировать лишние поля в .env

# Создаем глобальный экземпляр настроек
settings = Settings()