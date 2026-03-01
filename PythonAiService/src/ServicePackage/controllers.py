from fastapi import APIRouter, HTTPException, Request
from src.ServicePackage.service import Service
from src.config import settings
import logging
from typing import Optional

logger = logging.getLogger(__name__)

class AIController:
    """
    Контроллер для обработки AI запросов через GigaChat
    """
    
    def __init__(self):
        self.service = Service(settings)
        self.router = APIRouter(prefix="/api/v1/ai", tags=["AI"])
        self._setup_routes()
    
    def _setup_routes(self):
        """Настройка маршрутов"""
        self.router.add_api_route(
            path="/ask/{query}",
            endpoint=self.ask_get,
            methods=["GET"],
            response_model=dict,
            summary="Ask AI (GET)",
            description="Send a query to GigaChat via GET request"
        )
        
        self.router.add_api_route(
            path="/ask",
            endpoint=self.ask_post,
            methods=["POST"],
            response_model=dict,
            summary="Ask AI (POST)",
            description="Send a query to GigaChat via POST request"
        )
        
        self.router.add_api_route(
            path="/chat",
            endpoint=self.chat,
            methods=["POST"],
            response_model=dict,
            summary="Chat with AI",
            description="Send a chat conversation to GigaChat"
        )
        
        self.router.add_api_route(
            path="/health",
            endpoint=self.health_check,
            methods=["GET"],
            response_model=dict,
            summary="Health check",
            description="Check if AI service is healthy"
        )
    
    async def ask_get(self, query: str) -> dict:
        """
        GET endpoint для простых запросов
        
        Args:
            query: Текст запроса
            
        Returns:
            Ответ от GigaChat
        """
        try:
            if not query or len(query.strip()) == 0:
                raise HTTPException(status_code=400, detail="Query cannot be empty")
            
            response = self.service.ask_ai(query)
            if response is None:
                raise HTTPException(status_code=503, detail="Failed to get response from AI service")
            
            return {
                "success": True,
                "query": query,
                "response": response,
                "model": settings.MODEL
            }
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"❌ Error in ask_get: {e}")
            raise HTTPException(status_code=500, detail=str(e))
    
    async def ask_post(self, request: Request) -> dict:
        """
        POST endpoint для запросов
        
        Args:
            request: POST запрос с JSON телом
        """
        try:
            body = await request.json()
            query = body.get("query") or body.get("message")
            
            if not query:
                raise HTTPException(
                    status_code=400, 
                    detail="Missing query or message field in request body"
                )
            
            response = self.service.ask_ai(query)
            if response is None:
                raise HTTPException(status_code=503, detail="Failed to get response from AI service")
            
            return {
                "success": True,
                "query": query,
                "response": response,
                "model": settings.MODEL
            }
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"❌ Error in ask_post: {e}")
            raise HTTPException(status_code=500, detail=str(e))
    
    async def chat(self, request: Request) -> dict:
        """
        POST endpoint для чата с историей
        
        Args:
            request: POST запрос с массивом сообщений
        """
        try:
            body = await request.json()
            messages = body.get("messages")
            
            if not messages or not isinstance(messages, list):
                raise HTTPException(
                    status_code=400, 
                    detail="Messages array is required"
                )
            
            # Используем клиент напрямую для чата с историей
            response = self.service.gigachat_client.send_chat_request(messages)
            if response is None:
                raise HTTPException(status_code=503, detail="Failed to get response from AI service")
            
            return {
                "success": True,
                "response": response,
                "model": settings.MODEL
            }
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"❌ Error in chat: {e}")
            raise HTTPException(status_code=500, detail=str(e))
    
    async def health_check(self) -> dict:
        """Проверка здоровья сервиса"""
        try:
            # Пробуем получить токен для проверки соединения
            token = self.service.gigachat_client._get_token()
            return {
                "status": "healthy" if token else "unhealthy",
                "model": settings.MODEL,
                "gigachat_connected": token is not None
            }
        except Exception as e:
            logger.error(f"❌ Health check failed: {e}")
            return {
                "status": "unhealthy",
                "error": str(e)
            }
