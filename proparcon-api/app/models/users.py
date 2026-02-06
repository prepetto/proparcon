# app/models/users.py
from __future__ import annotations

from enum import Enum

from sqlalchemy import BigInteger, Boolean, String, text
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class UserRole(str, Enum):
    """
    Roles reales usados en el proyecto.
    Importante: deben existir los nombres que el código referencia:
    - ADMIN
    - GESTOR
    - LECTOR
    - USER (si lo sigues usando)
    """
    ADMIN = "admin"
    GESTOR = "gestor"
    LECTOR = "lector"
    USER = "user"


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    persona_id: Mapped[int] = mapped_column(BigInteger, nullable=False, unique=True)

    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)

    # OJO: en BD es password_hash
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)

    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, server_default=text("true"))

    # En BD es varchar(20) con default 'lector'
    role: Mapped[str] = mapped_column(String(20), nullable=False, server_default=text("'lector'"))
