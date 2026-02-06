"""
====================================================================
ARCHIVO: app/api/estancia.py
PROYECTO: PROPARCON API
DESCRIPCIÓN: Gestión de estancias (Inmueble -> Estancia).
====================================================================
ACTUALIZACIÓN REALIZADA:
    ✅ VISTA JERÁRQUICA: Consulta SQL optimizada para agrupar por 
       Inmueble, incluyendo la descripción del catálogo de tipos.
    ✅ ESTABILIDAD: Se mantienen los endpoints de CRUD necesarios
       para la integración con el Frontend.
====================================================================
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session
from sqlalchemy.sql import text
from app.api.deps import get_db

router = APIRouter()

# --------------------------------------------------------------------
# SECCIÓN 1: MODELOS PYDANTIC
# --------------------------------------------------------------------

class EstanciaCreate(BaseModel):
    inmueble_id: int
    tipo_estancia_id: int
    nombre: str

class EstanciaUpdate(BaseModel):
    tipo_estancia_id: Optional[int] = None
    nombre: Optional[str] = None

# --------------------------------------------------------------------
# SECCIÓN 2: CONSULTAS (GET)
# --------------------------------------------------------------------

@router.get("", response_model=List[dict])
def listar_estancias_agrupadas(db: Session = Depends(get_db)):
    """Obtiene estancias ordenadas por inmueble para la jerarquía web."""
    sql = text("""
        SELECT 
            e.id, e.inmueble_id, e.tipo_estancia_id, e.nombre,
            i.nombre_publico as inmueble_nombre,
            te.descripcion as tipo_estancia_desc
        FROM proparcon.estancia e
        JOIN proparcon.inmueble i ON e.inmueble_id = i.id
        LEFT JOIN proparcon.cat_tipo_estancia te ON e.tipo_estancia_id = te.id
        ORDER BY i.nombre_publico ASC, e.nombre ASC
    """)
    res = db.execute(sql).mappings().all()
    return [dict(r) for r in res]

@router.get("/tipos", response_model=List[dict])
def listar_tipos_estancia(db: Session = Depends(get_db)):
    sql = text("SELECT id, descripcion FROM proparcon.cat_tipo_estancia ORDER BY id")
    res = db.execute(sql).mappings().all()
    return [dict(r) for r in res]

# --------------------------------------------------------------------
# SECCIÓN 3: ESCRITURA (POST / PATCH / DELETE)
# --------------------------------------------------------------------

@router.post("", status_code=status.HTTP_201_CREATED)
def crear_estancia(datos: EstanciaCreate, db: Session = Depends(get_db)):
    sql = text("""
        INSERT INTO proparcon.estancia (inmueble_id, tipo_estancia_id, nombre) 
        VALUES (:i, :t, :n) RETURNING id
    """)
    res = db.execute(sql, {"i": datos.inmueble_id, "t": datos.tipo_estancia_id, "n": datos.nombre}).first()
    db.commit()
    return {"id": res[0], "message": "Estancia creada"}

@router.patch("/{estancia_id}")
def actualizar_estancia(estancia_id: int, datos: EstanciaUpdate, db: Session = Depends(get_db)):
    update_data = datos.model_dump(exclude_unset=True)
    if not update_data: raise HTTPException(400, "Sin cambios")
    set_clause = ", ".join([f"{k} = :{k}" for k in update_data.keys()])
    sql = text(f"UPDATE proparcon.estancia SET {set_clause} WHERE id = :id RETURNING id")
    db.execute(sql, {**update_data, "id": estancia_id})
    db.commit()
    return {"id": estancia_id, "status": "updated"}

@router.delete("/{estancia_id}")
def eliminar_estancia(estancia_id: int, db: Session = Depends(get_db)):
    db.execute(text("DELETE FROM proparcon.estancia WHERE id = :id"), {"id": estancia_id})
    db.commit()
    return {"message": "Borrado"}