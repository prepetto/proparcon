"""
====================================================================
SECURITY.PY: Criptografía y Gestión de Tokens
====================================================================
Cambios clave:
- Eliminada la restricción rígida de longitud (len == 60) en verify_password().
  Esa comprobación provoca falsos negativos cuando el hash no es exactamente
  60 caracteres (hashes migrados, variantes, otros esquemas, espacios, etc.).
- Se mantiene try/except para evitar crashes por hashes inválidos.
- Ajuste recomendado: tokenUrl debe coincidir con el endpoint real de login.
====================================================================
"""

import os
from datetime import datetime, timedelta, timezone
from typing import Union

from jose import jwt
from passlib.context import CryptContext
from fastapi.security import OAuth2PasswordBearer

# -----------------------------------------------------------------------------
# 1) CONFIGURACIÓN GLOBAL
# -----------------------------------------------------------------------------
SECRET_KEY = os.getenv("SECRET_KEY", "proparcon_secret_2025")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 1440  # 24h (OK para dev; en prod suele ser menor)

# Debe coincidir con tu endpoint real:
# En tu proyecto el login es POST /v1/auth/login
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/v1/auth/login")

# -----------------------------------------------------------------------------
# 2) HASHING
# -----------------------------------------------------------------------------
# Si tu BD tiene SOLO bcrypt, esto está bien.
# Si tienes mezcla (argon2, pbkdf2, etc.), añade esos esquemas aquí.
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Valida la contraseña contra el hash de la BD.

    Nota:
    - NO imponemos longitud fija del hash.
    - Passlib gestiona el formato; si es inválido, lanzará excepción y devolvemos False.
    """
    if not plain_password or not hashed_password:
        return False

    try:
        return pwd_context.verify(plain_password, hashed_password)
    except Exception:
        return False


def get_password_hash(password: str) -> str:
    """Genera hash seguro para nuevos registros."""
    return pwd_context.hash(password)

# -----------------------------------------------------------------------------
# 3) GENERACIÓN DE TOKENS
# -----------------------------------------------------------------------------
def create_access_token(data: dict, expires_delta: Union[timedelta, None] = None) -> str:
    """Genera JWT."""
    to_encode = data.copy()

    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)

    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
