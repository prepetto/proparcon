A continuación, presento la documentación integral del proyecto PROPARCON (Propiedad, Participación y Control). He estructurado la información en tres grandes bloques para asegurar una transferencia de conocimiento fluida a nuevos desarrolladores o interesados.

1. Documento de Arquitectura y Especificación Técnica
Objetivo: Permitir que un equipo de ingeniería asuma el desarrollo, despliegue y mantenimiento.

Stack Tecnológico
Backend: Python 3.10+ con FastAPI.

Base de Datos: PostgreSQL (Esquema proparcon).

ORM: SQLAlchemy (Uso de SQL nativo mediante text() para máximo control).

Servidor ASGI: Uvicorn.

Autenticación: JWT (JSON Web Tokens) con algoritmo HS256.

Estructura del Proyecto
Plaintext

app/
├── api/
│   ├── auth.py          # Gestión de Login y tokens
│   ├── inmueble.py      # CRUD Inmuebles y Catastro
│   ├── estancia.py      # CRUD Habitaciones/Estancias
│   ├── persona.py       # Registro de Inquilinos/Personas
│   ├── oferta.py        # Ofertas de alquiler
│   └── contrato.py      # Lógica compleja Contrato + Inquilinos (N:M)
├── core/
│   └── security.py      # Utilidades de JWT y hashing
├── db/
│   └── session.py       # Configuración de SQLAlchemy
└── main.py              # Punto de entrada y registro de rutas
Lógica Transaccional Crítica: Módulo Contrato
El módulo contrato.py es el núcleo operativo. Utiliza una transacción atómica para:

Insertar en alquiler_contrato.

Insertar múltiples registros en la tabla intermedia alquiler_contrato_inquilino.

Asignar el flag es_titular al primer inquilino de la lista.

2. Documento Funcional y Reglas de Negocio
Objetivo: Explicar qué hace la API y cómo se relacionan las entidades desde el punto de vista del usuario.

Flujo de Operación Estándar
Para formalizar un alquiler en el sistema, se debe seguir este flujo obligatorio:

Inmueble: Registro del activo físico con su Referencia Catastral.

Estancia: Definición de qué parte del inmueble se alquila (ej. Habitación 1).

Oferta: Publicación del precio y fecha de disponibilidad.

Persona: Registro de los datos personales del futuro inquilino.

Contrato: Unión de todos los anteriores. Un contrato requiere una oferta activa y al menos un inquilino.

Entidades y Relaciones
Contrato - Inquilino: Relación muchos a muchos (N:M). Un contrato puede tener varios inquilinos (ej. parejas o estudiantes compartiendo).

Oferta - Estancia: Relación 1:1. Cada oferta pertenece a una estancia específica.

3. Documento de Calidad y Pruebas (Ciclo Senior V4)
Objetivo: Garantizar que el sistema es estable y puede limpiarse completamente para integraciones continuas.

Estrategia de Pruebas
Se utiliza Postman como suite de pruebas automatizadas. El ciclo actual consta de 16 tests diseñados para verificar la persistencia y, sobre todo, la integridad referencial en el borrado.

El Ciclo de Vida del Dato (Life Cycle)
Tests 01-06 (Creación): Generación de la cadena de dependencias hasta el Contrato.

Tests 07-10 (Validación/Edición): Comprobación de que los datos son correctos y el método PATCH funciona.

Tests 11-16 (Desmontaje/Limpieza):

Orden Crítico: Se debe borrar el Contrato primero (Test 11).

Razón técnica: El contrato actúa como "ancla". Una vez eliminado, se liberan las restricciones de clave foránea (FK) sobre la Oferta y la Persona, permitiendo que estas se borren físicamente sin errores de base de datos.

Estado de Validación Actual
Autenticación: Operativa (Bearer Token).

Integridad de Datos: 100% (Verificada mediante ForeignKeyViolation tests).

Limpieza de DB: Garantizada mediante borrado secuencial inverso.

Nota para el nuevo equipo: El proyecto se encuentra en una fase donde la infraestructura base está blindada. Los próximos pasos deberían enfocarse en la Gestión de Recibos y la Pasarela de Pagos, utilizando la misma lógica transaccional implementada en el módulo de contratos para asegurar la consistencia financiera.