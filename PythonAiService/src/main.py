from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from src.ServicePackage.controllers import AIController
from src.config import settings
import logging
import uvicorn

# Настройка логирования
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def create_app() -> FastAPI:
    """
    Фабрика приложения FastAPI
    
    Returns:
        Настроенное FastAPI приложение
    """
    # Проверяем наличие обязательных настроек
    if not settings.GIGACHAT_CLIENT_ID or not settings.GIGACHAT_CLIENT_SECRET:
        logger.error("❌ GigaChat credentials not configured!")
        logger.error("Please set GIGACHAT_CLIENT_ID and GIGACHAT_CLIENT_SECRET in .env file")
        logger.error("Application will start but AI endpoints may not work")
    
    app = FastAPI(
        title="GigaChat Microservice",
        description="Microservice for interacting with GigaChat AI (Sber)",
        version="1.0.0",
        debug=settings.DEBUG
    )
    
    # Добавляем CORS middleware
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    
    # Инициализация контроллера
    try:
        ai_controller = AIController()
        app.include_router(ai_controller.router)
        logger.info("✅ AI Controller initialized successfully")
    except Exception as e:
        logger.error(f"❌ Failed to initialize AI Controller: {e}")
        logger.error("AI endpoints will not be available")
    
    @app.get("/")
    async def root():
        """Корневой endpoint"""
        return {
            "name": "GigaChat Microservice",
            "version": "1.0.0",
            "status": "running",
            "model": settings.MODEL,
            "gigachat_configured": bool(settings.GIGACHAT_CLIENT_ID and settings.GIGACHAT_CLIENT_SECRET)
        }
    
    @app.get("/health")
    async def health():
        """Health check endpoint"""
        return {
            "status": "healthy",
            "gigachat_configured": bool(settings.GIGACHAT_CLIENT_ID and settings.GIGACHAT_CLIENT_SECRET)
        }
    
    logger.info(f"✅ Application created successfully. Listening on {settings.HOST}:{settings.PORT}")
    return app

app = create_app()

if __name__ == "__main__":
    uvicorn.run(
        "src.main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG
    )
