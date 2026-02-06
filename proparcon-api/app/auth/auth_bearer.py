# app/auth/auth_bearer.py
from typing import List, Optional
from fastapi import Request, HTTPException, Depends 
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import jwt 

JWT_SECRET = "secret_key_proparcon_123" 
JWT_ALGORITHM = "HS256"

class JWTBearer(HTTPBearer):
    async def __call__(self, request: Request):
        credentials = await super(JWTBearer, self).__call__(request)
        if credentials:
            payload = jwt.decode(credentials.credentials, JWT_SECRET, algorithms=[JWT_ALGORITHM])
            if not payload:
                raise HTTPException(status_code=403, detail="Token inválido")
            return credentials.credentials
        raise HTTPException(status_code=403, detail="No autorizado")

class RoleChecker:
    def __init__(self, required_roles: List[str]):
        self.required_roles = required_roles
    def __call__(self, request: Request, token: str = Depends(JWTBearer())): 
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        user_roles = payload.get("roles", [])
        if "ADMIN" in user_roles or set(self.required_roles).intersection(set(user_roles)):
            return True
        raise HTTPException(status_code=403, detail="Permisos insuficientes")