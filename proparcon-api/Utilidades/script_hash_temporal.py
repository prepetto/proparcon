# script_hash_temporal.py

from passlib.context import CryptContext

# 1. Definición del Contexto de Hashing (Debe coincidir con su app/core/security.py)
# Utilizamos bcrypt, que es el algoritmo recomendado por defecto.
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password: str) -> str:
    """Genera el hash de una contraseña usando bcrypt."""
    return pwd_context.hash(password)

# 2. Contraseña a hashear (¡CAMBIE ESTO!)
contraseña_a_hashear = "admin" 

# 3. Generación del Hash
hashed_password = get_password_hash(contraseña_a_hashear)

print("-" * 50)
print(f"Contraseña de entrada: {contraseña_a_hashear}")
print(f"HASH GENERADO: {hashed_password}")
print("-" * 50)