"""
====================================================================
ARCHIVO: app/api/persona.py
PROYECTO: PROPARCON API
====================================================================
ESTADO: ✅ Revisado y Actualizado
CAMBIOS:
    - Añadido endpoint GET (lista completa) para evitar Error 405.
    - Sincronización de rutas sin slash final.
    - Tipado de respuesta corregido.
====================================================================
"""
from typing import Optional, List
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field, EmailStr
from sqlalchemy.orm import Session
from sqlalchemy.sql import text
from app.api.deps import get_db

router = APIRouter()

# --- 1. MODELOS DE VALIDACIÓN (PYDANTIC) ---
class PersonaCreate(BaseModel):
    tipo_doc: str = "DNI"
    doc_identidad: str = Field(..., min_length=3)
    nombre: str
    apellido1: str
    apellido2: Optional[str] = None
    email: Optional[EmailStr] = None

class PersonaUpdate(BaseModel):
    nombre: Optional[str] = None
    email_particular: Optional[EmailStr] = None
    telefono_movil: Optional[str] = None

# --- 2. ENDPOINTS DE CONSULTA (GET) ---

@router.get("", response_model=List[dict])
def obtener_personas(db: Session = Depends(get_db)):
    """
    Obtiene el listado completo de personas.
    Esencial para la vista de tabla en el frontend.
    """
    sql = text("SELECT * FROM proparcon.persona ORDER BY id DESC")
    res = db.execute(sql).mappings().all()
    return [dict(r) for r in res]

@router.get("/{persona_id}")
def obtener_persona(persona_id: int, db: Session = Depends(get_db)):
    """
    Obtiene los detalles de una persona específica.
    """
    sql = text("SELECT * FROM proparcon.persona WHERE id = :id")
    res = db.execute(sql, {"id": persona_id}).mappings().first()
    if not res:
        raise HTTPException(status_code=404, detail="Persona no encontrada")
    return dict(res)

# --- 3. ENDPOINTS DE CREACIÓN (POST) ---

@router.post("", status_code=status.HTTP_201_CREATED)
def crear_persona(datos: PersonaCreate, db: Session = Depends(get_db)):
    """
    Crea un nuevo registro de persona.
    """
    sql = text("""
        INSERT INTO proparcon.persona (nombre, apellido1, tipo_doc, doc_identidad, email_particular) 
        VALUES (:n, :a, :t, :d, :e) RETURNING id
    """)
    res = db.execute(sql, {
        "n": datos.nombre, 
        "a": datos.apellido1, 
        "t": datos.tipo_doc, 
        "d": datos.doc_identidad, 
        "e": datos.email
    }).first()
    db.commit()
    return {"id": res[0], "message": "Persona creada exitosamente"}

# --- 4. ENDPOINTS DE ACTUALIZACIÓN (PATCH) ---

@router.patch("/{persona_id}")
def actualizar_persona(persona_id: int, datos: PersonaUpdate, db: Session = Depends(get_db)):
    """
    Actualización parcial de datos de una persona.
    """
    update_data = datos.model_dump(exclude_unset=True)
    if not update_data:
        raise HTTPException(status_code=400, detail="No se enviaron datos para actualizar")
        
    set_clause = ", ".join([f"{k} = :{k}" for k in update_data.keys()])
    sql = text(f"UPDATE proparcon.persona SET {set_clause} WHERE id = :id RETURNING id")
    
    res = db.execute(sql, {**update_data, "id": persona_id}).first()
    if not res:
        raise HTTPException(status_code=404, detail="No se encontró la persona para actualizar")
        
    db.commit()
    return {"id": res[0], "status": "updated"}

# --- 5. ENDPOINTS DE ELIMINACIÓN (DELETE) ---

@router.delete("/{persona_id}")
def eliminar_persona(persona_id: int, db: Session = Depends(get_db)):
    """
    Elimina un registro de persona.
    """
    sql = text("DELETE FROM proparcon.persona WHERE id = :id")
    db.execute(sql, {"id": persona_id})
    db.commit()
    return {"message": "Registro eliminado correctamente"}