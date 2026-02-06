"""
====================================================================
USERS.PY: Gestión de Cuentas de Acceso (Versión Full CRUD)
====================================================================
Secciones:
  1. Modelos Pydantic (Validación de entrada y esquemas de Update)
  2. Consulta de Usuarios (GET por ID / Me)
  3. Registro y Creación (POST) - Transaccional con persona_id
  4. Actualización Dinámica (PATCH)
  5. Eliminación Física (DELETE) - Limpieza de Ciclo
====================================================================
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr, Field
from sqlalchemy.orm import Session
from sqlalchemy.sql import text

from app.api.deps import get_db, RoleChecker, get_current_user
from app.core.security import get_password_hash
from app.models.users import User, UserRole

router = APIRouter()
admin_only = Depends(RoleChecker([UserRole.ADMIN]))

# --------------------------------------------------------------------
# SECCIÓN 1: MODELOS PYDANTIC
# --------------------------------------------------------------------

class UserCreate(BaseModel):
    id: str = Field(..., description="ID string (varchar 50)")
    persona_id: int
    email: EmailStr
    password: str = Field(..., min_length=4)
    role: UserRole = UserRole.LECTOR

class UserResponse(BaseModel):
    id: str
    persona_id: int
    email: EmailStr
    role: str
    is_active: bool

    class Config:
        from_attributes = True

class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    role: Optional[UserRole] = None
    is_active: Optional[bool] = None

# --------------------------------------------------------------------
# SECCIÓN 2: CONSULTA (GET)
# --------------------------------------------------------------------

@router.get("/me", response_model=UserResponse)
def leer_perfil_propio(current_user: User = Depends(get_current_user)):
    return current_user

@router.get("/{user_id}", response_model=UserResponse, dependencies=[admin_only])
def obtener_usuario(user_id: str, db: Session = Depends(get_db)):
    sql = text("SELECT id, persona_id, email, role, is_active FROM proparcon.users WHERE id = :id")
    res = db.execute(sql, {"id": user_id}).mappings().first()
    if not res:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return res

# --------------------------------------------------------------------
# SECCIÓN 3: REGISTRO Y CREACIÓN (POST)
# --------------------------------------------------------------------

@router.post("", status_code=status.HTTP_201_CREATED, dependencies=[admin_only])
def crear_usuario_acceso(datos: UserCreate, db: Session = Depends(get_db)):
    """Crea un usuario vinculado a una persona_id."""
    hash_p = get_password_hash(datos.password)
    sql = text("""
        INSERT INTO proparcon.users (id, persona_id, email, password_hash, role)
        VALUES (:id, :p_id, :email, :pass, :role) RETURNING id
    """)
    try:
        res = db.execute(sql, {
            "id": datos.id, "p_id": datos.persona_id, 
            "email": datos.email, "pass": hash_p, "role": datos.role.value
        }).first()
        db.commit()
        return {"id": res[0], "message": "Acceso creado"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=f"Error DDL Users: {str(e)}")

# --------------------------------------------------------------------
# SECCIÓN 4: ACTUALIZACIÓN DINÁMICA (PATCH)
# --------------------------------------------------------------------

@router.patch("/{user_id}", dependencies=[admin_only])
def actualizar_usuario(user_id: str, datos: UserUpdate, db: Session = Depends(get_db)):
    update_dict = datos.model_dump(exclude_unset=True)
    if not update_dict:
        raise HTTPException(400, "Sin cambios")
    
    set_clause = ", ".join([f"{k} = :{k}" for k in update_dict.keys()])
    sql = text(f"UPDATE proparcon.users SET {set_clause} WHERE id = :id RETURNING id")
    
    try:
        res = db.execute(sql, {**update_dict, "id": user_id}).first()
        db.commit()
        return {"id": res[0], "status": "updated"}
    except Exception as e:
        db.rollback()
        raise HTTPException(400, detail=str(e))

# --------------------------------------------------------------------
# SECCIÓN 5: ELIMINACIÓN FÍSICA (DELETE)
# --------------------------------------------------------------------

@router.delete("/{user_id}", dependencies=[admin_only])
def borrar_usuario_fisico(user_id: str, db: Session = Depends(get_db)):
    sql = text("DELETE FROM proparcon.users WHERE id = :id RETURNING id")
    try:
        res = db.execute(sql, {"id": user_id}).first()
        db.commit()
        return {"id": res[0] if res else None, "message": "Acceso eliminado"}
    except Exception as e:
        db.rollback()
        raise HTTPException(400, detail=str(e))