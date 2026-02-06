# app/core/auth_deps.py
# Contiene la lógica para obtener el usuario actual y verificar roles (RoleChecker).

from typing import Optional, List, Annotated, Dict, Any
from fastapi import Depends, HTTPException, status, Security
from sqlalchemy.orm import Session
from sqlalchemy.sql import text
from jose import JWTError, jwt
from pydantic import BaseModel, EmailStr

# Importaciones CLAVE
from app.api.infra import get_db 
from app.core.security import oauth2_scheme, SECRET_KEY, ALGORITHM # De tu security.py

# -------------------------------------------------------------------
# SCHEMAS DE AUTORIZACIÓN
# -------------------------------------------------------------------

class CurrentUser(BaseModel):
    """Modelo inyectado que representa el usuario autenticado."""
    id: int
    email: EmailStr
    roles: List[str] # Lista de códigos de roles (e.g., ['ADMIN', 'GESTOR'])
    nombre: str
    apellido1: str

# -------------------------------------------------------------------
# DEPENDENCIAS DE AUTORIZACIÓN
# -------------------------------------------------------------------

# (La función get_persona_data_from_db se movería aquí o se haría inline)

# Configuración síncrona)
def get_current_persona(token: Annotated[str, Depends(oauth2_scheme)], db: Session = Depends(get_db)) -> CurrentUser: 
    """Decodifica el JWT, verifica la validez y retorna el objeto CurrentUser."""
    
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Token inválido o expirado",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        # Decodificar el token
        payload: Dict[str, Any] = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        
        # Asumiendo que el token tiene 'persona_id' y 'roles'
        persona_id: Optional[int] = payload.get("persona_id")
        roles: Optional[List[str]] = payload.get("roles")

        if persona_id is None or roles is None:
            raise credentials_exception
        
    except JWTError:
        raise credentials_exception
    
    # 📌 RECARGA DE DATOS (Mismo query que en tu persona.py)
    sql_current_user = text("""
        SELECT p.id, p.email_particular, p.nombre, p.apellido1
        FROM proparcon.persona p
        WHERE p.id = :id;
    """)
    persona_row = db.execute(sql_current_user, {"id": persona_id}).mappings().first()
    
    if persona_row is None:
        raise credentials_exception 
        
    return CurrentUser(
        id=persona_row["id"],
        email=persona_row["email_particular"],
        roles=roles, 
        nombre=persona_row["nombre"],
        apellido1=persona_row["apellido1"]
    )

class RoleChecker:
    """Clase dependiente que verifica si el usuario autenticado tiene uno de los roles requeridos."""
    
    def __init__(self, required_roles: List[str]):
        self.required_roles = required_roles

    def __call__(self, current_persona: CurrentUser = Security(get_current_persona)) -> CurrentUser:
        
        if not self.required_roles:
            return current_persona 
            
        has_permission = any(role in current_persona.roles for role in self.required_roles)

        if not has_permission:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="No tiene permisos suficientes. Roles requeridos: " + ", ".join(self.required_roles),
            )
            
        return current_persona