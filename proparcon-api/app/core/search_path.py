from __future__ import annotations

from sqlalchemy import text

async def prepare_session_search_path(session, schema: str) -> None:
    """
    Fuerza el search_path de la sesión (AsyncSession).
    Evita dependencias cruzadas con app.core.db y rompe imports circulares.
    """
    if not schema:
        return
    # Nota: schema viene de settings (controlado), no de input usuario.
    await session.execute(text(f"SET search_path TO {schema}, public"))
