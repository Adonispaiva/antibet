from fastapi import FastAPI
import logging

# Importações de configurações e rotas
from app.config.settings import settings # Card 5
from app.api.advertorial_detector_router import advertorial_detector_router

# --- Configuração de Logging ---
# Configura o logger para mostrar logs no console
logging.basicConfig(level=logging.INFO if not settings.DEBUG else logging.DEBUG)
logger = logging.getLogger(__name__)


# --- Inicialização do FastAPI ---
def create_application() -> FastAPI:
    """
    Cria e configura a instância principal do FastAPI.
    """
    application = FastAPI(
        title=settings.PROJECT_NAME,
        debug=settings.DEBUG,
        version="0.1.0",
        docs_url=f"{settings.API_V1_STR}/docs" if settings.DEBUG else None,
        redoc_url=f"{settings.API_V1_STR}/redoc" if settings.DEBUG else None,
    )

    # 1. Registro de Rotas
    # Router de Detecção (Cards 1, 2, 3)
    application.include_router(
        advertorial_detector_router, 
        prefix=settings.API_V1_STR, 
        tags=["Advertorial Detector"]
    )
    
    # 2. Log de Startup
    if settings.DEBUG:
        logger.info(f"Modo Debug: {settings.DEBUG}")
        logger.info(f"API V1 Prefix: {settings.API_V1_STR}")
        logger.info(f"SPA List Path: {settings.SPA_LIST_FILE_PATH}")
        
    return application

app = create_application()


# --- Health Check Route ---
@app.get("/", summary="Health Check", tags=["System"])
async def root():
    """
    Retorna o status da API e informações básicas.
    """
    return {
        "message": "AntiBet Backend API is running smoothly.",
        "project": settings.PROJECT_NAME,
        "debug": settings.DEBUG
    }

# Para rodar com Uvicorn:
# uvicorn main:app --reload