# app/core/settings.py
from __future__ import annotations

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict
from urllib.parse import quote_plus


class Settings(BaseSettings):
    """
    Configuración central del proyecto (Pydantic Settings).

    Regla de oro:
    - Las variables reales viven en MAYÚSCULAS (POSTGRES_USER, etc.)
    - Exponemos también aliases en minúsculas (postgres_user, db_user, etc.)
      para compatibilidad con código legacy que las pide así.
    """

    # --- Postgres (Docker / local) ---
    POSTGRES_USER: str = "admin"
    POSTGRES_PASSWORD: str = "admin"
    POSTGRES_HOST: str = "postgres"
    POSTGRES_PORT: int = 5432
    POSTGRES_DB: str = "proparcon"
    POSTGRES_SCHEMA: str = "proparcon"

    # En tu repo ya lo estabas usando así: DB_SSL en .env -> USE_SSL en Settings
    USE_SSL: bool = Field(False, alias="DB_SSL")

    # Si algún día quieres permitir URL completa
    DATABASE_URL: str | None = None

    model_config = SettingsConfigDict(
        env_file=".env",
        env_ignore_empty=True,
        extra="ignore",
    )

    # ----------------------------
    # Compatibilidad (minúsculas)
    # ----------------------------
    @property
    def postgres_user(self) -> str:
        return self.POSTGRES_USER

    @property
    def postgres_password(self) -> str:
        return self.POSTGRES_PASSWORD

    @property
    def postgres_host(self) -> str:
        return self.POSTGRES_HOST

    @property
    def postgres_port(self) -> int:
        return self.POSTGRES_PORT

    @property
    def postgres_db(self) -> str:
        return self.POSTGRES_DB

    # Alias típicos que a veces aparecen en código viejo
    @property
    def DB_USER(self) -> str:
        return self.POSTGRES_USER

    @property
    def db_user(self) -> str:
        return self.POSTGRES_USER

    # ----------------------------
    # URLs SQLAlchemy
    # ----------------------------
    def _base_dsn(self) -> str:
        """
        Devuelve DSN base 'postgresql://...' sin driver explícito.
        Si DATABASE_URL está definida, la usa.
        """
        if self.DATABASE_URL:
            url = self.DATABASE_URL.strip()
            if url.startswith("postgres://"):
                url = url.replace("postgres://", "postgresql://", 1)
            return url

        user = quote_plus(self.POSTGRES_USER)
        pwd = quote_plus(self.POSTGRES_PASSWORD)
        host = self.POSTGRES_HOST
        port = self.POSTGRES_PORT
        db = self.POSTGRES_DB
        return f"postgresql://{user}:{pwd}@{host}:{port}/{db}"

    @property
    def sqlalchemy_sync_url(self) -> str:
        """
        URL SYNC para SQLAlchemy usando psycopg2.
        """
        url = self._base_dsn()
        if url.startswith("postgresql+psycopg2://"):
            return url
        if url.startswith("postgresql://"):
            return url.replace("postgresql://", "postgresql+psycopg2://", 1)
        return url

    @property
    def sqlalchemy_async_url(self) -> str:
        """
        URL ASYNC para SQLAlchemy usando asyncpg.
        """
        url = self._base_dsn()
        if url.startswith("postgresql+asyncpg://"):
            return url
        if url.startswith("postgresql://"):
            return url.replace("postgresql://", "postgresql+asyncpg://", 1)
        return url


settings = Settings()
