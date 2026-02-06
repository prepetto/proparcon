-- === CICLO 1 · Datos mínimos coherentes ===
SET search_path TO proparcon;

-- 1️⃣ Personas
INSERT INTO persona (id, nombre, apellidos, dni, telefono)
VALUES
 (1,'María','Pérez Gómez','12345678A','600111222'),
 (2,'Juan','López Martín','87654321B','600333444');

-- 2️⃣ Propiedad 50 / 50 del inmueble 1
INSERT INTO inmueble_propiedad (id, inmueble_id, persona_id, tipo_derecho_id, porcentaje)
VALUES
 (1,1,1,1,50),
 (2,1,2,1,50);

-- 3️⃣ Estancia principal del inmueble 1
INSERT INTO estancia (id, inmueble_id, tipo_estancia_id, nombre, superficie)
VALUES
 (1,1,1,'Vivienda principal',85);

-- 4️⃣ Oferta activa sobre esa estancia
INSERT INTO alquiler_oferta
 (id, estancia_id, estado_id, renta_mensual, gestor_persona_id, encargado_persona_id, fecha_alta)
VALUES
 (1,1,1,850.00,1,2,CURRENT_DATE);
