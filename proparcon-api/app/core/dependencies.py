# app/core/dependencies.py
from __future__ import annotations

from typing import Generator, AsyncGenerator, List, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.sql import text

from app.core.db import (
    SessionLocal,
    AsyncSessionLocal,
    prepare_session_search_path,
    prepare_session_search_path_async,
)


def get_db() -> Generator[Session, None, None]:
    """
    Dependencia DB SYNC.
    Úsala en endpoints que usan db.query(...) o SQLAlchemy ORM sync.
    """
    db = SessionLocal()
    try:
        prepare_session_search_path(db)
        yield db
    finally:
        db.close()


async def get_async_db() -> AsyncGenerator[AsyncSession, None]:
    """
    Dependencia DB ASYNC.
    Úsala SOLO en endpoints async que usan await session.execute(...).
    """
    async with AsyncSessionLocal() as session:
        try:
            await prepare_session_search_path_async(session)
            yield session
        finally:
            await session.close()


def rows_to_dicts(result) -> List[Dict[str, Any]]:
    """Convierte Result de SQLAlchemy a lista de diccionarios."""
    return [dict(r._mapping) for r in result.fetchall()]


def fk_exists(db: Session, table: str, pk_id: int) -> bool:
    """
    Comprueba existencia FK en tabla (sync).
    table puede ser 'proparcon.persona' o 'persona' si search_path está bien.
    """
    row = db.execute(text(f"SELECT 1 FROM {table} WHERE id = :id"), {"id": pk_id}).first()
    return bool(row)
