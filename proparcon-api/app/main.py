"""
====================================================================
ARCHIVO: app/main.py
PROYECTO: PROPARCON API
====================================================================

OBJETIVO:
- Definir la instancia principal de FastAPI.
- Configurar middlewares globales (slash, CORS).
- Registrar routers versionados y funcionales.

DECISIONES DE DISEÑO:
- Auth SOLO va versionado (/v1/auth).
- El dominio funcional se expone bajo /api/* mediante agregador.
- Se evita cualquier redirección automática de slash.
====================================================================
"""

import logging

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware

# -------------------------------------------------------------------
# SECCIÓN 0: LOGGING BÁSICO
# -------------------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)

# -------------------------------------------------------------------
# SECCIÓN 1: INSTANCIA DE LA API
# -------------------------------------------------------------------
app = FastAPI(
    title="PROPARCON API",
    version="1.4.0",
    redirect_slashes=False,  # Evita 307/405 por trailing slash
)

logger.info("Inicializando PROPARCON API")

# -------------------------------------------------------------------
# SECCIÓN 2: MIDDLEWARE - NORMALIZACIÓN DE SLASH FINAL
# -------------------------------------------------------------------
@app.middleware("http")
async def remove_trailing_slash(request: Request, call_next):
    """
    Normaliza rutas con barra final:
        /api/persona/  -> /api/persona

    Evita redirecciones automáticas que rompen clientes web estrictos.
    """
    path = request.url.path
    if path != "/" and path.endswith("/"):
        request.scope["path"] = path.rstrip("/")
    return await call_next(request)

# -------------------------------------------------------------------
# SECCIÓN 3: CORS
# -------------------------------------------------------------------
# IMPORTANTE:
# allow_origins=["*"] es SOLO aceptable en desarrollo.
# En producción debe limitarse al dominio del frontend.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # DEV ONLY
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -------------------------------------------------------------------
# SECCIÓN 4: REGISTRO DE ROUTERS
# -------------------------------------------------------------------
# 4.1 Auth versionado
from app.api.v1.endpoints import auth as auth_v1

app.include_router(
    auth_v1.router,
    prefix="/v1/auth",
    tags=["Auth"],
)

# 4.2 API funcional (dominio) bajo /api
from app.routers.api import api_router

app.include_router(
    api_router,
    prefix="/api",
)

# -------------------------------------------------------------------
# SECCIÓN 5: ENDPOINTS DE SISTEMA
# -------------------------------------------------------------------
@app.get("/health", tags=["Sistema"])
async def health():
    """
    Healthcheck simple para balanceadores y monitorización.
    """
    return {
        "status": "ok",
        "service": "proparcon-api",
        "mode": "no-slash-strict",
    }
