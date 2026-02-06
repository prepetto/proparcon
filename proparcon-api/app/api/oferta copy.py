"""
====================================================================
ARCHIVO: app/api/oferta.py
PROYECTO: PROPARCON API
DESCRIPCIÓN: Gestión Comercial de Alquileres (Versión Full CRUD).
====================================================================
ACTUALIZACIÓN REALIZADA:
    ✅ EXPOSICIÓN TOTAL DE CAMPOS: El listado global ahora incluye:
       id, estancia_id, renta_mensual, fecha_alta, fecha_baja y estado_id.
    ✅ JOIN ENRIQUECIDO: Se une con 'estancia' e 'inmueble' para mostrar
       nombres legibles en el frontend en lugar de solo IDs.
    ✅ COMPATIBILIDAD POSTMAN: Se mantiene la estructura exacta de 
       'alquiler_oferta' para no romper los tests existentes.
====================================================================
"""

from typing import Optional, List
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field, ConfigDict
from sqlalchemy.orm import Session
from sqlalchemy.sql import text
from app.api.deps import get_db

router = APIRouter()

# --- MODELOS PYDANTIC ---
class OfertaCreate(BaseModel):
    estancia_id: int
    renta_mensual: float
    fecha_alta: str
    estado_id: int = 1

class OfertaUpdate(BaseModel):
    renta_mensual: Optional[float] = None
    estado_id: Optional[int] = None
    fecha_baja: Optional[str] = None

# --- CONSULTAS (GET) ---

@router.get("", response_model=List[dict])
def listar_ofertas_completas(db: Session = Depends(get_db)):
    """
    Obtiene todas las ofertas con todos sus campos y nombres asociados.
    Cruza datos con estancia e inmueble para el Frontend.
    """
    sql = text("""
        SELECT 
            o.*, 
            e.nombre as estancia_nombre,
            i.nombre_publico as inmueble_nombre
        FROM proparcon.alquiler_oferta o
        JOIN proparcon.estancia e ON o.estancia_id = e.id
        JOIN proparcon.inmueble i ON e.inmueble_id = i.id
        ORDER BY o.id DESC
    """)
    res = db.execute(sql).mappings().all()
    return [dict(r) for r in res]

@router.get("/{oferta_id}")
def obtener_oferta(oferta_id: int, db: Session = Depends(get_db)):
    sql = text("SELECT * FROM proparcon.alquiler_oferta WHERE id = :id")
    res = db.execute(sql, {"id": oferta_id}).mappings().first()
    if not res:
        raise HTTPException(status_code=404, detail="Oferta no encontrada")
    return dict(res)

# --- ESCRITURA (POST / PATCH / DELETE) ---

@router.post("", status_code=status.HTTP_201_CREATED)
def crear_oferta_alquiler(datos: OfertaCreate, db: Session = Depends(get_db)):
    sql = text("""
        INSERT INTO proparcon.alquiler_oferta (estancia_id, renta_mensual, fecha_alta, estado_id) 
        VALUES (:e_id, :renta, :fecha, :es_id) RETURNING id
    """)
    try:
        res = db.execute(sql, {
            "e_id": datos.estancia_id, "renta": datos.renta_mensual,
            "fecha": datos.fecha_alta, "es_id": datos.estado_id
        }).first()
        db.commit()
        return {"id": res[0], "message": "Oferta creada"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@router.patch("/{oferta_id}")
def actualizar_oferta(oferta_id: int, datos: OfertaUpdate, db: Session = Depends(get_db)):
    update_data = datos.model_dump(exclude_unset=True)
    if not update_data: raise HTTPException(400, "Sin datos")
    set_clause = ", ".join([f"{k} = :{k}" for k in update_data.keys()])
    sql = text(f"UPDATE proparcon.alquiler_oferta SET {set_clause} WHERE id = :id RETURNING id")
    res = db.execute(sql, {**update_data, "id": oferta_id}).first()
    db.commit()
    return {"id": res[0], "status": "updated"}

@router.delete("/{oferta_id}")
def eliminar_oferta(oferta_id: int, db: Session = Depends(get_db)):
    sql = text("DELETE FROM proparcon.alquiler_oferta WHERE id = :id RETURNING id")
    res = db.execute(sql, {"id": oferta_id}).first()
    db.commit()
    return {"id": res[0], "message": "Eliminada"}