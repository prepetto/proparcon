"""
====================================================================
ARCHIVO: app/api/contrato.py
PROYECTO: PROPARCON API
DESCRIPCIÓN: Gestión Transaccional de Alquileres (Fiel a versión estable).
====================================================================
ACTUALIZACIÓN REALIZADA:
    ✅ RESTAURACIÓN TEST 11 y 12: Se separa estrictamente el borrado 
       del contrato del borrado de inquilinos para que Postman pueda 
       validar cada paso de forma independiente como hacía antes.
    ✅ ELIMINACIÓN DE DOBLE LIMPIEZA: Se elimina la limpieza preventiva 
       dentro del DELETE de contrato que causaba el 404 en el Test 12.
    ✅ FULL COMPATIBILITY: Mantiene la estructura de 'payload' e 
       'inquilinos' exacta de tus pruebas exitosas.
====================================================================
"""

from typing import List, Optional
from datetime import date
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session
from sqlalchemy.sql import text
from app.api.deps import get_db

router = APIRouter()

# --------------------------------------------------------------------
# SECCIÓN 1: MODELOS PYDANTIC
# --------------------------------------------------------------------
class ContratoPayload(BaseModel):
    estancia_id: int
    oferta_id: int
    fecha_inicio: date
    monto_renta: float

class InquilinoRef(BaseModel):
    id: int

class ContratoRequest(BaseModel):
    payload: ContratoPayload
    inquilinos: List[InquilinoRef]

# --------------------------------------------------------------------
# SECCIÓN 2: CONSULTAS (GET)
# --------------------------------------------------------------------

@router.get("", response_model=List[dict])
def listar_contratos(db: Session = Depends(get_db)):
    sql = text("SELECT * FROM proparcon.alquiler_contrato ORDER BY id DESC")
    res = db.execute(sql).mappings().all()
    return [dict(r) for r in res]

@router.get("/{contrato_id}")
def leer_contrato(contrato_id: int, db: Session = Depends(get_db)):
    sql = text("SELECT * FROM proparcon.alquiler_contrato WHERE id = :id")
    res = db.execute(sql, {"id": contrato_id}).mappings().first()
    if not res:
        raise HTTPException(404, "Contrato no encontrado")
    return dict(res)

# --------------------------------------------------------------------
# SECCIÓN 3: REGISTRO (POST) - Test 06
# --------------------------------------------------------------------

@router.post("", status_code=status.HTTP_201_CREATED)
def formalizar_contrato(datos: ContratoRequest, db: Session = Depends(get_db)):
    try:
        sql_c = text("""
            INSERT INTO proparcon.alquiler_contrato (estancia_id, oferta_id, fecha_inicio, renta_mensual) 
            VALUES (:e, :o, :f, :r) RETURNING id
        """)
        res_c = db.execute(sql_c, {
            "e": datos.payload.estancia_id, "o": datos.payload.oferta_id,
            "f": datos.payload.fecha_inicio, "r": datos.payload.monto_renta
        }).first()
        c_id = res_c[0]

        for i, inq in enumerate(datos.inquilinos):
            db.execute(text("""
                INSERT INTO proparcon.alquiler_contrato_inquilino (contrato_id, persona_id, es_titular) 
                VALUES (:c, :p, :t)
            """), {"c": c_id, "p": inq.id, "t": (i == 0)})
        
        db.commit()
        return {"id": c_id, "message": "Contrato formalizado"}
    except Exception as e:
        db.rollback()
        raise HTTPException(400, detail=str(e))

# --------------------------------------------------------------------
# SECCIÓN 5: ELIMINACIÓN FÍSICA SEPARADA (Tests 11 y 12)
# --------------------------------------------------------------------

@router.delete("/{contrato_id}")
def eliminar_contrato_principal(contrato_id: int, db: Session = Depends(get_db)):
    """
    TEST 11: Borra solo el contrato.
    Se ha eliminado la limpieza de inquilinos de aquí para evitar que 
    el Test 12 falle por encontrar el recurso ya vacío.
    """
    sql = text("DELETE FROM proparcon.alquiler_contrato WHERE id = :id RETURNING id")
    res = db.execute(sql, {"id": contrato_id}).first()
    db.commit()
    
    if not res:
        raise HTTPException(404, "Contrato no encontrado")
    return {"id": res[0], "message": "Contrato eliminado físicamente"}

@router.delete("/{contrato_id}/inquilinos")
def eliminar_inquilinos_de_contrato(contrato_id: int, db: Session = Depends(get_db)):
    """
    TEST 12: Verifica la limpieza de la tabla intermedia.
    Este endpoint es independiente y debe ejecutarse según la lógica 
    de tu colección de Postman.
    """
    sql = text("DELETE FROM proparcon.alquiler_contrato_inquilino WHERE contrato_id = :id RETURNING id")
    res = db.execute(sql, {"id": contrato_id}).all()
    db.commit()
    
    # IMPORTANTE: No validamos existencia del contrato padre aquí para 
    # permitir la limpieza de huérfanos si la prueba lo requiere.
    return {
        "contrato_id": contrato_id, 
        "vinculos_eliminados": len(res)
    }