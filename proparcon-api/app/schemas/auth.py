"""
Archivo: app/schemas/auth.py
Descripción: Modelos de Pydantic para el flujo de autenticación y tokens.
"""
from typing import Optional
from pydantic import BaseModel, EmailStr

class Token(BaseModel):
    """Respuesta estándar tras un login exitoso."""
    access_token: str
    token_type: str
    # Agregamos info básica del usuario para evitar decodificar el JWT en el Front
    user_email: EmailStr
    user_role: str

class TokenPayload(BaseModel):
    """Estructura interna del contenido del token JWT."""
    sub: Optional[str] = None # Generalmente el email
    role: Optional[str] = None
    user_id: Optional[int] = None

class LoginRequest(BaseModel):
    """Esquema para la petición de login (JSON body)."""
    email: EmailStr
    password: str

# Nueva versión: 28 líneas.}