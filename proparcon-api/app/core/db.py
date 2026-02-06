# app/core/db.py
from __future__ import annotations

from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, Session

from sqlalchemy.ext.asyncio import (
    create_async_engine,
    async_sessionmaker,
    AsyncSession,
)

from app.core.settings import settings


# =============================================================================
# SECCIÓN 1: ENGINE + SESSION (SYNC)
# =============================================================================
engine = create_engine(
    settings.sqlalchemy_sync_url,
    pool_pre_ping=True,
    future=True,
)

SessionLocal = sessionmaker(
    bind=engine,
    autocommit=False,
    autoflush=False,
    expire_on_commit=False,
)


def prepare_session_search_path(db: Session) -> None:
    """
    Aplica search_path para que puedas consultar sin prefijar esquema.

    En PROPARCON lo normal es:
      SET search_path TO proparcon, public
    """
    schema = (settings.POSTGRES_SCHEMA or "").strip()
    if not schema:
        return
    db.execute(text(f"SET search_path TO {schema}, public"))


# =============================================================================
# SECCIÓN 2: ENGINE + SESSION (ASYNC)
# =============================================================================
async_connect_args = {"ssl": "require"} if settings.USE_SSL else {}

async_engine = create_async_engine(
    settings.sqlalchemy_async_url,
    pool_pre_ping=True,
    future=True,
    connect_args=async_connect_args,
)

AsyncSessionLocal = async_sessionmaker(
    bind=async_engine,
    expire_on_commit=False,
)


async def prepare_session_search_path_async(db: AsyncSession) -> None:
    """
    Igual que prepare_session_search_path pero para AsyncSession.
    """
    schema = (settings.POSTGRES_SCHEMA or "").strip()
    if not schema:
        return
    await db.execute(text(f"SET search_path TO {schema}, public"))
