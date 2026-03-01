from pydantic_settings import BaseSettings
from pydantic import Field
from typing import Optional

class Settings(BaseSettings):
    """
    Настройки приложения с GigaChat
    """
    # GigaChat settings - обязательные параметры
    GIGACHAT_CLIENT_ID: str = Field(..., description="GigaChat Client ID (обязательно)")
    GIGACHAT_CLIENT_SECRET: str = Field(..., description="GigaChat Client Secret (обязательно)")
    
    # Model settings
    MODEL: str = Field(
        default="GigaChat", 
        description="AI model name (GigaChat, GigaChat-Pro, GigaChat-Lite, GigaChat-Max)"
    )
    
    # System instruction
    SYSTEM_INSTRUCTION: str = Field(
        default="Ты - полезный ассистент. Отвечай на русском языке четко и по делу. "
                "Помогай пользователям с их вопросами. Будь вежливым и профессиональным.",
        description="System instruction for AI"
    )
    
    # Server settings
    HOST: str = Field(default="0.0.0.0", description="Host to bind")
    PORT: int = Field(default=8000, description="Port to bind")
    DEBUG: bool = Field(default=False, description="Debug mode")
    
    # SSL settings для GigaChat
    VERIFY_SSL: bool = Field(default=False, description="Verify SSL certificates")
    
    # Logging
    LOG_LEVEL: str = Field(default="INFO", description="Logging level")
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True
        extra = "ignore"

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        # Проверка наличия обязательных полей
        if not self.GIGACHAT_CLIENT_ID:
            print("❌ GIGACHAT_CLIENT_ID is required but not set in .env file")
            print("   Get your credentials at: https://developers.sber.ru/studio")
        if not self.GIGACHAT_CLIENT_SECRET:
            print("❌ GIGACHAT_CLIENT_SECRET is required but not set in .env file")
            print("   Get your credentials at: https://developers.sber.ru/studio")
        if self.GIGACHAT_CLIENT_ID and self.GIGACHAT_CLIENT_SECRET:
            print("✅ GigaChat credentials loaded successfully")

# Создаем глобальный экземпляр настроек
settings = Settings()
