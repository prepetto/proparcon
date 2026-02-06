"""
====================================================================
ARCHIVO: app/api/propiedad.py
PROYECTO: PROPARCON API
DESCRIPCIÓN: Gestión de titularidades con vista jerárquica exacta.
====================================================================
ACTUALIZACIÓN REALIZADA:
    ✅ ALINEACIÓN DDL: Se usan los campos 'doc_identidad', 'nombre', 
       'apellido1' y 'apellido2' de la tabla proparcon.persona.
    ✅ CATÁLOGO: Se une con 'cat_tipo_derecho_propiedad' para mostrar
       la descripción del derecho (Pleno dominio, etc.).
    ✅ VISTA JERÁRQUICA: Consulta optimizada por nombre_publico para
       agrupamiento eficiente en el Frontend.
====================================================================
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from sqlalchemy.sql import text
from app.api.deps import get_db

router = APIRouter()

# --------------------------------------------------------------------
# SECCIÓN 1: MODELOS PYDANTIC
# --------------------------------------------------------------------

class PropiedadCreate(BaseModel):
    inmueble_id: int
    persona_id: int
    tipo_derecho_id: int
    porcentaje: float = Field(..., ge=0, le=100)

class PropiedadUpdate(BaseModel):
    persona_id: Optional[int] = None
    tipo_derecho_id: Optional[int] = None
    porcentaje: Optional[float] = Field(None, ge=0, le=100)

# --------------------------------------------------------------------
# SECCIÓN 2: CONSULTAS (GET)
# --------------------------------------------------------------------

@router.get("", response_model=List[dict])
def listar_propiedades_jerarquicas(db: Session = Depends(get_db)):
    """
    Obtiene el listado de propiedad con todos los campos DDL confirmados.
    Une Inmueble, Persona y Catálogo de Derecho.
    """
    sql = text("""
        SELECT 
            ip.id, 
            ip.inmueble_id, 
            ip.persona_id, 
            ip.porcentaje, 
            ip.tipo_derecho_id,
            i.nombre_publico as inmueble_nombre,
            (p.nombre || ' ' || p.apellido1 || COALESCE(' ' || p.apellido2, '')) as titular_nombre,
            p.doc_identidad as titular_doc,
            td.descripcion as derecho_desc
        FROM proparcon.inmueble_propiedad ip
        JOIN proparcon.inmueble i ON ip.inmueble_id = i.id
        JOIN proparcon.persona p ON ip.persona_id = p.id
        JOIN proparcon.cat_tipo_derecho_propiedad td ON ip.tipo_derecho_id = td.id
        ORDER BY i.nombre_publico ASC, ip.porcentaje DESC
    """)
    try:
        res = db.execute(sql).mappings().all()
        return [dict(r) for r in res]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error SQL: {str(e)}")

# --------------------------------------------------------------------
# SECCIÓN 3: ESCRITURA (POST / PATCH / DELETE)
# --------------------------------------------------------------------

@router.post("", status_code=status.HTTP_201_CREATED)
def crear_propiedad(datos: PropiedadCreate, db: Session = Depends(get_db)):
    try:
        sql = text("""
            INSERT INTO proparcon.inmueble_propiedad 
                (inmueble_id, persona_id, tipo_derecho_id, porcentaje) 
            VALUES (:i, :p, :t, :po) RETURNING id
        """)
        res = db.execute(sql, {
            "i": datos.inmueble_id, "p": datos.persona_id, 
            "t": datos.tipo_derecho_id, "po": datos.porcentaje
        }).first()
        db.commit()
        return {"id": res[0], "message": "Propiedad registrada"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@router.patch("/{propiedad_id}")
def actualizar_propiedad(propiedad_id: int, datos: PropiedadUpdate, db: Session = Depends(get_db)):
    update_data = datos.model_dump(exclude_unset=True)
    if not update_data:
        raise HTTPException(400, "Sin cambios")
    set_clause = ", ".join([f"{k} = :{k}" for k in update_data.keys()])
    sql = text(f"UPDATE proparcon.inmueble_propiedad SET {set_clause} WHERE id = :id RETURNING id")
    db.execute(sql, {**update_data, "id": propiedad_id})
    db.commit()
    return {"id": propiedad_id, "status": "updated"}

@router.delete("/{propiedad_id}")
def eliminar_propiedad(propiedad_id: int, db: Session = Depends(get_db)):
    db.execute(text("DELETE FROM proparcon.inmueble_propiedad WHERE id = :id"), {"id": propiedad_id})
    db.commit()
    return {"message": "Eliminado"}