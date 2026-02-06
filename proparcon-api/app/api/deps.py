# app/api/deps.py
from __future__ import annotations

from typing import Sequence, Union

from fastapi import Depends, HTTPException, status
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from app.core.security import ALGORITHM, SECRET_KEY, oauth2_scheme
from app.core.dependencies import get_db  # <- SYNC
from app.models.users import User, UserRole


def get_current_user(
    db: Session = Depends(get_db),
    token: str = Depends(oauth2_scheme),
) -> User:
    """
    JWT -> email (sub) -> lookup en BD (sync).
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="No se pudo validar el token de acceso",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str | None = payload.get("sub")
        if not email:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    user = db.query(User).filter(User.email == email).first()
    if user is None:
        raise credentials_exception

    return user


class RoleChecker:
    """
    RBAC simple.
    allowed_roles puede ser [UserRole.ADMIN, UserRole.GESTOR] o strings.
    """

    def __init__(self, allowed_roles: Sequence[Union[UserRole, str]]):
        self.allowed_roles = allowed_roles

    def __call__(self, current_user: User = Depends(get_current_user)) -> User:
        user_role = (
            current_user.role.value
            if hasattr(current_user.role, "value")
            else str(current_user.role)
        )

        allowed = [
            r.value if hasattr(r, "value") else str(r)
            for r in self.allowed_roles
        ]

        if user_role not in allowed:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Permiso denegado. Requiere: {allowed}. Tu rol: {user_role}",
            )

        return current_user
