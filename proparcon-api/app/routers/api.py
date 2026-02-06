"""
====================================================================
ARCHIVO: app/routers/api.py
PROYECTO: PROPARCON API
DESCRIPCIÓN:
    Agregador de routers funcionales para FastAPI con RBAC por dominio.

CRITERIO DE DISEÑO:
    - Solo se incluyen routers de dominio (app/api/*.py).
    - Auth y Users se gestionan EXCLUSIVAMENTE como endpoints versionados
      desde main.py (/v1/auth, /v1/users).
    - RBAC se aplica a nivel de include_router().
====================================================================
"""

from fastapi import APIRouter, Depends

# -------------------------------------------------------------------
# Dependencias de autorización (RBAC)
# -------------------------------------------------------------------
from app.api.deps import RoleChecker
from app.models.users import UserRole

# -------------------------------------------------------------------
# Routers de dominio (app/api/*.py)
# Cada módulo debe exponer: router = APIRouter()
# -------------------------------------------------------------------
from app.api import (
    catalogos,
    contrato,
    estancia,
    infra,
    inmueble,
    oferta,
    persona,
    propiedad,
)

# -------------------------------------------------------------------
# Router maestro
# -------------------------------------------------------------------
api_router = APIRouter()

# -------------------------------------------------------------------
# RUTAS PÚBLICAS / INFRA
# -------------------------------------------------------------------
api_router.include_router(
    infra.router,
    prefix="/infra",
    tags=["infra"],
)

api_router.include_router(
    catalogos.router,
    prefix="/catalogos",
    tags=["catalogos"],
)

# -------------------------------------------------------------------
# RUTAS CON RBAC: GESTOR o ADMIN
# -------------------------------------------------------------------
gestor_or_admin = Depends(
    RoleChecker([UserRole.ADMIN, UserRole.GESTOR])
)

api_router.include_router(
    inmueble.router,
    prefix="/inmueble",
    tags=["inmueble"],
    dependencies=[gestor_or_admin],
)

api_router.include_router(
    estancia.router,
    prefix="/estancia",
    tags=["estancia"],
    dependencies=[gestor_or_admin],
)

api_router.include_router(
    oferta.router,
    prefix="/oferta",
    tags=["oferta"],
    dependencies=[gestor_or_admin],
)

# -------------------------------------------------------------------
# RUTAS CON RBAC: SOLO ADMIN
# -------------------------------------------------------------------
admin_only = Depends(RoleChecker([UserRole.ADMIN]))

api_router.include_router(
    persona.router,
    prefix="/persona",
    tags=["persona"],
    dependencies=[admin_only],
)

api_router.include_router(
    propiedad.router,
    prefix="/propiedad",
    tags=["propiedad"],
    dependencies=[admin_only],
)

api_router.include_router(
    contrato.router,
    prefix="/contrato",
    tags=["contrato"],
    dependencies=[admin_only],
)

__all__ = ["api_router"]
