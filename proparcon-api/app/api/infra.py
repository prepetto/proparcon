"""
====================================================================
INFRA.PY: Guardián de Salud del Sistema (Health Check)
====================================================================
Estado: ✅ Revisado
Sección: Mantenimiento e Infraestructura
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy.sql import text

# 📌 IMPORTACIONES DE SEGURIDAD
from app.api.deps import get_db, RoleChecker
from app.models.users import UserRole

router = APIRouter(prefix="/api/infra", tags=["Infraestructura"])

@router.get("/health")
def health_status(
    db: Session = Depends(get_db),
    _ = Depends(RoleChecker([UserRole.ADMIN]))
):
    """Endpoint crítico para verificar la conexión real con PostgreSQL."""
    try:
        # Prueba de fuego: consulta al esquema proparcon
        db.execute(text("SELECT 1 FROM proparcon.users LIMIT 1"))
        return {
            "status": "online",
            "db_connection": "established",
            "schema": "proparcon",
            "rbac": "active"
        }
    except Exception as e:
        return {
            "status": "error",
            "message": f"Fallo en infraestructura: {str(e)}"
        }