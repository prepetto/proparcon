"""
====================================================================
ARCHIVO: app/api/propiedad.py
PROYECTO: PROPARCON API
DESCRIPCIÓN: Gestión de titularidades (Persona Física - Inmueble).
====================================================================
ACTUALIZACIÓN REALIZADA:
    ✅ ALINEACIÓN DDL: Uso estricto de 'doc_identidad', 'nombre' y 
       'apellido1' según esquema confirmado.
    ✅ VISTA JERÁRQUICA: Consulta SQL optimizada para agrupar por 
       Inmueble, incluyendo la descripción del catálogo de derechos.
    ✅ CRUD COMPLETO: Sincronización de POST, GET, PATCH y DELETE.
====================================================================
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from sqlalchemy.sql import text
from app.api.deps import get_db

router = APIRouter()

# --- SECCIÓN 1: MODELOS PYDANTIC ---
class PropiedadCreate(BaseModel):
    inmueble_id: int
    persona_id: int
    tipo_derecho_id: int
    porcentaje: float = Field(..., ge=0, le=100)

class PropiedadUpdate(BaseModel):
    persona_id: Optional[int] = None
    tipo_derecho_id: Optional[int] = None
    porcentaje: Optional[float] = Field(None, ge=0, le=100)

# --- SECCIÓN 2: CONSULTAS (GET) ---
@router.get("", response_model=List[dict])
def listar_propiedades(db: Session = Depends(get_db)):
    """Lista titularidades para visualización jerárquica Inmueble -> Dueños."""
    sql = text("""
        SELECT 
            ip.id, ip.inmueble_id, ip.persona_id, ip.porcentaje, ip.tipo_derecho_id,
            i.nombre_publico as inmueble_nombre,
            (p.nombre || ' ' || p.apellido1) as titular_nombre,
            p.doc_identidad as titular_doc,
            td.descripcion as derecho_desc
        FROM proparcon.inmueble_propiedad ip
        JOIN proparcon.inmueble i ON ip.inmueble_id = i.id
        JOIN proparcon.persona p ON ip.persona_id = p.id
        JOIN proparcon.cat_tipo_derecho_propiedad td ON ip.tipo_derecho_id = td.id
        ORDER BY i.nombre_publico ASC, ip.porcentaje DESC
    """)
    res = db.execute(sql).mappings().all()
    return [dict(r) for r in res]

# --- SECCIÓN 3: ESCRITURA (POST / PATCH / DELETE) ---
@router.post("", status_code=status.HTTP_201_CREATED)
def crear_propiedad(datos: PropiedadCreate, db: Session = Depends(get_db)):
    sql = text("""
        INSERT INTO proparcon.inmueble_propiedad (inmueble_id, persona_id, tipo_derecho_id, porcentaje) 
        VALUES (:i, :p, :t, :po) RETURNING id
    """)
    res = db.execute(sql, {"i": datos.inmueble_id, "p": datos.persona_id, "t": datos.tipo_derecho_id, "po": datos.porcentaje}).first()
    db.commit()
    return {"id": res[0], "message": "Propiedad asignada"}

@router.patch("/{propiedad_id}")
def actualizar_propiedad(propiedad_id: int, datos: PropiedadUpdate, db: Session = Depends(get_db)):
    update_data = datos.model_dump(exclude_unset=True)
    if not update_data: raise HTTPException(400, "Sin cambios")
    set_clause = ", ".join([f"{k} = :{k}" for k in update_data.keys()])
    sql = text(f"UPDATE proparcon.inmueble_propiedad SET {set_clause} WHERE id = :id RETURNING id")
    db.execute(sql, {**update_data, "id": propiedad_id})
    db.commit()
    return {"id": propiedad_id, "status": "updated"}

@router.delete("/{propiedad_id}")
def eliminar_propiedad(propiedad_id: int, db: Session = Depends(get_db)):
    db.execute(text("DELETE FROM proparcon.inmueble_propiedad WHERE id = :id"), {"id": propiedad_id})
    db.commit()
    return {"message": "Registro eliminado"}