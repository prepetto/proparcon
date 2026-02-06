# app/api/v1/endpoints/auth.py
from __future__ import annotations

import logging
import os
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr
from sqlalchemy.orm import Session

from app.api.deps import get_db
from app.core.security import create_access_token, verify_password
from app.models.users import User

logger = logging.getLogger(__name__)
router = APIRouter()


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


def _bypass_enabled() -> bool:
    return os.getenv("ADMIN_BYPASS_ENABLED", "0").strip() == "1"


def _bypass_password() -> str:
    return os.getenv("ADMIN_BYPASS_PASSWORD", "admin").strip()


def _bypass_emails() -> set[str]:
    raw = os.getenv("ADMIN_BYPASS_EMAILS", "").strip()
    if not raw:
        return set()
    return {e.strip().lower() for e in raw.split(",") if e.strip()}


def _get_user_by_email(db: Session, email: str) -> Optional[User]:
    return db.query(User).filter(User.email == email).first()


@router.post("/login", tags=["auth"])
def login(login_data: LoginRequest, db: Session = Depends(get_db)):
    """
    Autentica un usuario y devuelve un JWT.
    - En DEV permite bypass si ADMIN_BYPASS_ENABLED=1.
    """
    email = login_data.email.lower().strip()

    # 1) BYPASS DEV
    if _bypass_enabled():
        allowed_emails = _bypass_emails()
        if allowed_emails and email in allowed_emails and login_data.password == _bypass_password():
            user = _get_user_by_email(db, email)
            if not user:
                raise HTTPException(status_code=404, detail="Usuario bypass no existe en BD")

            token_data = {"sub": user.email, "role": user.role}
            logger.warning("Login BYPASS usado para email=%s", email)
            return {"access_token": create_access_token(token_data), "token_type": "bearer"}

    # 2) Login real
    user = _get_user_by_email(db, email)
    if not user or not verify_password(login_data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciales incorrectas",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token_data = {"sub": user.email, "role": user.role}
    return {"access_token": create_access_token(token_data), "token_type": "bearer"}
