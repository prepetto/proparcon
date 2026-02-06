# Imagen base
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Instala dependencias del sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
 && rm -rf /var/lib/apt/lists/*

# Directorio de trabajo
WORKDIR /app

# Copia los requisitos e instálalos
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copia la aplicación
COPY app ./app

# Añade /app al PYTHONPATH
ENV PYTHONPATH=/app

# Expone el puerto de la API
EXPOSE 8000

# Comando de arranque
CMD ["sh", "-lc", "uvicorn app.main:app --host 0.0.0.0 --port 8000 ${UVICORN_RELOAD:+--reload}"]

# Opcional: dependencias de desarrollo (tests)
COPY requirements-dev.txt ./requirements-dev.txt
RUN pip install --no-cache-dir -r requirements-dev.txt