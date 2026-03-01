import os
import requests
import json
import time
from typing import Optional, Dict, Any, List
import logging
from datetime import datetime, timedelta

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
                 client_id: Optional[str] = None,
                 client_secret: Optional[str] = None,
                 scope: str = "GIGACHAT_API_PERS",
                 verify_ssl: bool = False,
                 timeout: int = 30):
        """
        Инициализация клиента GigaChat
        
        Args:
            model: Название модели (GigaChat, GigaChat-Pro, GigaChat-Lite, GigaChat-Max)
            system_instruction: Системная инструкция
            client_id: Client ID для авторизации
            client_secret: Client Secret для авторизации
            scope: Область доступа
            verify_ssl: Проверять SSL сертификаты
            timeout: Таймаут запросов в секундах
        """
        self.model = model
        self.system_instruction = system_instruction
        self.scope = scope
        self.verify_ssl = verify_ssl
        self.timeout = timeout
        
        # Получаем учетные данные из параметров или переменных окружения
        self.client_id = client_id or os.getenv("GIGACHAT_CLIENT_ID")
        self.client_secret = client_secret or os.getenv("GIGACHAT_CLIENT_SECRET")
        
        if not self.client_id or not self.client_secret:
            raise ValueError(
                "GigaChat credentials not found. Please provide client_id and client_secret "
                "or set GIGACHAT_CLIENT_ID and GIGACHAT_CLIENT_SECRET in .env file\n"
                "Get your credentials at: https://developers.sber.ru/studio"
            )
        
        self.access_token = None
        self.token_expires_at = 0
        logger.info(f"✅ GigaChat client initialized with model: {model}")
    
    def _get_token(self) -> Optional[str]:
        """
        Получение токена доступа
        Документация: https://developers.sber.ru/docs/ru/gigachat/api/authorization
        """
        # Проверяем, не истек ли текущий токен
        current_time = time.time()
        if self.access_token and current_time < self.token_expires_at:
            return self.access_token
        
        try:
            import base64
            auth_string = f"{self.client_id}:{self.client_secret}"
            auth_base64 = base64.b64encode(auth_string.encode()).decode()
            
            headers = {
                "Content-Type": "application/x-www-form-urlencoded",
                "Accept": "application/json",
                "Authorization": f"Basic {auth_base64}"
            }
            
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
                    max_tokens: int = 1000,
                    top_p: float = 0.9,
                    n: int = 1) -> Optional[str]:
        """
        Отправка запроса к GigaChat
        
        Args:
            message: Сообщение пользователя
            temperature: Температура генерации (0.0 - 1.0)
            max_tokens: Максимальное количество токенов в ответе
            top_p: Top-p sampling параметр
            n: Количество вариантов ответа
            
        Returns:
            Ответ от GigaChat или None в случае ошибки
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
            
            # Формируем сообщения
            messages = []
            
            # Добавляем системную инструкцию, если она есть
            if self.system_instruction:
                messages.append({
                    "role": "system",
                    "content": self.system_instruction
                })
            
            # Добавляем сообщение пользователя
            messages.append({
                "role": "user",
                "content": message
            })
            
            payload = {
                "model": self.model,
                "messages": messages,
                "temperature": temperature,
                "max_tokens": max_tokens,
                "top_p": top_p,
                "n": n
            }
            
            logger.info(f"Sending request to GigaChat ({self.model})...")
            response = requests.post(
                f"{self.API_URL}/chat/completions",
                headers=headers,
                json=payload,
                verify=self.verify_ssl,
                timeout=self.timeout
            )
            
            if response.status_code == 200:
                result = response.json()
                # Извлекаем текст ответа
                if result.get("choices") and len(result["choices"]) > 0:
                    content = result["choices"][0].get("message", {}).get("content", "")
                    usage = result.get("usage", {})
                    logger.info(f"✅ Response received. Tokens used: {usage.get('total_tokens', 'unknown')}")
                    return content
                else:
                    logger.warning("⚠️ No content in response")
                    return None
            else:
                logger.error(f"❌ API error: {response.status_code} - {response.text}")
                return None
                
        except requests.exceptions.Timeout:
            logger.error("❌ Timeout while sending request to GigaChat")
            return None
        except requests.exceptions.ConnectionError:
            logger.error("❌ Connection error while sending request to GigaChat")
            return None
        except Exception as e:
            logger.error(f"❌ Error sending request to GigaChat: {e}")
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
