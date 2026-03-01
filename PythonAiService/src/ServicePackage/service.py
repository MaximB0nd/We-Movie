from src.ClientPackage.client import GigaChatClient
from src.config import settings
import logging

logger = logging.getLogger(__name__)

class Service:
    def __init__(self):
        """Инициализация сервиса с GigaChat"""
        self.settings = settings
        
        # Проверяем наличие учетных данных (поддержка обоих вариантов)
        has_auth_key = hasattr(self.settings, 'GIGACHAT_AUTH_KEY') and self.settings.GIGACHAT_AUTH_KEY
        has_client_creds = (hasattr(self.settings, 'GIGACHAT_CLIENT_ID') and self.settings.GIGACHAT_CLIENT_ID and 
                           hasattr(self.settings, 'GIGACHAT_CLIENT_SECRET') and self.settings.GIGACHAT_CLIENT_SECRET)
        
        if not (has_auth_key or has_client_creds):
            logger.error("❌ GigaChat credentials not found")
            logger.error("Please set either GIGACHAT_AUTH_KEY or both GIGACHAT_CLIENT_ID and GIGACHAT_CLIENT_SECRET in .env file")
            raise ValueError("GigaChat credentials are required")
        
        try:
            # Передаём оба варианта, клиент сам выберет нужный
            self.gigachat_client = GigaChatClient(
                model=self.settings.MODEL,
                system_instruction=self.settings.SYSTEM_INSTRUCTION,
                auth_key=getattr(self.settings, 'GIGACHAT_AUTH_KEY', None),
                client_id=getattr(self.settings, 'GIGACHAT_CLIENT_ID', None),
                client_secret=getattr(self.settings, 'GIGACHAT_CLIENT_SECRET', None),
                verify_ssl=self.settings.VERIFY_SSL
            )
            logger.info(f"✅ Service initialized with model: {self.settings.MODEL}")
        except Exception as e:
            logger.error(f"❌ Failed to initialize GigaChat client: {e}")
            raise
    
    def ask_ai(self, message: str) -> str | None:
        """Отправка запроса к GigaChat"""
        if not message or not message.strip():
            logger.warning("⚠️ Empty message received")
            return None
        
        logger.info(f"📤 Sending request: {message[:50]}...")
        try:
            response = self.gigachat_client.send_request(message)
            if response:
                logger.info(f"📥 Response received ({len(response)} chars)")
                return response
            return None
        except Exception as e:
            logger.error(f"❌ Error: {e}")
            return None