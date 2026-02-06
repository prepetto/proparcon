# app/api/v1/endpoints/login_router.py (o su archivo de login)

from typing import Optional # 🚨 CORRECCIÓN: Importar Optional
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm 
from sqlalchemy.orm import Session
from pydantic import BaseModel # 🚨 CORRECCIÓN: Importar BaseModel

# ====================================================================
# IMPORTACIONES CLAVE
# ====================================================================

from app.api.infra import get_db 
from app.core.security import verify_password, create_access_token 
from app.models.users import User # Importa el modelo de la tabla de usuarios

# Asumiendo que el modelo Token está definido aquí para evitar problemas de importación
class Token(BaseModel):
    access_token: str
    token_type: str
    role: str
    full_name: Optional[str] = None


router = APIRouter(tags=["authentication"])

@router.post("/auth/login", response_model=Token, summary="Genera token JWT para usuarios de aplicación")
def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    # 1. Buscar usuario por email en la tabla DEDICADA 'users'
    user = db.query(User).filter(User.email == form_data.username).first()

    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciales inválidas o usuario inactivo",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # 2. Verificar la contraseña hasheada
    if not verify_password(form_data.password, user.hashed_password): 
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Contraseña incorrecta",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # 3. Crear el token JWT
    access_token = create_access_token(
        data={
            "sub": user.email, 
            "role": user.role, 
            "user_id": str(user.id),
            "full_name": user.full_name 
        }
    )

    # 4. Devolver el token
    return Token(
        access_token=access_token, 
        token_type="bearer", 
        role=user.role,
        full_name=user.full_name
    )