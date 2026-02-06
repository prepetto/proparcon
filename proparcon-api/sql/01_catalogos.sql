-- Esquema base (si hiciera falta recrearlo manualmente)
-- DROP SCHEMA IF EXISTS proparcon CASCADE;
-- CREATE SCHEMA proparcon AUTHORIZATION CURRENT_USER;

CREATE TABLE proparcon.cat_tipo_via (
  id  integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo varchar(20) UNIQUE NOT NULL,
  descripcion text NOT NULL
);

CREATE TABLE proparcon.cat_pais (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  iso2 char(2) UNIQUE NOT NULL,
  nombre text NOT NULL
);

CREATE TABLE proparcon.cat_provincia (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  pais_id integer NOT NULL REFERENCES proparcon.cat_pais(id),
  nombre text NOT NULL,
  UNIQUE (pais_id, nombre)
);

CREATE TABLE proparcon.cat_rol (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo varchar(40) UNIQUE NOT NULL,
  descripcion text NOT NULL
);

CREATE TABLE proparcon.cat_tipo_inmueble (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo varchar(40) UNIQUE NOT NULL,
  descripcion text NOT NULL
);

CREATE TABLE proparcon.cat_tipo_estancia (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo varchar(40) UNIQUE NOT NULL,
  descripcion text NOT NULL,
  alquilable boolean NOT NULL DEFAULT false,
  es_raiz boolean NOT NULL DEFAULT false
);

CREATE TABLE proparcon.cat_tipo_derecho_propiedad (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo varchar(40) UNIQUE NOT NULL,  -- USUFRUCTO, NUDA, PLENO
  descripcion text NOT NULL
);

CREATE TABLE proparcon.cat_estado_oferta_alquiler (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo varchar(40) UNIQUE NOT NULL,  -- VACIO, RESERVADO, EN_OBRA
  descripcion text NOT NULL
);

CREATE TABLE proparcon.cat_tipo_avaliador (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo varchar(40) UNIQUE NOT NULL,  -- PERSONA, SEGURO_IMPAGO, AVAL_BANCARIO
  descripcion text NOT NULL
);

CREATE TABLE proparcon.cat_tipo_ingreso (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo varchar(40) UNIQUE NOT NULL,  -- NOMINA, NOMINA_B, ...
  descripcion text NOT NULL
);
