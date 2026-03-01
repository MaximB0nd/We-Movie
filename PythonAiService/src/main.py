from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from src.ServicePackage.controllers import AIController
from src.config import settings
import logging
import uvicorn

logging.basicConfig(level=getattr(logging, settings.LOG_LEVEL))
logger = logging.getLogger(__name__)

def create_app() -> FastAPI:
    """Фабрика приложения FastAPI"""
    
    app = FastAPI(
        title="GigaChat Microservice",
        description="Microservice for interacting with GigaChat AI",
        version="1.0.0",
        debug=settings.DEBUG
    )
    
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
        return {
            "name": "GigaChat Microservice",
            "version": "1.0.0",
            "status": "running"
        }
    
    @app.get("/health")
    async def health():
        return {"status": "healthy"}
    
    return app

app = create_app()

if __name__ == "__main__":
    uvicorn.run(
        "src.main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG
    )