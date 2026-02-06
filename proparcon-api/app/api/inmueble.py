"""
====================================================================
ARCHIVO: app/api/inmueble.py
PROYECTO: PROPARCON API
DESCRIPCIÓN: Gestión Integral de Activos Inmobiliarios y Catastro.
====================================================================
ACTUALIZACIÓN REALIZADA:
    ✅ ADICIÓN DE LISTADO GLOBAL: Se ha implementado el método GET raíz 
       (@router.get("")) para permitir que el Frontend cargue la tabla 
       y los selectores de inmuebles (Solución definitiva al Error 405).
    ✅ INTEGRACIÓN CATASTRAL: El listado y la consulta por ID incluyen 
       ahora un LEFT JOIN con la tabla 'catastro' para devolver la 
       referencia catastral vinculada.
    ✅ COMPATIBILIDAD POSTMAN: Se mantienen los endpoints existentes 
       para asegurar que tus pruebas actuales sigan siendo válidas.
====================================================================
"""

from typing import Optional, List
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from sqlalchemy.sql import text
from app.api.deps import get_db

router = APIRouter()

# --------------------------------------------------------------------
# SECCIÓN 1: MODELOS PYDANTIC (Validación de Esquemas)
# --------------------------------------------------------------------

class InmuebleCreate(BaseModel):
    """Esquema para la creación de un nuevo inmueble."""
    tipo_inmueble_id: int
    nombre_publico: str = Field(..., min_length=3)
    direccion_id: int
    referencia_catastral: Optional[str] = None

class InmuebleUpdate(BaseModel):
    """Esquema para la actualización parcial (PATCH) de un inmueble."""
    nombre_publico: Optional[str] = None
    tipo_inmueble_id: Optional[int] = None
    direccion_id: Optional[int] = None

# --------------------------------------------------------------------
# SECCIÓN 2: CONSULTAS (GET) - Lectura de Activos
# --------------------------------------------------------------------

@router.get("", response_model=List[dict])
def listar_inmuebles(db: Session = Depends(get_db)):
    """
    Lista todos los inmuebles registrados.
    Realiza un LEFT JOIN con catastro para mostrar la referencia si existe.
    """
    sql = text("""
        SELECT i.*, c.ref_catastral 
        FROM proparcon.inmueble i 
        LEFT JOIN proparcon.catastro c ON i.id = c.inmueble_id 
        ORDER BY i.id DESC
    """)
    res = db.execute(sql).mappings().all()
    return [dict(r) for r in res]

@router.get("/{inmueble_id}")
def obtener_inmueble(inmueble_id: int, db: Session = Depends(get_db)):
    """
    Obtiene los detalles de un inmueble específico por ID.
    """
    sql = text("""
        SELECT i.*, c.ref_catastral 
        FROM proparcon.inmueble i 
        LEFT JOIN proparcon.catastro c ON i.id = c.inmueble_id 
        WHERE i.id = :id
    """)
    res = db.execute(sql, {"id": inmueble_id}).mappings().first()
    if not res:
        raise HTTPException(status_code=404, detail="Inmueble no encontrado")
    return dict(res)

# --------------------------------------------------------------------
# SECCIÓN 3: ESCRITURA (POST) - Registro Transaccional
# --------------------------------------------------------------------

@router.post("", status_code=status.HTTP_201_CREATED)
def crear_inmueble_completo(datos: InmuebleCreate, db: Session = Depends(get_db)):
    """
    Crea un inmueble y su registro catastral asociado en una sola operación.
    """
    try:
        # 1. Registro del Inmueble
        sql_i = text("""
            INSERT INTO proparcon.inmueble (nombre_publico, direccion_id, tipo_inmueble_id) 
            VALUES (:n, :d, :t) RETURNING id
        """)
        res_i = db.execute(sql_i, {
            "n": datos.nombre_publico, 
            "d": datos.direccion_id, 
            "t": datos.tipo_inmueble_id
        }).first()
        nuevo_id = res_i[0]

        # 2. Registro del Catastro (si aplica)
        if datos.referencia_catastral:
            sql_c = text("""
                INSERT INTO proparcon.catastro (inmueble_id, ref_catastral) 
                VALUES (:id, :ref)
            """)
            db.execute(sql_c, {"id": nuevo_id, "ref": datos.referencia_catastral})
        
        db.commit()
        return {"id": nuevo_id, "message": "Inmueble y catastro registrados"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

# --------------------------------------------------------------------
# SECCIÓN 4: ACTUALIZACIÓN (PATCH) - Modificación Parcial
# --------------------------------------------------------------------

@router.patch("/{inmueble_id}")
def actualizar_inmueble(inmueble_id: int, datos: InmuebleUpdate, db: Session = Depends(get_db)):
    """
    Actualiza campos específicos del inmueble sin afectar al resto.
    """
    update_data = datos.model_dump(exclude_unset=True)
    if not update_data:
        raise HTTPException(status_code=400, detail="Nada que actualizar")
    
    set_clause = ", ".join([f"{k} = :{k}" for k in update_data.keys()])
    sql = text(f"UPDATE proparcon.inmueble SET {set_clause} WHERE id = :id RETURNING id")
    
    try:
        res = db.execute(sql, {**update_data, "id": inmueble_id}).first()
        if not res:
            raise HTTPException(404, "Inmueble no encontrado")
        db.commit()
        return {"id": res[0], "message": "Actualizado correctamente"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

# --------------------------------------------------------------------
# SECCIÓN 5: ELIMINACIÓN (DELETE) - Limpieza de Activos
# --------------------------------------------------------------------

@router.delete("/{inmueble_id}")
def eliminar_inmueble_total(inmueble_id: int, db: Session = Depends(get_db)):
    """
    Borrado en cascada (manual) de catastro e inmueble.
    """
    try:
        db.execute(text("DELETE FROM proparcon.catastro WHERE inmueble_id = :id"), {"id": inmueble_id})
        db.execute(text("DELETE FROM proparcon.inmueble WHERE id = :id"), {"id": inmueble_id})
        db.commit()
        return {"message": "Inmueble eliminado con éxito"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=f"Error al eliminar: {str(e)}")