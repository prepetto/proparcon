from pydantic import BaseModel, EmailStr
from datetime import datetime

class UserResponse(BaseModel):
    id: int
    email: EmailStr
    is_active: bool
    persona_id: int
    fecha_creacion: datetime

    class Config:
        from_attributes = True