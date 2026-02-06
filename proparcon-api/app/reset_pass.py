# app/cli/reset_password.py
from app.core.security import get_password_hash
from app.core.db import SessionLocal
from app.models.users import User

def reset(email: str, new_password: str):
    db = SessionLocal()
    user = db.query(User).filter(User.email == email).first()
    if not user:
        raise Exception("Usuario no existe")

    user.password_hash = get_password_hash(new_password)
    db.commit()
    print("Password actualizado")

if __name__ == "__main__":
    reset("admin@proparcon.es", "Admin123!")
