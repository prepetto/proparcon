"""
====================================================================
ARCHIVO: app/api/oferta.py
PROYECTO: PROPARCON API
DESCRIPCIÓN:
    Gestión Comercial (Inmueble -> Estancia -> Oferta).
====================================================================
ACTUALIZACIÓN:
    ✅ Añadido GET /{oferta_id} (necesario para CRUD completo y Postman)
    ✅ Mantiene compatibilidad total con endpoints existentes
====================================================================
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session
from sqlalchemy.sql import text

from app.api.deps import get_db

router = APIRouter()

# -------------------------------------------------------------------
# SECCIÓN 1: MODELOS PYDANTIC
# -------------------------------------------------------------------
class OfertaCreate(BaseModel):
    estancia_id: int
    renta_mensual: float
    fecha_alta: str
    estado_id: int = 1


class OfertaUpdate(BaseModel):
    renta_mensual: Optional[float] = None
    estado_id: Optional[int] = None
    fecha_baja: Optional[str] = None


# -------------------------------------------------------------------
# SECCIÓN 2: CONSULTAS (GET)
# -------------------------------------------------------------------
@router.get("", response_model=List[dict])
def listar_ofertas(db: Session = Depends(get_db)):
    """Obtiene ofertas unidas con estancia e inmueble para jerarquía."""
    sql = text("""
        SELECT 
            o.*,
            e.nombre AS estancia_nombre,
            i.nombre_publico AS inmueble_nombre,
            i.id AS inmueble_id
        FROM proparcon.alquiler_oferta o
        JOIN proparcon.estancia e ON o.estancia_id = e.id
        JOIN proparcon.inmueble i ON e.inmueble_id = i.id
        ORDER BY i.nombre_publico ASC, e.nombre ASC
    """)
    res = db.execute(sql).mappings().all()
    return [dict(r) for r in res]


@router.get("/{oferta_id}", response_model=dict)
def obtener_oferta(oferta_id: int, db: Session = Depends(get_db)):
    """Obtiene una oferta por ID (necesario para CRUD completo)."""
    sql = text("""
        SELECT 
            o.*,
            e.nombre AS estancia_nombre,
            i.nombre_publico AS inmueble_nombre,
            i.id AS inmueble_id
        FROM proparcon.alquiler_oferta o
        JOIN proparcon.estancia e ON o.estancia_id = e.id
        JOIN proparcon.inmueble i ON e.inmueble_id = i.id
        WHERE o.id = :id
    """)
    res = db.execute(sql, {"id": oferta_id}).mappings().first()

    if not res:
        raise HTTPException(status_code=404, detail="Oferta no encontrada")

    return dict(res)


# -------------------------------------------------------------------
# SECCIÓN 3: ESCRITURA (POST / PATCH / DELETE)
# -------------------------------------------------------------------
@router.post("", status_code=status.HTTP_201_CREATED)
def crear_oferta(datos: OfertaCreate, db: Session = Depends(get_db)):
    sql = text("""
        INSERT INTO proparcon.alquiler_oferta
            (estancia_id, renta_mensual, fecha_alta, estado_id)
        VALUES
            (:e, :r, :f, :s)
        RETURNING id
    """)
    res = db.execute(
        sql,
        {
            "e": datos.estancia_id,
            "r": datos.renta_mensual,
            "f": datos.fecha_alta,
            "s": datos.estado_id,
        },
    ).first()

    db.commit()
    return {"id": res[0], "message": "Oferta publicada"}


@router.patch("/{oferta_id}")
def actualizar_oferta(oferta_id: int, datos: OfertaUpdate, db: Session = Depends(get_db)):
    update_data = datos.model_dump(exclude_unset=True)
    if not update_data:
        raise HTTPException(status_code=400, detail="Sin cambios")

    set_clause = ", ".join([f"{k} = :{k}" for k in update_data.keys()])
    sql = text(f"""
        UPDATE proparcon.alquiler_oferta
        SET {set_clause}
        WHERE id = :id
        RETURNING id
    """)

    res = db.execute(sql, {**update_data, "id": oferta_id}).first()
    if not res:
        raise HTTPException(status_code=404, detail="Oferta no encontrada")

    db.commit()
    return {"id": oferta_id, "status": "updated"}


@router.delete("/{oferta_id}")
def eliminar_oferta(oferta_id: int, db: Session = Depends(get_db)):
    res = db.execute(
        text("DELETE FROM proparcon.alquiler_oferta WHERE id = :id RETURNING id"),
        {"id": oferta_id},
    ).first()

    if not res:
        raise HTTPException(status_code=404, detail="Oferta no encontrada")

    db.commit()
    return {"message": "Oferta eliminada"}
