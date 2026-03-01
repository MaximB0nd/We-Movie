from src.ClientPackage.client import GigaChatClient  # Обратите внимание на заглавную G
from src.config import Settings  # Импортируем класс Settings
import logging
from typing import Optional

logger = logging.getLogger(__name__)

class Service:
    def __init__(self, settings: Optional[Settings] = None):
        self.settings = settings or Settings()

        # Проверяем наличие учетных данных
        if not self.settings.GIGACHAT_CLIENT_ID or not self.settings.GIGACHAT_CLIENT_SECRET:
            logger.error("GigaChat credentials not found in settings")
            logger.error("Please set GIGACHAT_CLIENT_ID and GIGACHAT_CLIENT_SECRET in .env file")
            logger.error("Get credentials at: https://developers.sber.ru/studio")
            raise ValueError("GigaChat credentials are required")

        # Инициализируем GigaChat клиент
        try:
            self.gigachat_client = GigaChatClient(
                model=self.settings.MODEL,
                system_instruction=self.settings.SYSTEM_INSTRUCTION,
                client_id=self.settings.GIGACHAT_CLIENT_ID,
                client_secret=self.settings.GIGACHAT_CLIENT_SECRET,
                verify_ssl=self.settings.VERIFY_SSL
            )
            logger.info(f"Service initialized with GigaChat model: {self.settings.MODEL}")
        except Exception as e:
            logger.error(f"Failed to initialize GigaChat client: {e}")
            raise

    def ask_ai(self, message: str) -> Optional[str]:
        if not message or not message.strip():
            logger.warning("Empty message received")
            return None

        logger.info(f"Sending request to GigaChat: {message[:100]}...")
        try:
            response = self.gigachat_client.send_request(message)
            if response:
                logger.info(f"Response received from GigaChat ({len(response)} chars)")
                return response
            else:
                logger.warning("Empty response from GigaChat")
                return None
        except Exception as e:
            logger.error(f"Error in ask_ai: {e}")
            return None
