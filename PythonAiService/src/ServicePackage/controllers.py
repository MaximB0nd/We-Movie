from fastapi import APIRouter, HTTPException, Request
from src.ServicePackage.service import Service
import logging

logger = logging.getLogger(__name__)

class AIController:
    """
    Контроллер для обработки AI запросов через GigaChat
    """
    
    def __init__(self):
        # Создаем сервис без передачи аргументов
        self.service = Service()
        self.router = APIRouter(prefix="/api/v1/ai", tags=["AI"])
        self._setup_routes()
        logger.info("✅ AIController initialized successfully")
    
    def _setup_routes(self):
        """Настройка маршрутов"""
        self.router.add_api_route(
            path="/ask/{query}",
            endpoint=self.ask_get,
            methods=["GET"],
            response_model=dict,
            summary="Ask AI (GET)"
        )
        
        self.router.add_api_route(
            path="/ask",
            endpoint=self.ask_post,
            methods=["POST"],
            response_model=dict,
            summary="Ask AI (POST)"
        )
        
        self.router.add_api_route(
            path="/health",
            endpoint=self.health_check,
            methods=["GET"],
            response_model=dict,
            summary="Health check"
        )
    
    async def ask_get(self, query: str) -> dict:
        """GET endpoint"""
        try:
            if not query:
                raise HTTPException(status_code=400, detail="Query cannot be empty")
            
            response = self.service.ask_ai(query)
            if response is None:
                raise HTTPException(status_code=503, detail="Failed to get response from AI service")
            
            return {
                "success": True,
                "query": query,
                "response": response
            }
        except Exception as e:
            logger.error(f"Error in ask_get: {e}")
            raise HTTPException(status_code=500, detail=str(e))
    
    async def ask_post(self, request: Request) -> dict:
        """POST endpoint"""
        try:
            body = await request.json()
            query = body.get("query") or body.get("message")
            
            if not query:
                raise HTTPException(status_code=400, detail="Missing query field")
            
            response = self.service.ask_ai(query)
            if response is None:
                raise HTTPException(status_code=503, detail="Failed to get response from AI service")
            
            return {
                "success": True,
                "query": query,
                "response": response
            }
        except Exception as e:
            logger.error(f"Error in ask_post: {e}")
            raise HTTPException(status_code=500, detail=str(e))
    
    async def health_check(self) -> dict:
        """Health check endpoint"""
        return {
            "status": "healthy",
            "service": "GigaChat AI"
        }