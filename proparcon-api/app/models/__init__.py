"""
====================================================================
ARCHIVO: app/models/__init__.py
PROYECTO: PROPARCON API
DESCRIPCIÓN:
    Punto único de exportación del paquete de modelos SQLAlchemy.

REGLAS:
    - Solo se importan modelos que existen en app/models para no romper
      imports ni migraciones.
    - Base se exporta para que Alembic y tooling puedan acceder a metadata.
====================================================================
"""

# -------------------------------------------------------------------
# SECCIÓN 1: Base declarativa
# -------------------------------------------------------------------
from .base import Base

# -------------------------------------------------------------------
# SECCIÓN 2: Modelos disponibles en el paquete (según directorio actual)
# -------------------------------------------------------------------
from .users import User

__all__ = [
    "Base",
    "User",
]
