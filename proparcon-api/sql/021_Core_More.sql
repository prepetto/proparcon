-- DIRECCION
CREATE TABLE proparcon.direccion (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  tipo_via_id integer REFERENCES proparcon.cat_tipo_via(id),
  via_nombre text NOT NULL,
  numero varchar(10),
  escalera varchar(10),
  piso varchar(10),
  puerta varchar(10),
  cp varchar(10),
  municipio text,
  provincia_id integer REFERENCES proparcon.cat_provincia(id),
  pais_id integer REFERENCES proparcon.cat_pais(id),
  observaciones text
);

-- PERSONA / JURIDICA (sin dominios; checks in-line)
CREATE TABLE proparcon.persona (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  tipo_doc varchar(20) NOT NULL,
  doc_identidad text NOT NULL CHECK (length(doc_identidad) BETWEEN 3 AND 64),
  nombre text NOT NULL,
  apellido1 text NOT NULL,
  apellido2 text,
  fecha_nacimiento date,
  lugar_nacimiento text,
  nacionalidad text,
  profesion text,
  direccion_id bigint REFERENCES proparcon.direccion(id),
  telefono_fijo varchar(25),
  telefono_movil varchar(25),
  email_particular text,
  email_laboral text,
  nick text,
  linkedin text,
  iban text,
  UNIQUE (tipo_doc, doc_identidad)
);

CREATE TABLE proparcon.juridica (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  cif varchar(20) UNIQUE NOT NULL,
  denominacion_social text NOT NULL,
  abreviatura varchar(10),
  domicilio_fiscal_id bigint REFERENCES proparcon.direccion(id),
  acta_titularidad_real date
);

-- ORGANO ADMIN
CREATE TABLE proparcon.org_admin_tipo (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo varchar(40) UNIQUE NOT NULL,  -- ADM_UNICO, SOLIDARIOS, MANCOMUNADOS, CONSEJO
  descripcion text NOT NULL
);

CREATE TABLE proparcon.org_admin (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  juridica_id bigint NOT NULL REFERENCES proparcon.juridica(id) ON DELETE CASCADE,
  tipo_id integer NOT NULL REFERENCES proparcon.org_admin_tipo(id),
  fecha_escritura date
);

CREATE TABLE proparcon.org_admin_miembro (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  org_admin_id bigint NOT NULL REFERENCES proparcon.org_admin(id) ON DELETE CASCADE,
  persona_id bigint REFERENCES proparcon.persona(id),
  juridica_id bigint REFERENCES proparcon.juridica(id),
  representante_persona_id bigint REFERENCES proparcon.persona(id),
  CHECK (
    (persona_id IS NOT NULL AND juridica_id IS NULL)
    OR (persona_id IS NULL AND juridica_id IS NOT NULL)
  )
);

-- EMPLEO
CREATE TABLE proparcon.centro_trabajo (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  juridica_id bigint NOT NULL REFERENCES proparcon.juridica(id) ON DELETE CASCADE,
  direccion_id bigint NOT NULL REFERENCES proparcon.direccion(id)
);

CREATE TABLE proparcon.empleado (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  persona_id bigint NOT NULL REFERENCES proparcon.persona(id) ON DELETE CASCADE,
  juridica_id bigint NOT NULL REFERENCES proparcon.juridica(id) ON DELETE CASCADE,
  centro_trabajo_id bigint REFERENCES proparcon.centro_trabajo(id),
  UNIQUE (persona_id, juridica_id)
);

-- ROLES
CREATE TABLE proparcon.persona_rol (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  persona_id bigint NOT NULL REFERENCES proparcon.persona(id) ON DELETE CASCADE,
  rol_id integer NOT NULL REFERENCES proparcon.cat_rol(id),
  gestor_supervisor_id bigint REFERENCES proparcon.persona(id),
  fecha_alta date DEFAULT now(),
  fecha_baja date,
  UNIQUE (persona_id, rol_id)
);

-- INMUEBLE
CREATE TABLE proparcon.inmueble (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  tipo_inmueble_id integer NOT NULL REFERENCES proparcon.cat_tipo_inmueble(id),
  nombre_publico text,
  direccion_id bigint REFERENCES proparcon.direccion(id),
  gestor_persona_id bigint REFERENCES proparcon.persona(id),
  encargado_persona_id bigint REFERENCES proparcon.persona(id),
  gestoria_juridica_id bigint REFERENCES proparcon.juridica(id)
);

CREATE TABLE proparcon.estancia (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  inmueble_id bigint NOT NULL REFERENCES proparcon.inmueble(id) ON DELETE CASCADE,
  tipo_estancia_id integer NOT NULL REFERENCES proparcon.cat_tipo_estancia(id),
  nombre text,
  parent_estancia_id bigint REFERENCES proparcon.estancia(id),
  UNIQUE (inmueble_id, nombre)
);

-- REGISTRO & CATASTRO
CREATE TABLE proparcon.registro_propiedad (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  inmueble_id bigint NOT NULL UNIQUE REFERENCES proparcon.inmueble(id) ON DELETE CASCADE,
  localidad text NOT NULL,
  registro_numero text NOT NULL,
  seccion text,
  finca text NOT NULL,
  cru_idufir text UNIQUE,
  arp_fecha date,
  nota_simple_url text
);

CREATE TABLE proparcon.catastro (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  inmueble_id bigint NOT NULL UNIQUE REFERENCES proparcon.inmueble(id) ON DELETE CASCADE,
  ref_catastral varchar(20) UNIQUE NOT NULL,
  direccion_catastral_id bigint REFERENCES proparcon.direccion(id),
  uso text,
  anio_construccion int,
  coef_participacion numeric(5,2) CHECK (coef_participacion BETWEEN 0 AND 100),
  sup_construida numeric(10,2),
  sup_parcela numeric(10,2)
);

-- PROPIEDAD
CREATE TABLE proparcon.inmueble_propiedad (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  inmueble_id bigint NOT NULL REFERENCES proparcon.inmueble(id) ON DELETE CASCADE,
  persona_id bigint REFERENCES proparcon.persona(id),
  juridica_id bigint REFERENCES proparcon.juridica(id),
  tipo_derecho_id integer NOT NULL REFERENCES proparcon.cat_tipo_derecho_propiedad(id),
  porcentaje numeric(5,2) NOT NULL CHECK (porcentaje BETWEEN 0 AND 100),
  CHECK (
    (persona_id IS NOT NULL AND juridica_id IS NULL)
    OR (persona_id IS NULL AND juridica_id IS NOT NULL)
  )
);

-- ALQUILER
CREATE TABLE proparcon.alquiler_oferta (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  estancia_id bigint NOT NULL REFERENCES proparcon.estancia(id) ON DELETE CASCADE,
  estado_id integer NOT NULL REFERENCES proparcon.cat_estado_oferta_alquiler(id),
  renta_mensual numeric(12,2) NOT NULL CHECK (renta_mensual >= 0),
  gestor_persona_id bigint REFERENCES proparcon.persona(id),
  encargado_persona_id bigint REFERENCES proparcon.persona(id),
  fecha_alta date NOT NULL DEFAULT now(),
  fecha_baja date
);

CREATE TABLE proparcon.alquiler_contrato (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  estancia_id bigint NOT NULL REFERENCES proparcon.estancia(id) ON DELETE CASCADE,
  fecha_inicio date NOT NULL,
  fecha_fin date,
  contrato_pdf_url text,
  gestor_persona_id bigint REFERENCES proparcon.persona(id),
  encargado_persona_id bigint REFERENCES proparcon.persona(id),
  renta_mensual numeric(12,2) NOT NULL CHECK (renta_mensual >= 0),
  activo boolean NOT NULL DEFAULT true
);

CREATE TABLE proparcon.alquiler_contrato_inquilino (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  contrato_id bigint NOT NULL REFERENCES proparcon.alquiler_contrato(id) ON DELETE CASCADE,
  persona_id bigint REFERENCES proparcon.persona(id),
  juridica_id bigint REFERENCES proparcon.juridica(id),
  CHECK (
    (persona_id IS NOT NULL AND juridica_id IS NULL)
    OR (persona_id IS NULL AND juridica_id IS NOT NULL)
  )
);

-- AVAL
CREATE TABLE proparcon.entidad_bancaria (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre text NOT NULL,
  cod_banco_esp char(4),
  swift_bic varchar(11)
);

CREATE TABLE proparcon.alquiler_contrato_aval (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  contrato_id bigint NOT NULL REFERENCES proparcon.alquiler_contrato(id) ON DELETE CASCADE,
  tipo_avaliador_id integer NOT NULL REFERENCES proparcon.cat_tipo_avaliador(id),
  persona_id bigint REFERENCES proparcon.persona(id),
  juridica_id bigint REFERENCES proparcon.juridica(id),
  entidad_bancaria_id bigint REFERENCES proparcon.entidad_bancaria(id),
  importe_maximo numeric(12,2),
  plazo_meses int,
  detalles text,
  CHECK (
    (tipo_avaliador_id IS NOT NULL) AND
    (
      (persona_id IS NOT NULL AND juridica_id IS NULL)
      OR (persona_id IS NULL AND juridica_id IS NOT NULL)
      OR (entidad_bancaria_id IS NOT NULL)
    )
  )
);
