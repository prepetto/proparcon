"""
====================================================================
DEPS.PY: Dependencias Globales e Inyección de Seguridad
====================================================================
Descripción: Gestiona la base de datos, JWT y Control de Acceso.
Secciones:
  1. Sección 1: Gestión de Base de Datos (Session Injection)
  2. Sección 2: Validación de Identidad (JWT Extraction)
  3. Sección 3: Control de Roles (RBAC - admin/gestor)
====================================================================
"""

from typing import Generator, List, Union
from fastapi import Depends, HTTPException, status
from jose import jwt, JWTError
from sqlalchemy.orm import Session

from app.core.db import SessionLocal
from app.core.security import oauth2_scheme, SECRET_KEY, ALGORITHM
from app.models.users import User  # Asegúrate de que User tenga el campo 'role'

# --------------------------------------------------------------------
# SECCIÓN 1: BASE DE DATOS
# --------------------------------------------------------------------
def get_db() -> Generator:
    """Inyección de sesión de SQLAlchemy para los endpoints."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --------------------------------------------------------------------
# SECCIÓN 2: VALIDACIÓN DE IDENTIDAD
# --------------------------------------------------------------------
def get_current_user(
    db: Session = Depends(get_db), 
    token: str = Depends(oauth2_scheme)
) -> User:
    """Extrae el email del sub del JWT y busca al usuario en BD."""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="No se pudo validar el token de acceso",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
        
    user = db.query(User).filter(User.email == email).first()
    if user is None:
        raise credentials_exception
    return user

# --------------------------------------------------------------------
# SECCIÓN 3: CONTROL DE ROLES (RBAC)
# --------------------------------------------------------------------
class RoleChecker:
    """
    Sincronizado con main.py ("admin", "gestor").
    Permite el uso de: Depends(RoleChecker(["admin", "gestor"]))
    """
    def __init__(self, allowed_roles: List[str]):
        # Aseguramos que los roles permitidos estén en el formato correcto
        self.allowed_roles = allowed_roles

    def __call__(self, current_user: User = Depends(get_current_user)):
        # Extraemos el valor del rol (manejando si es un Enum o un string)
        user_role = current_user.role.value if hasattr(current_user.role, 'value') else str(current_user.role)
        
        if user_role not in self.allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Permiso denegado. Se requiere uno de estos roles: {self.allowed_roles}. Tu rol es: {user_role}"
            )
        return current_user