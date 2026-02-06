"""
====================================================================
ARCHIVO: app/api/catalogos.py
PROYECTO: PROPARCON API
====================================================================
Propósito:
  CRUD homogéneo de catálogos (tablas CAT) para la capa web / admin.

Diseño:
  - Este router NO define prefix "/catalogos".
    El prefix se aplica en app/routers/api.py con include_router(..., prefix="/catalogos").

Seguridad:
  - Se usa whitelist (ALLOWED_CATALOGS) para impedir inyección SQL por nombre de tabla.
  - Tabla siempre viene de whitelist.
  - Valores (id, campos) van parametrizados.

Compatibilidad con Postman (CRUD completo):
  - Implementa:
      GET    /catalogos/{catalogo}         (list)
      GET    /catalogos/{catalogo}/{id}    (get by id)   <-- antes faltaba (causaba 405)
      POST   /catalogos/{catalogo}         (create)
      PATCH  /catalogos/{catalogo}/{id}    (partial update)
      DELETE /catalogos/{catalogo}/{id}    (delete)

Flexibilidad (para que Postman pueda cubrir TODO sin rehacerlo cada vez):
  - Permite campos extra en POST/PATCH (p.ej. pais_id en provincia),
    pero SOLO se insertan/actualizan si la columna existe en la tabla real.
  - Acepta "nombre" como alias de "descripcion" (común en UI / testers).

Notas:
  - Este router asume que los catálogos tienen al menos id + (codigo/descripcion) en la mayoría de casos.
    Si algún catálogo no tiene esas columnas, igualmente funcionará si Postman envía columnas que existan.
====================================================================
"""

from __future__ import annotations

from typing import Any, Dict, List, Optional, Tuple

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.api.deps import get_db

router = APIRouter(tags=["Catálogos"])

# --------------------------------------------------------------------
# CONFIG: Mapa de catálogos expuestos (whitelist)
# --------------------------------------------------------------------
# Clave pública (frontend/postman) -> tabla física en BD (schema.table)
ALLOWED_CATALOGS: dict[str, str] = {
    # Ya existentes:
    "estado_contrato": "proparcon.cat_estado_contrato",
    "estado_oferta": "proparcon.cat_estado_oferta_alquiler",
    "tipo_inmueble": "proparcon.cat_tipo_inmueble",
    "tipo_via": "proparcon.cat_tipo_via",

    # Los que tu Postman está probando y antes estaban comentados:
    "pais": "proparcon.cat_pais",
    "provincia": "proparcon.cat_provincia",
    "rol": "proparcon.cat_rol",
    "tipo_avaliador": "proparcon.cat_tipo_avaliador",
    "tipo_contrato": "proparcon.cat_tipo_contrato",
    "tipo_derecho_propiedad": "proparcon.cat_tipo_derecho_propiedad",
    "tipo_estancia": "proparcon.cat_tipo_estancia",
    "tipo_ingreso": "proparcon.cat_tipo_ingreso",
}


def _table_for(catalogo: str) -> str:
    """Resuelve nombre lógico de catálogo a tabla segura (whitelist)."""
    table = ALLOWED_CATALOGS.get(catalogo)
    if not table:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Catálogo no soportado: {catalogo}",
        )
    return table


def _split_schema_table(qualified: str) -> Tuple[str, str]:
    """
    qualified: "schema.table"
    """
    if "." not in qualified:
        raise HTTPException(status_code=500, detail=f"Tabla inválida: {qualified}")
    schema, table = qualified.split(".", 1)
    return schema, table


def _get_table_columns(db: Session, qualified: str) -> List[str]:
    """
    Devuelve lista de columnas reales para schema.table (incluye 'id').
    """
    schema, table = _split_schema_table(qualified)
    sql = text(
        """
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = :schema
          AND table_name = :table
        ORDER BY ordinal_position
        """
    )
    rows = db.execute(sql, {"schema": schema, "table": table}).scalars().all()
    if not rows:
        raise HTTPException(
            status_code=500,
            detail=f"No se pudieron obtener columnas de {qualified}. ¿Existe la tabla?",
        )
    return [str(c) for c in rows]


def _normalize_payload(payload: Dict[str, Any]) -> Dict[str, Any]:
    """
    Normaliza payload:
    - Si viene "nombre" y no viene "descripcion", lo mapeamos.
    - Limpieza básica de strings (strip) si aplica.
    """
    out = dict(payload)

    if "descripcion" not in out and "nombre" in out:
        out["descripcion"] = out.get("nombre")

    # Limpieza suave
    for k, v in list(out.items()):
        if isinstance(v, str):
            out[k] = v.strip()

    return out


# --------------------------------------------------------------------
# ESQUEMAS Pydantic (permitimos extras)
# --------------------------------------------------------------------
class CatalogoCreate(BaseModel):
    """
    Payload de creación.
    - codigo/descripcion son los “clásicos”
    - se permiten campos extra (por ejemplo pais_id)
    """
    codigo: Optional[str] = Field(None, min_length=1, max_length=40)
    descripcion: Optional[str] = Field(None, min_length=1)
    nombre: Optional[str] = Field(None, min_length=1)  # alias habitual

    class Config:
        extra = "allow"


class CatalogoUpdate(BaseModel):
    """
    Payload de actualización parcial.
    """
    codigo: Optional[str] = Field(None, min_length=1, max_length=40)
    descripcion: Optional[str] = Field(None, min_length=1)
    nombre: Optional[str] = Field(None, min_length=1)  # alias habitual

    class Config:
        extra = "allow"


class CatalogoItemOut(BaseModel):
    """
    Salida homogénea.
    Nota: si una tabla no tiene codigo/descripcion, la salida puede no aplicar.
    Para Postman/CRUD general, devolvemos id + lo que exista en select.
    """
    id: int
    codigo: Optional[str] = None
    descripcion: Optional[str] = None

    class Config:
        extra = "allow"


class CatalogoCreateOut(BaseModel):
    id: int
    message: str = "created"


class CatalogoMessage(BaseModel):
    message: str


# --------------------------------------------------------------------
# ENDPOINTS
# --------------------------------------------------------------------
@router.get("", response_model=List[str])
def listar_catalogos_soportados() -> List[str]:
    """Lista de catálogos soportados por este router (para UI/admin)."""
    return sorted(ALLOWED_CATALOGS.keys())


@router.get("/{catalogo}", response_model=List[CatalogoItemOut])
def listar_items(
    catalogo: str,
    db: Session = Depends(get_db),
) -> List[CatalogoItemOut]:
    """Lista items de un catálogo."""
    table = _table_for(catalogo)

    # Intentamos devolver id, codigo, descripcion si existen.
    cols = _get_table_columns(db, table)
    select_cols = [c for c in ["id", "codigo", "descripcion"] if c in cols]
    if not select_cols:
        # Si no existen esas columnas, devolvemos al menos id y el resto de columnas reales.
        select_cols = cols

    sql = text(f"SELECT {', '.join(select_cols)} FROM {table} ORDER BY id ASC")
    rows = db.execute(sql).mappings().all()
    return [CatalogoItemOut(**dict(r)) for r in rows]


@router.get("/{catalogo}/{item_id}", response_model=CatalogoItemOut)
def obtener_item(
    catalogo: str,
    item_id: int,
    db: Session = Depends(get_db),
) -> CatalogoItemOut:
    """Get by ID (antes faltaba y Postman daba 405)."""
    table = _table_for(catalogo)

    cols = _get_table_columns(db, table)
    select_cols = [c for c in ["id", "codigo", "descripcion"] if c in cols]
    if not select_cols:
        select_cols = cols

    sql = text(f"SELECT {', '.join(select_cols)} FROM {table} WHERE id = :id")
    row = db.execute(sql, {"id": item_id}).mappings().first()
    if not row:
        raise HTTPException(status_code=404, detail="Registro no encontrado")
    return CatalogoItemOut(**dict(row))


@router.post("/{catalogo}", response_model=CatalogoCreateOut, status_code=status.HTTP_201_CREATED)
def crear_item(
    catalogo: str,
    payload: CatalogoCreate,
    db: Session = Depends(get_db),
) -> CatalogoCreateOut:
    """Crea un item en el catálogo (insert dinámico según columnas reales)."""
    table = _table_for(catalogo)
    cols = _get_table_columns(db, table)

    data = _normalize_payload(payload.dict(exclude_none=True))

    # Solo insertamos columnas que existan en la tabla.
    insert_cols = [k for k in data.keys() if k in cols and k != "id"]

    # Si el catálogo clásico tiene codigo/descripcion, forzamos que exista algo razonable.
    if "codigo" in cols and "codigo" not in insert_cols:
        raise HTTPException(status_code=422, detail="Falta 'codigo' (obligatorio)")
    if "descripcion" in cols and "descripcion" not in insert_cols:
        raise HTTPException(status_code=422, detail="Falta 'descripcion' (obligatorio)")

    if not insert_cols:
        raise HTTPException(status_code=422, detail="No hay campos válidos para insertar")

    params = {k: data[k] for k in insert_cols}
    placeholders = ", ".join([f":{k}" for k in insert_cols])

    try:
        sql = text(
            f"""
            INSERT INTO {table} ({", ".join(insert_cols)})
            VALUES ({placeholders})
            RETURNING id
            """
        )
        new_id = db.execute(sql, params).scalar_one()
        db.commit()
        return CatalogoCreateOut(id=int(new_id))
    except Exception as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Error creando registro: {exc}",
        )


@router.patch("/{catalogo}/{item_id}", response_model=CatalogoMessage)
def actualizar_item(
    catalogo: str,
    item_id: int,
    payload: CatalogoUpdate,
    db: Session = Depends(get_db),
) -> CatalogoMessage:
    """Actualiza parcialmente un item del catálogo (update dinámico según columnas reales)."""
    table = _table_for(catalogo)
    cols = _get_table_columns(db, table)

    data = _normalize_payload(payload.dict(exclude_none=True))
    update_cols = [k for k in data.keys() if k in cols and k != "id"]

    if not update_cols:
        raise HTTPException(status_code=422, detail="No hay campos válidos para actualizar")

    fields = [f"{k} = :{k}" for k in update_cols]
    params: Dict[str, Any] = {"id": item_id, **{k: data[k] for k in update_cols}}

    try:
        sql = text(f"UPDATE {table} SET {', '.join(fields)} WHERE id = :id")
        res = db.execute(sql, params)
        db.commit()

        if res.rowcount == 0:
            raise HTTPException(status_code=404, detail="Registro no encontrado")

        return CatalogoMessage(message="updated")
    except HTTPException:
        db.rollback()
        raise
    except Exception as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Error actualizando registro: {exc}",
        )


@router.delete("/{catalogo}/{item_id}", response_model=CatalogoMessage)
def borrar_item(
    catalogo: str,
    item_id: int,
    db: Session = Depends(get_db),
) -> CatalogoMessage:
    """Borra un item del catálogo."""
    table = _table_for(catalogo)

    try:
        sql = text(f"DELETE FROM {table} WHERE id = :id")
        res = db.execute(sql, {"id": item_id})
        db.commit()

        if res.rowcount == 0:
            raise HTTPException(status_code=404, detail="Registro no encontrado")

        return CatalogoMessage(message="deleted")
    except HTTPException:
        db.rollback()
        raise
    except Exception as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Error borrando registro: {exc}",
        )
