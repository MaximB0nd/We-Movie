import requests
import base64  
import uuid
import time
from typing import Optional, Dict, List
import logging

logger = logging.getLogger(__name__)

class GigaChatClient:
    """
    Клиент для работы с GigaChat API от Сбера
    Документация: https://developers.sber.ru/docs/ru/gigachat/api/overview
    """
    
    # Базовые URL для API
    AUTH_URL = "https://ngw.devices.sberbank.ru:9443/api/v2/oauth"
    API_URL = "https://gigachat.devices.sberbank.ru/api/v1"
    
    def __init__(self, 
             model: str = "GigaChat", 
             system_instruction: Optional[str] = None,
             auth_key: Optional[str] = None,
             client_id: Optional[str] = None,
             client_secret: Optional[str] = None,
             scope: str = "GIGACHAT_API_PERS",
             verify_ssl: bool = False,
             timeout: int = 30):
        """
        Инициализация клиента GigaChat
        """
        self.model = model
        self.system_instruction = system_instruction
        self.scope = scope
        self.verify_ssl = verify_ssl
        self.timeout = timeout
        
        # Сохраняем оба варианта
        self.auth_key = auth_key
        self.client_id = client_id
        self.client_secret = client_secret
        
        # Проверяем наличие хотя бы одного варианта
        if not (self.auth_key or (self.client_id and self.client_secret)):
            raise ValueError(
                "GigaChat credentials not found. Please provide auth_key "
                "or both client_id and client_secret"
            )
        
        self.access_token = None
        self.token_expires_at = 0
        logger.info(f"✅ GigaChat client initialized with model: {model}")
    
    def _generate_rquid(self) -> str:
            """
            Генерация уникального идентификатора для запроса (RqUID)
            Требуется GigaChat API для каждого запроса
            """
            return str(uuid.uuid4())

    def _get_token(self) -> Optional[str]:
        """
        Получение токена доступа
        """
        current_time = time.time()
        if self.access_token and current_time < self.token_expires_at:
            return self.access_token
        
        try:
            # Определяем заголовок Authorization
            if self.auth_key:
                # Используем готовый ключ
                auth_header = f"Basic {self.auth_key}"
                logger.debug("Using auth_key for authorization")
            elif self.client_id and self.client_secret:
                # Формируем из client_id и client_secret
                auth_string = f"{self.client_id}:{self.client_secret}"
                auth_base64 = base64.b64encode(auth_string.encode()).decode()
                auth_header = f"Basic {auth_base64}"
                logger.debug("Using client_id:client_secret pair for authorization")
            else:
                logger.error("No authorization credentials provided")
                return None
            
            headers = {
                "Content-Type": "application/x-www-form-urlencoded",
                "Accept": "application/json",
                "Authorization": auth_header,
                "RqUID": self._generate_rquid()
            }
        
        # ... остальной код без изменений
            
            data = {"scope": self.scope}
            
            logger.info("Requesting new access token from GigaChat...")
            response = requests.post(
                f"{self.AUTH_URL}",
                headers=headers,
                data=data,
                verify=self.verify_ssl,
                timeout=self.timeout
            )
            
            if response.status_code == 200:
                token_data = response.json()
                self.access_token = token_data.get("access_token")
                expires_in = token_data.get("expires_in", 3600)
                self.token_expires_at = time.time() + expires_in - 60  # Запас 60 секунд
                logger.info("✅ Successfully obtained GigaChat access token")
                return self.access_token
            else:
                logger.error(f"❌ Failed to get token: {response.status_code} - {response.text}")
                return None
                
        except requests.exceptions.Timeout:
            logger.error("❌ Timeout while getting token")
            return None
        except requests.exceptions.ConnectionError:
            logger.error("❌ Connection error while getting token")
            return None
        except Exception as e:
            logger.error(f"❌ Error getting token: {e}")
            return None
    
    def send_request(self, 
                message: str, 
                temperature: float = 0.7,
                max_tokens: int = 1000) -> Optional[str]:
        """
        Отправка запроса к GigaChat
        """
        try:
            token = self._get_token()
            if not token:
                logger.error("❌ Failed to obtain access token")
                return None
            
            logger.debug(f"Using token: {token[:50]}...")
            
            headers = {
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json"
            }
            
            messages = []
            if self.system_instruction:
                messages.append({
                    "role": "system",
                    "content": self.system_instruction
                })
            
            messages.append({
                "role": "user",
                "content": message
            })
            
            payload = {
                "model": self.model,
                "messages": messages,
                "temperature": temperature,
                "max_tokens": max_tokens
            }
            
            logger.debug(f"Payload: {payload}")
            logger.info(f"📡 Sending request to GigaChat API...")
            
            response = requests.post(
                f"{self.API_URL}/chat/completions",
                headers=headers,
                json=payload,
                verify=self.verify_ssl,
                timeout=self.timeout
            )
            
            logger.info(f"Response status: {response.status_code}")
            logger.debug(f"Response headers: {response.headers}")
            logger.debug(f"Response body: {response.text[:500]}")
            
            if response.status_code == 200:
                result = response.json()
                if result.get("choices") and len(result["choices"]) > 0:
                    content = result["choices"][0].get("message", {}).get("content", "")
                    return content
                else:
                    logger.warning("No choices in response")
                    return None
            else:
                logger.error(f"❌ API error: {response.status_code}")
                logger.error(f"Response body: {response.text}")
                return None
                
        except requests.exceptions.Timeout:
            logger.error("❌ Timeout while sending request")
            return None
        except requests.exceptions.ConnectionError as e:
            logger.error(f"❌ Connection error: {e}")
            return None
        except Exception as e:
            logger.error(f"❌ Error sending request: {e}")
            return None
    
    def send_chat_request(self, 
                          messages: List[Dict[str, str]], 
                          temperature: float = 0.7,
                          max_tokens: int = 1000) -> Optional[str]:
        """
        Отправка запроса с полным контекстом диалога
        
        Args:
            messages: Список сообщений в формате 
                     [{"role": "user/system/assistant", "content": "текст"}]
            temperature: Температура генерации
            max_tokens: Максимальное количество токенов
            
        Returns:
            Ответ от GigaChat
        """
        try:
            token = self._get_token()
            if not token:
                logger.error("❌ Failed to obtain access token")
                return None
            
            headers = {
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json"
            }
            
            # Добавляем системную инструкцию, если её нет в сообщениях
            if self.system_instruction and not any(m["role"] == "system" for m in messages):
                messages.insert(0, {
                    "role": "system",
                    "content": self.system_instruction
                })
            
            payload = {
                "model": self.model,
                "messages": messages,
                "temperature": temperature,
                "max_tokens": max_tokens
            }
            
            logger.info(f"Sending chat request to GigaChat ({self.model})...")
            response = requests.post(
                f"{self.API_URL}/chat/completions",
                headers=headers,
                json=payload,
                verify=self.verify_ssl,
                timeout=self.timeout
            )
            
            if response.status_code == 200:
                result = response.json()
                if result.get("choices") and len(result["choices"]) > 0:
                    content = result["choices"][0].get("message", {}).get("content", "")
                    logger.info("✅ Chat response received")
                    return content
            else:
                logger.error(f"❌ API error: {response.status_code} - {response.text}")
                return None
                
        except Exception as e:
            logger.error(f"❌ Error in send_chat_request: {e}")
            return None
