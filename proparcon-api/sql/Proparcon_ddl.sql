-- DROP SCHEMA proparcon;

CREATE SCHEMA proparcon AUTHORIZATION "admin";

-- DROP SEQUENCE proparcon.alquiler_contrato_aval_id_seq;

CREATE SEQUENCE proparcon.alquiler_contrato_aval_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.alquiler_contrato_aval_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.alquiler_contrato_aval_id_seq TO "admin";

-- DROP SEQUENCE proparcon.alquiler_contrato_id_seq;

CREATE SEQUENCE proparcon.alquiler_contrato_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.alquiler_contrato_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.alquiler_contrato_id_seq TO "admin";

-- DROP SEQUENCE proparcon.alquiler_contrato_inquilino_id_seq;

CREATE SEQUENCE proparcon.alquiler_contrato_inquilino_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.alquiler_contrato_inquilino_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.alquiler_contrato_inquilino_id_seq TO "admin";

-- DROP SEQUENCE proparcon.alquiler_oferta_id_seq;

CREATE SEQUENCE proparcon.alquiler_oferta_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.alquiler_oferta_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.alquiler_oferta_id_seq TO "admin";

-- DROP SEQUENCE proparcon.cat_estado_contrato_id_seq;

CREATE SEQUENCE proparcon.cat_estado_contrato_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.cat_estado_contrato_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.cat_estado_contrato_id_seq TO "admin";

-- DROP SEQUENCE proparcon.cat_estado_oferta_alquiler_id_seq;

CREATE SEQUENCE proparcon.cat_estado_oferta_alquiler_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.cat_estado_oferta_alquiler_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.cat_estado_oferta_alquiler_id_seq TO "admin";

-- DROP SEQUENCE proparcon.cat_pais_id_seq;

CREATE SEQUENCE proparcon.cat_pais_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.cat_pais_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.cat_pais_id_seq TO "admin";

-- DROP SEQUENCE proparcon.cat_provincia_id_seq;

CREATE SEQUENCE proparcon.cat_provincia_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.cat_provincia_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.cat_provincia_id_seq TO "admin";

-- DROP SEQUENCE proparcon.cat_rol_id_seq;

CREATE SEQUENCE proparcon.cat_rol_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.cat_rol_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.cat_rol_id_seq TO "admin";

-- DROP SEQUENCE proparcon.cat_tipo_avaliador_id_seq;

CREATE SEQUENCE proparcon.cat_tipo_avaliador_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.cat_tipo_avaliador_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.cat_tipo_avaliador_id_seq TO "admin";

-- DROP SEQUENCE proparcon.cat_tipo_contrato_id_seq;

CREATE SEQUENCE proparcon.cat_tipo_contrato_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.cat_tipo_contrato_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.cat_tipo_contrato_id_seq TO "admin";

-- DROP SEQUENCE proparcon.cat_tipo_derecho_propiedad_id_seq;

CREATE SEQUENCE proparcon.cat_tipo_derecho_propiedad_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.cat_tipo_derecho_propiedad_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.cat_tipo_derecho_propiedad_id_seq TO "admin";

-- DROP SEQUENCE proparcon.cat_tipo_estancia_id_seq;

CREATE SEQUENCE proparcon.cat_tipo_estancia_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.cat_tipo_estancia_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.cat_tipo_estancia_id_seq TO "admin";

-- DROP SEQUENCE proparcon.cat_tipo_ingreso_id_seq;

CREATE SEQUENCE proparcon.cat_tipo_ingreso_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.cat_tipo_ingreso_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.cat_tipo_ingreso_id_seq TO "admin";

-- DROP SEQUENCE proparcon.cat_tipo_inmueble_id_seq;

CREATE SEQUENCE proparcon.cat_tipo_inmueble_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.cat_tipo_inmueble_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.cat_tipo_inmueble_id_seq TO "admin";

-- DROP SEQUENCE proparcon.cat_tipo_via_id_seq;

CREATE SEQUENCE proparcon.cat_tipo_via_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.cat_tipo_via_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.cat_tipo_via_id_seq TO "admin";

-- DROP SEQUENCE proparcon.catastro_id_seq;

CREATE SEQUENCE proparcon.catastro_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.catastro_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.catastro_id_seq TO "admin";

-- DROP SEQUENCE proparcon.centro_trabajo_id_seq;

CREATE SEQUENCE proparcon.centro_trabajo_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.centro_trabajo_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.centro_trabajo_id_seq TO "admin";

-- DROP SEQUENCE proparcon.direccion_id_seq;

CREATE SEQUENCE proparcon.direccion_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.direccion_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.direccion_id_seq TO "admin";

-- DROP SEQUENCE proparcon.empleado_id_seq;

CREATE SEQUENCE proparcon.empleado_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.empleado_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.empleado_id_seq TO "admin";

-- DROP SEQUENCE proparcon.entidad_bancaria_id_seq;

CREATE SEQUENCE proparcon.entidad_bancaria_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.entidad_bancaria_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.entidad_bancaria_id_seq TO "admin";

-- DROP SEQUENCE proparcon.estancia_id_seq;

CREATE SEQUENCE proparcon.estancia_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.estancia_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.estancia_id_seq TO "admin";

-- DROP SEQUENCE proparcon.inmueble_id_seq;

CREATE SEQUENCE proparcon.inmueble_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.inmueble_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.inmueble_id_seq TO "admin";

-- DROP SEQUENCE proparcon.inmueble_propiedad_id_seq;

CREATE SEQUENCE proparcon.inmueble_propiedad_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.inmueble_propiedad_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.inmueble_propiedad_id_seq TO "admin";

-- DROP SEQUENCE proparcon.juridica_id_seq;

CREATE SEQUENCE proparcon.juridica_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.juridica_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.juridica_id_seq TO "admin";

-- DROP SEQUENCE proparcon.org_admin_id_seq;

CREATE SEQUENCE proparcon.org_admin_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.org_admin_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.org_admin_id_seq TO "admin";

-- DROP SEQUENCE proparcon.org_admin_miembro_id_seq;

CREATE SEQUENCE proparcon.org_admin_miembro_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.org_admin_miembro_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.org_admin_miembro_id_seq TO "admin";

-- DROP SEQUENCE proparcon.org_admin_tipo_id_seq;

CREATE SEQUENCE proparcon.org_admin_tipo_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.org_admin_tipo_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.org_admin_tipo_id_seq TO "admin";

-- DROP SEQUENCE proparcon.persona_id_seq;

CREATE SEQUENCE proparcon.persona_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.persona_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.persona_id_seq TO "admin";

-- DROP SEQUENCE proparcon.persona_rol_id_seq;

CREATE SEQUENCE proparcon.persona_rol_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.persona_rol_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.persona_rol_id_seq TO "admin";

-- DROP SEQUENCE proparcon.registro_propiedad_id_seq;

CREATE SEQUENCE proparcon.registro_propiedad_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.registro_propiedad_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.registro_propiedad_id_seq TO "admin";

-- DROP SEQUENCE proparcon.users_id_seq;

CREATE SEQUENCE proparcon.users_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE proparcon.users_id_seq OWNER TO "admin";
GRANT ALL ON SEQUENCE proparcon.users_id_seq TO "admin";
-- proparcon.alembic_version definition

-- Drop table

-- DROP TABLE proparcon.alembic_version;

CREATE TABLE proparcon.alembic_version ( version_num varchar(32) NOT NULL, CONSTRAINT alembic_version_pkc null);

-- Permissions

ALTER TABLE proparcon.alembic_version OWNER TO "admin";
GRANT ALL ON TABLE proparcon.alembic_version TO "admin";


-- proparcon.cat_estado_contrato definition

-- Drop table

-- DROP TABLE proparcon.cat_estado_contrato;

CREATE TABLE proparcon.cat_estado_contrato ( id int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL, codigo varchar(40) NOT NULL, descripcion text NOT NULL, CONSTRAINT cat_estado_contrato_codigo_key UNIQUE (codigo), CONSTRAINT cat_estado_contrato_pkey PRIMARY KEY (id));

-- Permissions

ALTER TABLE proparcon.cat_estado_contrato OWNER TO "admin";
GRANT ALL ON TABLE proparcon.cat_estado_contrato TO "admin";


-- proparcon.cat_estado_oferta_alquiler definition

-- Drop table

-- DROP TABLE proparcon.cat_estado_oferta_alquiler;

CREATE TABLE proparcon.cat_estado_oferta_alquiler ( id int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL, codigo varchar(40) NOT NULL, descripcion text NOT NULL, CONSTRAINT cat_estado_oferta_alquiler_codigo_key UNIQUE (codigo), CONSTRAINT cat_estado_oferta_alquiler_pkey PRIMARY KEY (id));

-- Permissions

ALTER TABLE proparcon.cat_estado_oferta_alquiler OWNER TO "admin";
GRANT ALL ON TABLE proparcon.cat_estado_oferta_alquiler TO "admin";


-- proparcon.cat_pais definition

-- Drop table

-- DROP TABLE proparcon.cat_pais;

CREATE TABLE proparcon.cat_pais ( id int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL, iso2 bpchar(2) NOT NULL, nombre text NOT NULL, CONSTRAINT cat_pais_iso2_key UNIQUE (iso2), CONSTRAINT cat_pais_pkey PRIMARY KEY (id));

-- Permissions

ALTER TABLE proparcon.cat_pais OWNER TO "admin";
GRANT ALL ON TABLE proparcon.cat_pais TO "admin";


-- proparcon.cat_rol definition

-- Drop table

-- DROP TABLE proparcon.cat_rol;

CREATE TABLE proparcon.cat_rol ( id int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL, codigo varchar(40) NOT NULL, descripcion text NOT NULL, CONSTRAINT cat_rol_codigo_key UNIQUE (codigo), CONSTRAINT cat_rol_pkey PRIMARY KEY (id));

-- Permissions

ALTER TABLE proparcon.cat_rol OWNER TO "admin";
GRANT ALL ON TABLE proparcon.cat_rol TO "admin";


-- proparcon.cat_tipo_avaliador definition

-- Drop table

-- DROP TABLE proparcon.cat_tipo_avaliador;

CREATE TABLE proparcon.cat_tipo_avaliador ( id int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL, codigo varchar(40) NOT NULL, descripcion text NOT NULL, CONSTRAINT cat_tipo_avaliador_codigo_key UNIQUE (codigo), CONSTRAINT cat_tipo_avaliador_pkey PRIMARY KEY (id));

-- Permissions

ALTER TABLE proparcon.cat_tipo_avaliador OWNER TO "admin";
GRANT ALL ON TABLE proparcon.cat_tipo_avaliador TO "admin";


-- proparcon.cat_tipo_contrato definition

-- Drop table

-- DROP TABLE proparcon.cat_tipo_contrato;

CREATE TABLE proparcon.cat_tipo_contrato ( id int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL, codigo varchar(40) NOT NULL, descripcion text NOT NULL, CONSTRAINT cat_tipo_contrato_codigo_key UNIQUE (codigo), CONSTRAINT cat_tipo_contrato_pkey PRIMARY KEY (id));

-- Permissions

ALTER TABLE proparcon.cat_tipo_contrato OWNER TO "admin";
GRANT ALL ON TABLE proparcon.cat_tipo_contrato TO "admin";


-- proparcon.cat_tipo_derecho_propiedad definition

-- Drop table

-- DROP TABLE proparcon.cat_tipo_derecho_propiedad;

CREATE TABLE proparcon.cat_tipo_derecho_propiedad ( id int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL, codigo varchar(40) NOT NULL, descripcion text NOT NULL, CONSTRAINT cat_tipo_derecho_propiedad_codigo_key UNIQUE (codigo), CONSTRAINT cat_tipo_derecho_propiedad_pkey PRIMARY KEY (id));

-- Permissions

ALTER TABLE proparcon.cat_tipo_derecho_propiedad OWNER TO "admin";
GRANT ALL ON TABLE proparcon.cat_tipo_derecho_propiedad TO "admin";


-- proparcon.cat_tipo_estancia definition

-- Drop table

-- DROP TABLE proparcon.cat_tipo_estancia;

CREATE TABLE proparcon.cat_tipo_estancia ( id int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL, codigo varchar(40) NOT NULL, descripcion text NOT NULL, alquilable bool DEFAULT false NOT NULL, es_raiz bool DEFAULT false NOT NULL, CONSTRAINT cat_tipo_estancia_codigo_key UNIQUE (codigo), CONSTRAINT cat_tipo_estancia_pkey PRIMARY KEY (id));

-- Permissions

ALTER TABLE proparcon.cat_tipo_estancia OWNER TO "admin";
GRANT ALL ON TABLE proparcon.cat_tipo_estancia TO "admin";


-- proparcon.cat_tipo_ingreso definition

-- Drop table

-- DROP TABLE proparcon.cat_tipo_ingreso;

CREATE TABLE proparcon.cat_tipo_ingreso ( id int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL, codigo varchar(40) NOT NULL, descripcion text NOT NULL, CONSTRAINT cat_tipo_ingreso_codigo_key UNIQUE (codigo), CONSTRAINT cat_tipo_ingreso_pkey PRIMARY KEY (id));

-- Permissions

ALTER TABLE proparcon.cat_tipo_ingreso OWNER TO "admin";
GRANT ALL ON TABLE proparcon.cat_tipo_ingreso TO "admin";


-- proparcon.cat_tipo_inmueble definition

-- Drop table

-- DROP TABLE proparcon.cat_tipo_inmueble;

CREATE TABLE proparcon.cat_tipo_inmueble ( id int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL, codigo varchar(40) NOT NULL, descripcion text NOT NULL, CONSTRAINT cat_tipo_inmueble_codigo_key UNIQUE (codigo), CONSTRAINT cat_tipo_inmueble_pkey PRIMARY KEY (id));

-- Permissions

ALTER TABLE proparcon.cat_tipo_inmueble OWNER TO "admin";
GRANT ALL ON TABLE proparcon.cat_tipo_inmueble TO "admin";


-- proparcon.cat_tipo_via definition

-- Drop table

-- DROP TABLE proparcon.cat_tipo_via;

CREATE TABLE proparcon.cat_tipo_via ( id int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL, codigo varchar(20) NOT NULL, descripcion text NOT NULL, CONSTRAINT cat_tipo_via_codigo_key UNIQUE (codigo), CONSTRAINT cat_tipo_via_pkey PRIMARY KEY (id));

-- Permissions

ALTER TABLE proparcon.cat_tipo_via OWNER TO "admin";
GRANT ALL ON TABLE proparcon.cat_tipo_via TO "admin";


-- proparcon.entidad_bancaria definition

-- Drop table

-- DROP TABLE proparcon.entidad_bancaria;

CREATE TABLE proparcon.entidad_bancaria ( id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL, nombre text NOT NULL, cod_banco_esp bpchar(4) NULL, swift_bic varchar(11) NULL, CONSTRAINT entidad_bancaria_pkey PRIMARY KEY (id));

-- Permissions

ALTER TABLE proparcon.entidad_bancaria OWNER TO "admin";
GRANT ALL ON TABLE proparcon.entidad_bancaria TO "admin";


-- proparcon.org_admin_tipo definition

-- Drop table

-- DROP TABLE proparcon.org_admin_tipo;

CREATE TABLE proparcon.org_admin_tipo ( id int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL, codigo varchar(40) NOT NULL, descripcion text NOT NULL, CONSTRAINT org_admin_tipo_codigo_key UNIQUE (codigo), CONSTRAINT org_admin_tipo_pkey PRIMARY KEY (id));

-- Permissions

ALTER TABLE proparcon.org_admin_tipo OWNER TO "admin";
GRANT ALL ON TABLE proparcon.org_admin_tipo TO "admin";


-- proparcon.cat_provincia definition

-- Drop table

-- DROP TABLE proparcon.cat_provincia;

CREATE TABLE proparcon.cat_provincia ( id int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL, pais_id int4 NOT NULL, nombre text NOT NULL, CONSTRAINT cat_provincia_pais_id_nombre_key UNIQUE (pais_id, nombre), CONSTRAINT cat_provincia_pkey PRIMARY KEY (id), CONSTRAINT cat_provincia_pais_id_fkey FOREIGN KEY (pais_id) REFERENCES proparcon.cat_pais(id));

-- Permissions

ALTER TABLE proparcon.cat_provincia OWNER TO "admin";
GRANT ALL ON TABLE proparcon.cat_provincia TO "admin";


-- proparcon.direccion definition

-- Drop table

-- DROP TABLE proparcon.direccion;

CREATE TABLE proparcon.direccion ( id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL, tipo_via_id int4 NULL, via_nombre text NOT NULL, numero varchar(10) NULL, escalera varchar(10) NULL, piso varchar(10) NULL, puerta varchar(10) NULL, cp varchar(10) NULL, municipio text NULL, provincia_id int4 NULL, pais_id int4 NULL, observaciones text NULL, CONSTRAINT direccion_pkey PRIMARY KEY (id), CONSTRAINT direccion_pais_id_fkey FOREIGN KEY (pais_id) REFERENCES proparcon.cat_pais(id), CONSTRAINT direccion_provincia_id_fkey FOREIGN KEY (provincia_id) REFERENCES proparcon.cat_provincia(id), CONSTRAINT direccion_tipo_via_id_fkey FOREIGN KEY (tipo_via_id) REFERENCES proparcon.cat_tipo_via(id));

-- Permissions

ALTER TABLE proparcon.direccion OWNER TO "admin";
GRANT ALL ON TABLE proparcon.direccion TO "admin";


-- proparcon.juridica definition

-- Drop table

-- DROP TABLE proparcon.juridica;

CREATE TABLE proparcon.juridica ( id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL, cif varchar(20) NOT NULL, denominacion_social text NOT NULL, abreviatura varchar(10) NULL, domicilio_fiscal_id int8 NULL, acta_titularidad_real date NULL, CONSTRAINT juridica_cif_key UNIQUE (cif), CONSTRAINT juridica_pkey PRIMARY KEY (id), CONSTRAINT juridica_domicilio_fiscal_id_fkey FOREIGN KEY (domicilio_fiscal_id) REFERENCES proparcon.direccion(id));

-- Permissions

ALTER TABLE proparcon.juridica OWNER TO "admin";
GRANT ALL ON TABLE proparcon.juridica TO "admin";


-- proparcon.org_admin definition

-- Drop table

-- DROP TABLE proparcon.org_admin;

CREATE TABLE proparcon.org_admin ( id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL, juridica_id int8 NOT NULL, tipo_id int4 NOT NULL, fecha_escritura date NULL, CONSTRAINT org_admin_pkey PRIMARY KEY (id), CONSTRAINT org_admin_juridica_id_fkey FOREIGN KEY (juridica_id) REFERENCES proparcon.juridica(id) ON DELETE CASCADE, CONSTRAINT org_admin_tipo_id_fkey FOREIGN KEY (tipo_id) REFERENCES proparcon.org_admin_tipo(id));

-- Permissions

ALTER TABLE proparcon.org_admin OWNER TO "admin";
GRANT ALL ON TABLE proparcon.org_admin TO "admin";


-- proparcon.persona definition

-- Drop table

-- DROP TABLE proparcon.persona;

CREATE TABLE proparcon.persona ( id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL, tipo_doc varchar(20) NOT NULL, doc_identidad text NOT NULL, nombre text NOT NULL, apellido1 text NOT NULL, apellido2 text NULL, fecha_nacimiento date NULL, lugar_nacimiento text NULL, nacionalidad text NULL, profesion text NULL, direccion_id int8 NULL, telefono_fijo varchar(25) NULL, telefono_movil varchar(25) NULL, email_particular text NULL, email_laboral text NULL, nick text NULL, linkedin text NULL, iban text NULL, CONSTRAINT persona_doc_identidad_check CHECK (((length(doc_identidad) >= 3) AND (length(doc_identidad) <= 64))), CONSTRAINT persona_pkey PRIMARY KEY (id), CONSTRAINT persona_tipo_doc_doc_identidad_key UNIQUE (tipo_doc, doc_identidad), CONSTRAINT persona_direccion_id_fkey FOREIGN KEY (direccion_id) REFERENCES proparcon.direccion(id));
CREATE INDEX proparcon_idx_persona_doc ON proparcon.persona USING btree (tipo_doc, doc_identidad);

-- Permissions

ALTER TABLE proparcon.persona OWNER TO "admin";
GRANT ALL ON TABLE proparcon.persona TO "admin";


-- proparcon.persona_rol definition

-- Drop table

-- DROP TABLE proparcon.persona_rol;

CREATE TABLE proparcon.persona_rol ( id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL, persona_id int8 NOT NULL, rol_id int4 NOT NULL, gestor_supervisor_id int8 NULL, fecha_alta date DEFAULT now() NULL, fecha_baja date NULL, CONSTRAINT persona_rol_persona_id_rol_id_key UNIQUE (persona_id, rol_id), CONSTRAINT persona_rol_pkey PRIMARY KEY (id), CONSTRAINT persona_rol_gestor_supervisor_id_fkey FOREIGN KEY (gestor_supervisor_id) REFERENCES proparcon.persona(id), CONSTRAINT persona_rol_persona_id_fkey FOREIGN KEY (persona_id) REFERENCES proparcon.persona(id) ON DELETE CASCADE, CONSTRAINT persona_rol_rol_id_fkey FOREIGN KEY (rol_id) REFERENCES proparcon.cat_rol(id));
CREATE INDEX proparcon_idx_persona_rol ON proparcon.persona_rol USING btree (persona_id, rol_id);

-- Permissions

ALTER TABLE proparcon.persona_rol OWNER TO "admin";
GRANT ALL ON TABLE proparcon.persona_rol TO "admin";


-- proparcon.users definition

-- Drop table

-- DROP TABLE proparcon.users;

CREATE TABLE proparcon.users ( id varchar(50) DEFAULT nextval('users_id_seq'::regclass) NOT NULL, persona_id int8 NOT NULL, email varchar(255) NOT NULL, password_hash varchar(255) NOT NULL, is_active bool DEFAULT true NOT NULL, fecha_creacion timestamp DEFAULT now() NULL, "role" varchar(20) DEFAULT 'lector'::character varying NOT NULL, CONSTRAINT users_email_key UNIQUE (email), CONSTRAINT users_persona_id_key UNIQUE (persona_id), CONSTRAINT users_pkey PRIMARY KEY (id), CONSTRAINT users_persona_id_fkey FOREIGN KEY (persona_id) REFERENCES proparcon.persona(id));

-- Permissions

ALTER TABLE proparcon.users OWNER TO "admin";
GRANT ALL ON TABLE proparcon.users TO "admin";


-- proparcon.centro_trabajo definition

-- Drop table

-- DROP TABLE proparcon.centro_trabajo;

CREATE TABLE proparcon.centro_trabajo ( id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL, juridica_id int8 NOT NULL, direccion_id int8 NOT NULL, CONSTRAINT centro_trabajo_pkey PRIMARY KEY (id), CONSTRAINT centro_trabajo_direccion_id_fkey FOREIGN KEY (direccion_id) REFERENCES proparcon.direccion(id), CONSTRAINT centro_trabajo_juridica_id_fkey FOREIGN KEY (juridica_id) REFERENCES proparcon.juridica(id) ON DELETE CASCADE);

-- Permissions

ALTER TABLE proparcon.centro_trabajo OWNER TO "admin";
GRANT ALL ON TABLE proparcon.centro_trabajo TO "admin";


-- proparcon.empleado definition

-- Drop table

-- DROP TABLE proparcon.empleado;

CREATE TABLE proparcon.empleado ( id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL, persona_id int8 NOT NULL, juridica_id int8 NOT NULL, centro_trabajo_id int8 NULL, CONSTRAINT empleado_persona_id_juridica_id_key UNIQUE (persona_id, juridica_id), CONSTRAINT empleado_pkey PRIMARY KEY (id), CONSTRAINT empleado_centro_trabajo_id_fkey FOREIGN KEY (centro_trabajo_id) REFERENCES proparcon.centro_trabajo(id), CONSTRAINT empleado_juridica_id_fkey FOREIGN KEY (juridica_id) REFERENCES proparcon.juridica(id) ON DELETE CASCADE, CONSTRAINT empleado_persona_id_fkey FOREIGN KEY (persona_id) REFERENCES proparcon.persona(id) ON DELETE CASCADE);

-- Permissions

ALTER TABLE proparcon.empleado OWNER TO "admin";
GRANT ALL ON TABLE proparcon.empleado TO "admin";


-- proparcon.inmueble definition

-- Drop table

-- DROP TABLE proparcon.inmueble;

CREATE TABLE proparcon.inmueble ( id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL, tipo_inmueble_id int4 NOT NULL, nombre_publico text NULL, direccion_id int8 NULL, gestor_persona_id int8 NULL, encargado_persona_id int8 NULL, gestoria_juridica_id int8 NULL, CONSTRAINT inmueble_pkey PRIMARY KEY (id), CONSTRAINT inmueble_direccion_id_fkey FOREIGN KEY (direccion_id) REFERENCES proparcon.direccion(id), CONSTRAINT inmueble_encargado_persona_id_fkey FOREIGN KEY (encargado_persona_id) REFERENCES proparcon.persona(id), CONSTRAINT inmueble_gestor_persona_id_fkey FOREIGN KEY (gestor_persona_id) REFERENCES proparcon.persona(id), CONSTRAINT inmueble_gestoria_juridica_id_fkey FOREIGN KEY (gestoria_juridica_id) REFERENCES proparcon.juridica(id), CONSTRAINT inmueble_tipo_inmueble_id_fkey FOREIGN KEY (tipo_inmueble_id) REFERENCES proparcon.cat_tipo_inmueble(id));
CREATE INDEX proparcon_idx_inmueble_gestor ON proparcon.inmueble USING btree (gestor_persona_id);

-- Permissions

ALTER TABLE proparcon.inmueble OWNER TO "admin";
GRANT ALL ON TABLE proparcon.inmueble TO "admin";


-- proparcon.inmueble_propiedad definition

-- Drop table

-- DROP TABLE proparcon.inmueble_propiedad;

CREATE TABLE proparcon.inmueble_propiedad ( id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL, inmueble_id int8 NOT NULL, persona_id int8 NULL, juridica_id int8 NULL, tipo_derecho_id int4 NOT NULL, porcentaje numeric(5, 2) NOT NULL, CONSTRAINT inmueble_propiedad_check CHECK ((((persona_id IS NOT NULL) AND (juridica_id IS NULL)) OR ((persona_id IS NULL) AND (juridica_id IS NOT NULL)))), CONSTRAINT inmueble_propiedad_pkey PRIMARY KEY (id), CONSTRAINT inmueble_propiedad_porcentaje_check CHECK (((porcentaje >= (0)::numeric) AND (porcentaje <= (100)::numeric))), CONSTRAINT inmueble_propiedad_inmueble_id_fkey FOREIGN KEY (inmueble_id) REFERENCES proparcon.inmueble(id) ON DELETE CASCADE, CONSTRAINT inmueble_propiedad_juridica_id_fkey FOREIGN KEY (juridica_id) REFERENCES proparcon.juridica(id), CONSTRAINT inmueble_propiedad_persona_id_fkey FOREIGN KEY (persona_id) REFERENCES proparcon.persona(id), CONSTRAINT inmueble_propiedad_tipo_derecho_id_fkey FOREIGN KEY (tipo_derecho_id) REFERENCES proparcon.cat_tipo_derecho_propiedad(id));
CREATE INDEX proparcon_idx_inm_prop_inmueble ON proparcon.inmueble_propiedad USING btree (inmueble_id);
CREATE INDEX proparcon_idx_inm_prop_tipo ON proparcon.inmueble_propiedad USING btree (tipo_derecho_id);

-- Table Triggers

create trigger trg_propiedades_100 after
insert
    or
delete
    or
update
    on
    proparcon.inmueble_propiedad for each statement execute function trg_check_propiedades_100();

-- Permissions

ALTER TABLE proparcon.inmueble_propiedad OWNER TO "admin";
GRANT ALL ON TABLE proparcon.inmueble_propiedad TO "admin";


-- proparcon.org_admin_miembro definition

-- Drop table

-- DROP TABLE proparcon.org_admin_miembro;

CREATE TABLE proparcon.org_admin_miembro ( id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL, org_admin_id int8 NOT NULL, persona_id int8 NULL, juridica_id int8 NULL, representante_persona_id int8 NULL, CONSTRAINT org_admin_miembro_check CHECK ((((persona_id IS NOT NULL) AND (juridica_id IS NULL)) OR ((persona_id IS NULL) AND (juridica_id IS NOT NULL)))), CONSTRAINT org_admin_miembro_pkey PRIMARY KEY (id), CONSTRAINT org_admin_miembro_juridica_id_fkey FOREIGN KEY (juridica_id) REFERENCES proparcon.juridica(id), CONSTRAINT org_admin_miembro_org_admin_id_fkey FOREIGN KEY (org_admin_id) REFERENCES proparcon.org_admin(id) ON DELETE CASCADE, CONSTRAINT org_admin_miembro_persona_id_fkey FOREIGN KEY (persona_id) REFERENCES proparcon.persona(id), CONSTRAINT org_admin_miembro_representante_persona_id_fkey FOREIGN KEY (representante_persona_id) REFERENCES proparcon.persona(id));

-- Permissions

ALTER TABLE proparcon.org_admin_miembro OWNER TO "admin";
GRANT ALL ON TABLE proparcon.org_admin_miembro TO "admin";


-- proparcon.registro_propiedad definition

-- Drop table

-- DROP TABLE proparcon.registro_propiedad;

CREATE TABLE proparcon.registro_propiedad ( id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL, inmueble_id int8 NOT NULL, localidad text NOT NULL, registro_numero text NOT NULL, seccion text NULL, finca text NOT NULL, cru_idufir text NULL, arp_fecha date NULL, nota_simple_url text NULL, CONSTRAINT registro_propiedad_cru_idufir_key UNIQUE (cru_idufir), CONSTRAINT registro_propiedad_inmueble_id_key UNIQUE (inmueble_id), CONSTRAINT registro_propiedad_pkey PRIMARY KEY (id), CONSTRAINT registro_propiedad_inmueble_id_fkey FOREIGN KEY (inmueble_id) REFERENCES proparcon.inmueble(id) ON DELETE CASCADE);

-- Permissions

ALTER TABLE proparcon.registro_propiedad OWNER TO "admin";
GRANT ALL ON TABLE proparcon.registro_propiedad TO "admin";


-- proparcon.catastro definition

-- Drop table

-- DROP TABLE proparcon.catastro;

CREATE TABLE proparcon.catastro ( id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL, inmueble_id int8 NOT NULL, ref_catastral varchar(20) NOT NULL, direccion_catastral_id int8 NULL, uso text NULL, anio_construccion int4 NULL, coef_participacion numeric(5, 2) NULL, sup_construida numeric(10, 2) NULL, sup_parcela numeric(10, 2) NULL, CONSTRAINT catastro_coef_participacion_check CHECK (((coef_participacion >= (0)::numeric) AND (coef_participacion <= (100)::numeric))), CONSTRAINT catastro_inmueble_id_key UNIQUE (inmueble_id), CONSTRAINT catastro_pkey PRIMARY KEY (id), CONSTRAINT catastro_ref_catastral_key UNIQUE (ref_catastral), CONSTRAINT catastro_direccion_catastral_id_fkey FOREIGN KEY (direccion_catastral_id) REFERENCES proparcon.direccion(id), CONSTRAINT catastro_inmueble_id_fkey FOREIGN KEY (inmueble_id) REFERENCES proparcon.inmueble(id) ON DELETE CASCADE);

-- Permissions

ALTER TABLE proparcon.catastro OWNER TO "admin";
GRANT ALL ON TABLE proparcon.catastro TO "admin";


-- proparcon.estancia definition

-- Drop table

-- DROP TABLE proparcon.estancia;

CREATE TABLE proparcon.estancia ( id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL, inmueble_id int8 NOT NULL, tipo_estancia_id int4 NOT NULL, nombre text NULL, parent_estancia_id int8 NULL, CONSTRAINT estancia_inmueble_id_nombre_key UNIQUE (inmueble_id, nombre), CONSTRAINT estancia_pkey PRIMARY KEY (id), CONSTRAINT estancia_inmueble_id_fkey FOREIGN KEY (inmueble_id) REFERENCES proparcon.inmueble(id) ON DELETE CASCADE, CONSTRAINT estancia_parent_estancia_id_fkey FOREIGN KEY (parent_estancia_id) REFERENCES proparcon.estancia(id), CONSTRAINT estancia_tipo_estancia_id_fkey FOREIGN KEY (tipo_estancia_id) REFERENCES proparcon.cat_tipo_estancia(id));
CREATE INDEX proparcon_idx_estancia_inmueble ON proparcon.estancia USING btree (inmueble_id);

-- Permissions

ALTER TABLE proparcon.estancia OWNER TO "admin";
GRANT ALL ON TABLE proparcon.estancia TO "admin";


-- proparcon.alquiler_oferta definition

-- Drop table

-- DROP TABLE proparcon.alquiler_oferta;

CREATE TABLE proparcon.alquiler_oferta ( id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL, estancia_id int8 NOT NULL, estado_id int4 NOT NULL, renta_mensual numeric(12, 2) NOT NULL, gestor_persona_id int8 NULL, encargado_persona_id int8 NULL, fecha_alta date DEFAULT now() NOT NULL, fecha_baja date NULL, CONSTRAINT alquiler_oferta_pkey PRIMARY KEY (id), CONSTRAINT alquiler_oferta_renta_mensual_check CHECK ((renta_mensual >= (0)::numeric)), CONSTRAINT alquiler_oferta_encargado_persona_id_fkey FOREIGN KEY (encargado_persona_id) REFERENCES proparcon.persona(id), CONSTRAINT alquiler_oferta_estado_id_fkey FOREIGN KEY (estado_id) REFERENCES proparcon.cat_estado_oferta_alquiler(id), CONSTRAINT alquiler_oferta_estancia_id_fkey FOREIGN KEY (estancia_id) REFERENCES proparcon.estancia(id) ON DELETE CASCADE, CONSTRAINT alquiler_oferta_gestor_persona_id_fkey FOREIGN KEY (gestor_persona_id) REFERENCES proparcon.persona(id));
CREATE INDEX proparcon_idx_alq_oferta_estancia ON proparcon.alquiler_oferta USING btree (estancia_id);

-- Permissions

ALTER TABLE proparcon.alquiler_oferta OWNER TO "admin";
GRANT ALL ON TABLE proparcon.alquiler_oferta TO "admin";


-- proparcon.alquiler_contrato definition

-- Drop table

-- DROP TABLE proparcon.alquiler_contrato;

CREATE TABLE proparcon.alquiler_contrato ( id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL, estancia_id int8 NOT NULL, fecha_inicio date NOT NULL, fecha_fin date NULL, contrato_pdf_url text NULL, gestor_persona_id int8 NULL, encargado_persona_id int8 NULL, renta_mensual numeric(12, 2) NOT NULL, estado_id int4 DEFAULT 1 NOT NULL, oferta_id int8 NULL, fianza numeric(12, 2) NULL, tipo_contrato_id int4 NULL, CONSTRAINT alquiler_contrato_fianza_check CHECK ((fianza >= (0)::numeric)), CONSTRAINT alquiler_contrato_pkey PRIMARY KEY (id), CONSTRAINT alquiler_contrato_renta_mensual_check CHECK ((renta_mensual >= (0)::numeric)), CONSTRAINT trg_assert_contrato_tiene_titular TRIGGER DEFERRABLE INITIALLY DEFERRED, CONSTRAINT alquiler_contrato_encargado_persona_id_fkey FOREIGN KEY (encargado_persona_id) REFERENCES proparcon.persona(id), CONSTRAINT alquiler_contrato_estado_id_fkey FOREIGN KEY (estado_id) REFERENCES proparcon.cat_estado_contrato(id), CONSTRAINT alquiler_contrato_estancia_id_fkey FOREIGN KEY (estancia_id) REFERENCES proparcon.estancia(id) ON DELETE CASCADE, CONSTRAINT alquiler_contrato_gestor_persona_id_fkey FOREIGN KEY (gestor_persona_id) REFERENCES proparcon.persona(id), CONSTRAINT alquiler_contrato_oferta_id_fkey FOREIGN KEY (oferta_id) REFERENCES proparcon.alquiler_oferta(id), CONSTRAINT alquiler_contrato_tipo_contrato_id_fkey FOREIGN KEY (tipo_contrato_id) REFERENCES proparcon.cat_tipo_contrato(id));
CREATE INDEX proparcon_idx_alq_contrato_estancia ON proparcon.alquiler_contrato USING btree (estancia_id);

-- Table Triggers

create constraint trigger trg_assert_contrato_tiene_titular after
update
    of estado_id on
    proparcon.alquiler_contrato deferrable initially deferred for each row execute function trg_assert_contrato_tiene_inquilino_titular();
create trigger trg_exclusion_alquiler_contrato_estancia before
insert
    or
update
    of estancia_id,
    estado_id on
    proparcon.alquiler_contrato for each row execute function trg_check_exclusion_alquiler_estancia();

-- Permissions

ALTER TABLE proparcon.alquiler_contrato OWNER TO "admin";
GRANT ALL ON TABLE proparcon.alquiler_contrato TO "admin";


-- proparcon.alquiler_contrato_aval definition

-- Drop table

-- DROP TABLE proparcon.alquiler_contrato_aval;

CREATE TABLE proparcon.alquiler_contrato_aval ( id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL, contrato_id int8 NOT NULL, tipo_avaliador_id int4 NOT NULL, persona_id int8 NULL, juridica_id int8 NULL, entidad_bancaria_id int8 NULL, importe_maximo numeric(12, 2) NULL, plazo_meses int4 NULL, detalles text NULL, CONSTRAINT alquiler_contrato_aval_check CHECK (((tipo_avaliador_id IS NOT NULL) AND (((persona_id IS NOT NULL) AND (juridica_id IS NULL)) OR ((persona_id IS NULL) AND (juridica_id IS NOT NULL)) OR (entidad_bancaria_id IS NOT NULL)))), CONSTRAINT alquiler_contrato_aval_pkey PRIMARY KEY (id), CONSTRAINT alquiler_contrato_aval_contrato_id_fkey FOREIGN KEY (contrato_id) REFERENCES proparcon.alquiler_contrato(id) ON DELETE CASCADE, CONSTRAINT alquiler_contrato_aval_entidad_bancaria_id_fkey FOREIGN KEY (entidad_bancaria_id) REFERENCES proparcon.entidad_bancaria(id), CONSTRAINT alquiler_contrato_aval_juridica_id_fkey FOREIGN KEY (juridica_id) REFERENCES proparcon.juridica(id), CONSTRAINT alquiler_contrato_aval_persona_id_fkey FOREIGN KEY (persona_id) REFERENCES proparcon.persona(id), CONSTRAINT alquiler_contrato_aval_tipo_avaliador_id_fkey FOREIGN KEY (tipo_avaliador_id) REFERENCES proparcon.cat_tipo_avaliador(id));

-- Permissions

ALTER TABLE proparcon.alquiler_contrato_aval OWNER TO "admin";
GRANT ALL ON TABLE proparcon.alquiler_contrato_aval TO "admin";


-- proparcon.alquiler_contrato_inquilino definition

-- Drop table

-- DROP TABLE proparcon.alquiler_contrato_inquilino;

CREATE TABLE proparcon.alquiler_contrato_inquilino ( id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL, contrato_id int8 NOT NULL, persona_id int8 NULL, juridica_id int8 NULL, es_titular bool DEFAULT false NOT NULL, CONSTRAINT alquiler_contrato_inquilino_check CHECK ((((persona_id IS NOT NULL) AND (juridica_id IS NULL)) OR ((persona_id IS NULL) AND (juridica_id IS NOT NULL)))), CONSTRAINT alquiler_contrato_inquilino_pkey PRIMARY KEY (id), CONSTRAINT uq_contrato_inquilino UNIQUE (contrato_id, persona_id) DEFERRABLE, CONSTRAINT alquiler_contrato_inquilino_contrato_id_fkey FOREIGN KEY (contrato_id) REFERENCES proparcon.alquiler_contrato(id) ON DELETE CASCADE, CONSTRAINT alquiler_contrato_inquilino_juridica_id_fkey FOREIGN KEY (juridica_id) REFERENCES proparcon.juridica(id), CONSTRAINT alquiler_contrato_inquilino_persona_id_fkey FOREIGN KEY (persona_id) REFERENCES proparcon.persona(id));

-- Permissions

ALTER TABLE proparcon.alquiler_contrato_inquilino OWNER TO "admin";
GRANT ALL ON TABLE proparcon.alquiler_contrato_inquilino TO "admin";



-- DROP FUNCTION proparcon.fn_inmueble_de_estancia(int8);

CREATE OR REPLACE FUNCTION proparcon.fn_inmueble_de_estancia(in_estancia_id bigint)
 RETURNS bigint
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
DECLARE v_inmueble_id bigint;
BEGIN
  SELECT e.inmueble_id INTO v_inmueble_id FROM proparcon.estancia e WHERE e.id = in_estancia_id;
  RETURN v_inmueble_id;
END; $function$
;

-- Permissions

ALTER FUNCTION proparcon.fn_inmueble_de_estancia(int8) OWNER TO "admin";
GRANT ALL ON FUNCTION proparcon.fn_inmueble_de_estancia(int8) TO "admin";

-- DROP PROCEDURE proparcon.sp_demo_final(date, date, numeric, date, date, numeric);

CREATE OR REPLACE PROCEDURE proparcon.sp_demo_final(IN p_oferta_inicio date DEFAULT '2025-11-01'::date, IN p_oferta_fin date DEFAULT NULL::date, IN p_oferta_renta numeric DEFAULT 850, IN p_contrato_inicio date DEFAULT '2025-12-01'::date, IN p_contrato_fin date DEFAULT NULL::date, IN p_contrato_renta numeric DEFAULT 900)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
  -- Objetos principales de la demo
  v_estancia    bigint;   -- estancia objetivo (id=6 si existe; si no, la primera)
  v_inmueble    bigint;   -- inmueble asociado a la estancia objetivo
  v_contrato    bigint;   -- contrato demo insertado/seleccionado
  v_persona     bigint;   -- persona demo a asociar como inquilino

  -- Mecanismos de asociación de inquilino
  v_col_inq     text;     -- columna directa (si existe)
  v_tbl_p1      regclass := to_regclass('proparcon.alquiler_contrato_inquilino');   -- (contrato_id, persona_id)
  v_tbl_p2      regclass := to_regclass('proparcon.alquiler_contrato_persona');     -- (contrato_id, persona_id, rol)

  -- Auxiliares
  v_count_est   int;
BEGIN
  -- ============================================================
  -- 1) Saneamiento de rangos incoherentes (no romper CHECKs)
  --    - Alinea fecha_baja < fecha_alta → fecha_baja = fecha_alta
  --    - Alinea fecha_fin < fecha_inicio → fecha_fin = fecha_inicio y activo = FALSE
  -- ============================================================
  UPDATE proparcon.alquiler_oferta
     SET fecha_baja = fecha_alta
   WHERE fecha_baja IS NOT NULL AND fecha_baja < fecha_alta;

  UPDATE proparcon.alquiler_contrato
     SET fecha_fin = fecha_inicio, activo = FALSE
   WHERE fecha_fin IS NOT NULL AND fecha_fin < fecha_inicio;

  -- ============================================================
  -- 2) Garantizar inmueble + estancia
  --    - Si no hay estancias, intenta crear inmueble por defecto y una estancia.
  --    - Si tu tabla inmueble tiene NOT NULLs obligatorios, lanza error claro.
  -- ============================================================
  SELECT COUNT(*) INTO v_count_est FROM proparcon.estancia;
  IF v_count_est = 0 THEN
    BEGIN
      INSERT INTO proparcon.inmueble DEFAULT VALUES RETURNING id INTO v_inmueble;
    EXCEPTION
      WHEN not_null_violation THEN
        RAISE EXCEPTION 'sp_demo_final: no se pudo crear un inmueble con DEFAULT VALUES (NOT NULL requerido). Crea manualmente un inmueble con sus campos obligatorios y vuelve a ejecutar.';
      WHEN OTHERS THEN
        RAISE EXCEPTION 'sp_demo_final: error creando inmueble por defecto (%). Crea uno manualmente y reintenta.', SQLERRM;
    END;

    BEGIN
      INSERT INTO proparcon.estancia (inmueble_id) VALUES (v_inmueble);
    EXCEPTION
      WHEN not_null_violation THEN
        RAISE EXCEPTION 'sp_demo_final: no se pudo crear estancia por defecto (NOT NULL en estancia). Indica columnas requeridas.';
      WHEN OTHERS THEN
        RAISE EXCEPTION 'sp_demo_final: error creando estancia por defecto (%).', SQLERRM;
    END;
  END IF;

  -- ============================================================
  -- 3) Estancia objetivo: id=6 si existe; si no, la primera
  -- ============================================================
  SELECT COALESCE((SELECT 6 WHERE EXISTS (SELECT 1 FROM proparcon.estancia WHERE id=6)),
                  (SELECT MIN(id) FROM proparcon.estancia))
  INTO v_estancia;

  -- Inmueble de la estancia objetivo
  SELECT inmueble_id INTO v_inmueble
  FROM proparcon.estancia
  WHERE id = v_estancia;

  -- ============================================================
  -- 4) Cerrar activos HOY a nivel de inmueble (seguro para CHECKs)
  --    - Ofertas: fecha_baja = COALESCE(fecha_baja, ayer) si siguen activas hoy
  --    - Contratos: fecha_fin = COALESCE(fecha_fin, ayer), activo = FALSE si siguen activos hoy
  -- ============================================================
  UPDATE proparcon.alquiler_oferta o
     SET fecha_baja = COALESCE(o.fecha_baja, CURRENT_DATE - 1)
   WHERE o.estancia_id IN (SELECT id FROM proparcon.estancia WHERE inmueble_id = v_inmueble)
     AND COALESCE(o.fecha_baja, DATE '9999-12-31') >= CURRENT_DATE;

  UPDATE proparcon.alquiler_contrato c
     SET fecha_fin = COALESCE(c.fecha_fin, CURRENT_DATE - 1),
         activo    = FALSE
   WHERE c.estancia_id IN (SELECT id FROM proparcon.estancia WHERE inmueble_id = v_inmueble)
     AND COALESCE(c.fecha_fin, DATE '9999-12-31') >= CURRENT_DATE;

  -- ============================================================
  -- 5) Insertar OFERTA demo (idempotente por solape de rangos)
  -- ============================================================
  INSERT INTO proparcon.alquiler_oferta (estancia_id, fecha_alta, fecha_baja, renta_mensual)
  SELECT v_estancia, p_oferta_inicio, p_oferta_fin, p_oferta_renta
  WHERE NOT EXISTS (
    SELECT 1
    FROM proparcon.alquiler_oferta o
    WHERE o.estancia_id = v_estancia
      AND daterange(o.fecha_alta, COALESCE(o.fecha_baja, DATE '9999-12-31'), '[]')
          && daterange(p_oferta_inicio, COALESCE(p_oferta_fin, DATE '9999-12-31'), '[]')
  );

  -- ============================================================
  -- 6) Insertar CONTRATO demo (idempotente) como INACTIVO
  --    - Luego se asocia inquilino y se activa
  -- ============================================================
  INSERT INTO proparcon.alquiler_contrato (estancia_id, fecha_inicio, fecha_fin, renta_mensual, activo)
  SELECT v_estancia, p_contrato_inicio, p_contrato_fin, p_contrato_renta, FALSE
  WHERE NOT EXISTS (
    SELECT 1
    FROM proparcon.alquiler_contrato c
    WHERE c.estancia_id = v_estancia
      AND daterange(c.fecha_inicio, COALESCE(c.fecha_fin, DATE '9999-12-31'), '[]')
          && daterange(p_contrato_inicio, COALESCE(p_contrato_fin, DATE '9999-12-31'), '[]')
  );

  -- Localizar el contrato de demo
  SELECT id INTO v_contrato
  FROM proparcon.alquiler_contrato
  WHERE estancia_id = v_estancia
    AND fecha_inicio = p_contrato_inicio
  ORDER BY id DESC
  LIMIT 1;

  IF v_contrato IS NULL THEN
    RAISE EXCEPTION 'sp_demo_final: no se encontró el contrato de demo (estancia %, inicio %).', v_estancia, p_contrato_inicio;
  END IF;

  -- ============================================================
  -- 7) Persona demo (o la primera existente)
  --    - Si tu tabla persona tiene NOT NULLs, puedes adaptar aquí valores por defecto
  -- ============================================================
  SELECT id INTO v_persona
  FROM proparcon.persona
  ORDER BY id
  LIMIT 1;

  IF v_persona IS NULL THEN
    BEGIN
      INSERT INTO proparcon.persona DEFAULT VALUES RETURNING id INTO v_persona;
    EXCEPTION
      WHEN not_null_violation THEN
        RAISE EXCEPTION 'sp_demo_final: no se pudo crear persona demo con DEFAULT VALUES (NOT NULL). Indica columnas requeridas y reintenta.';
      WHEN OTHERS THEN
        RAISE EXCEPTION 'sp_demo_final: error creando persona demo (%).', SQLERRM;
    END;
  END IF;

  -- ============================================================
  -- 8) Asociar INQUILINO al contrato
  --    - Prioridad: tabla puente v1 → tabla puente v2 → columna directa
  -- ============================================================
  SELECT CASE
           WHEN EXISTS (SELECT 1 FROM information_schema.columns
                        WHERE table_schema='proparcon'
                          AND table_name='alquiler_contrato'
                          AND column_name='inquilino_persona_id')    THEN 'inquilino_persona_id'
           WHEN EXISTS (SELECT 1 FROM information_schema.columns
                        WHERE table_schema='proparcon'
                          AND table_name='alquiler_contrato'
                          AND column_name='arrendatario_persona_id') THEN 'arrendatario_persona_id'
           ELSE NULL
         END
  INTO v_col_inq;

  IF v_tbl_p1 IS NOT NULL THEN
    INSERT INTO proparcon.alquiler_contrato_inquilino (contrato_id, persona_id)
    SELECT v_contrato, v_persona
    WHERE NOT EXISTS (
      SELECT 1
      FROM proparcon.alquiler_contrato_inquilino
      WHERE contrato_id = v_contrato
        AND persona_id  = v_persona
    );

  ELSIF v_tbl_p2 IS NOT NULL THEN
    INSERT INTO proparcon.alquiler_contrato_persona (contrato_id, persona_id, rol)
    SELECT v_contrato, v_persona, 'inquilino'
    WHERE NOT EXISTS (
      SELECT 1
      FROM proparcon.alquiler_contrato_persona
      WHERE contrato_id = v_contrato
        AND persona_id  = v_persona
        AND (rol = 'inquilino' OR rol IS NULL)
    );

  ELSIF v_col_inq IS NOT NULL THEN
    EXECUTE format('UPDATE proparcon.alquiler_contrato SET %I = $1 WHERE id = $2', v_col_inq)
    USING v_persona, v_contrato;

  ELSE
    -- Si no hay forma de asociar inquilino, no activamos para no violar triggers
    RAISE NOTICE 'sp_demo_final: no hay tabla puente ni columna directa para inquilinos; el contrato quedará INACTIVO.';
    RETURN;
  END IF;

  -- ============================================================
  -- 9) Activar contrato (ya con ≥1 inquilino asociado)
  -- ============================================================
  UPDATE proparcon.alquiler_contrato
     SET activo = TRUE
   WHERE id = v_contrato;

  RAISE NOTICE 'DEMO FINAL OK · Estancia % · Contrato % · Inquilino %',
               v_estancia, v_contrato, v_persona;
END;
$procedure$
;

-- Permissions

ALTER PROCEDURE proparcon.sp_demo_final(date, date, numeric, date, date, numeric) OWNER TO "admin";
GRANT ALL ON PROCEDURE proparcon.sp_demo_final(date, date, numeric, date, date, numeric) TO "admin";

-- DROP PROCEDURE proparcon.sp_demo_more_data();

CREATE OR REPLACE PROCEDURE proparcon.sp_demo_more_data()
 LANGUAGE plpgsql
AS $procedure$
DECLARE
  -- Fechas objetivo
  v_oferta_fecha date := DATE '2026-01-10';
  v_ctr_inicio   date := DATE '2026-02-01';

  -- Inmuebles candidatos (libres)
  v_inmA bigint;  -- para oferta
  v_inmB bigint;  -- para contrato

  -- Estancias objetivo (nuevas o fallback a existentes)
  v_estA bigint;
  v_estB bigint;

  -- Persona demo
  v_pers bigint;

  -- Contrato B
  v_contratoB bigint;

  -- Asociación
  v_tbl_p1 regclass := to_regclass('proparcon.alquiler_contrato_inquilino');
  v_tbl_p2 regclass := to_regclass('proparcon.alquiler_contrato_persona');
  v_col_inq text;

  v_has_final boolean := (to_regprocedure('proparcon.sp_demo_final()') IS NOT NULL);
BEGIN
  -- 0) Asegurar base mínima (si no hay inmuebles)
  IF NOT EXISTS (SELECT 1 FROM proparcon.inmueble) THEN
    IF v_has_final THEN
      CALL proparcon.sp_demo_final();
    END IF;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM proparcon.inmueble) THEN
    RAISE NOTICE 'MORE_DATA: no hay inmuebles; se omiten escenarios.';
    RETURN;
  END IF;

  -- 1) Buscar inmueble libre para v_oferta_fecha
  WITH inm_libres AS (
    SELECT i.id
    FROM proparcon.inmueble i
    WHERE NOT EXISTS (
      SELECT 1 FROM proparcon.estancia e
      JOIN proparcon.alquiler_oferta o ON o.estancia_id = e.id
      WHERE e.inmueble_id = i.id
        AND daterange(o.fecha_alta, COALESCE(o.fecha_baja, DATE '9999-12-31'), '[]') @> v_oferta_fecha
    )
    AND NOT EXISTS (
      SELECT 1 FROM proparcon.estancia e
      JOIN proparcon.alquiler_contrato c ON c.estancia_id = e.id
      WHERE e.inmueble_id = i.id
        AND daterange(c.fecha_inicio, COALESCE(c.fecha_fin, DATE '9999-12-31'), '[]') @> v_oferta_fecha
    )
    ORDER BY i.id
  )
  SELECT id INTO v_inmA FROM inm_libres LIMIT 1;

  IF v_inmA IS NULL THEN
    RAISE NOTICE 'MORE_DATA: sin inmueble libre para OFERTA en %; omito escenario A.', v_oferta_fecha;
  END IF;

  -- 2) Buscar inmueble libre para v_ctr_inicio (distinto de A si hay)
  WITH inm_libres AS (
    SELECT i.id
    FROM proparcon.inmueble i
    WHERE NOT EXISTS (
      SELECT 1 FROM proparcon.estancia e
      JOIN proparcon.alquiler_oferta o ON o.estancia_id = e.id
      WHERE e.inmueble_id = i.id
        AND daterange(o.fecha_alta, COALESCE(o.fecha_baja, DATE '9999-12-31'), '[]') @> v_ctr_inicio
    )
    AND NOT EXISTS (
      SELECT 1 FROM proparcon.estancia e
      JOIN proparcon.alquiler_contrato c ON c.estancia_id = e.id
      WHERE e.inmueble_id = i.id
        AND daterange(c.fecha_inicio, COALESCE(c.fecha_fin, DATE '9999-12-31'), '[]') @> v_ctr_inicio
    )
    ORDER BY i.id
  )
  SELECT id INTO v_inmB FROM inm_libres
  WHERE (v_inmA IS NULL OR id <> v_inmA)
  LIMIT 1;

  IF v_inmB IS NULL THEN
    RAISE NOTICE 'MORE_DATA: sin inmueble libre para CONTRATO en %; omito escenario B.', v_ctr_inicio;
  END IF;

  IF v_inmA IS NULL AND v_inmB IS NULL THEN
    RAISE NOTICE 'MORE_DATA: no hay hueco libre en inmuebles; no se inserta nada.';
    RETURN;
  END IF;

  -- 3) Estancia A (crear o fallback)
  IF v_inmA IS NOT NULL THEN
    BEGIN
      INSERT INTO proparcon.estancia (inmueble_id)
      VALUES (v_inmA)
      RETURNING id INTO v_estA;
    EXCEPTION WHEN not_null_violation THEN
      SELECT id INTO v_estA
      FROM proparcon.estancia
      WHERE inmueble_id = v_inmA
      ORDER BY id
      LIMIT 1;
      IF v_estA IS NULL THEN
        RAISE NOTICE 'MORE_DATA: sin estancia utilizable en inmueble % (A); omito escenario A.', v_inmA;
      END IF;
    END;
  END IF;

  -- 4) Estancia B (crear o fallback)
  IF v_inmB IS NOT NULL THEN
    BEGIN
      INSERT INTO proparcon.estancia (inmueble_id)
      VALUES (v_inmB)
      RETURNING id INTO v_estB;
    EXCEPTION WHEN not_null_violation THEN
      SELECT id INTO v_estB
      FROM proparcon.estancia
      WHERE inmueble_id = v_inmB
      ORDER BY id
      LIMIT 1;
      IF v_estB IS NULL THEN
        RAISE NOTICE 'MORE_DATA: sin estancia utilizable en inmueble % (B); omito escenario B.', v_inmB;
      END IF;
    END;
  END IF;

  IF v_estA IS NULL AND v_estB IS NULL THEN
    RAISE NOTICE 'MORE_DATA: no hay estancias objetivo; no se inserta nada.';
    RETURN;
  END IF;

  -- 5) Escenario A: OFERTA (con guarda a nivel INMUEBLE + try/catch)
  IF v_estA IS NOT NULL THEN
    BEGIN
      INSERT INTO proparcon.alquiler_oferta (estancia_id, fecha_alta, fecha_baja, renta_mensual)
      SELECT v_estA, v_oferta_fecha, NULL, 700
      WHERE NOT EXISTS (  -- idempotencia por estancia+fecha exacta
        SELECT 1 FROM proparcon.alquiler_oferta
        WHERE estancia_id = v_estA
          AND fecha_alta   = v_oferta_fecha
      )
      AND NOT EXISTS (   -- GUARDA: inmueble libre para esa fecha (ofertas y contratos)
        SELECT 1
        FROM proparcon.estancia e2
        JOIN proparcon.alquiler_oferta o2 ON o2.estancia_id = e2.id
        WHERE e2.inmueble_id = (SELECT inmueble_id FROM proparcon.estancia WHERE id = v_estA)
          AND daterange(o2.fecha_alta, COALESCE(o2.fecha_baja, DATE '9999-12-31'), '[]') @> v_oferta_fecha
      )
      AND NOT EXISTS (
        SELECT 1
        FROM proparcon.estancia e3
        JOIN proparcon.alquiler_contrato c2 ON c2.estancia_id = e3.id
        WHERE e3.inmueble_id = (SELECT inmueble_id FROM proparcon.estancia WHERE id = v_estA)
          AND daterange(c2.fecha_inicio, COALESCE(c2.fecha_fin, DATE '9999-12-31'), '[]') @> v_oferta_fecha
      );
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'MORE_DATA(A): se omitió la oferta por exclusión/trigger: %', SQLERRM;
    END;
  END IF;

  -- 6) Escenario B: CONTRATO (idempotente, inactivo; guarda + try/catch)
  IF v_estB IS NOT NULL THEN
    BEGIN
      INSERT INTO proparcon.alquiler_contrato (estancia_id, fecha_inicio, fecha_fin, renta_mensual, activo)
      SELECT v_estB, v_ctr_inicio, NULL, 950, FALSE
      WHERE NOT EXISTS (  -- idempotencia por estancia+fecha exacta
        SELECT 1 FROM proparcon.alquiler_contrato
        WHERE estancia_id = v_estB
          AND fecha_inicio = v_ctr_inicio
      )
      AND NOT EXISTS (   -- GUARDA: inmueble libre para esa fecha (ofertas y contratos)
        SELECT 1
        FROM proparcon.estancia e2
        JOIN proparcon.alquiler_oferta o2 ON o2.estancia_id = e2.id
        WHERE e2.inmueble_id = (SELECT inmueble_id FROM proparcon.estancia WHERE id = v_estB)
          AND daterange(o2.fecha_alta, COALESCE(o2.fecha_baja, DATE '9999-12-31'), '[]') @> v_ctr_inicio
      )
      AND NOT EXISTS (
        SELECT 1
        FROM proparcon.estancia e3
        JOIN proparcon.alquiler_contrato c2 ON c2.estancia_id = e3.id
        WHERE e3.inmueble_id = (SELECT inmueble_id FROM proparcon.estancia WHERE id = v_estB)
          AND daterange(c2.fecha_inicio, COALESCE(c2.fecha_fin, DATE '9999-12-31'), '[]') @> v_ctr_inicio
      );
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'MORE_DATA(B): se omitió el contrato por exclusión/trigger: %', SQLERRM;
    END;
  END IF;

  -- 7) Si no se generó contrato B, terminar (escenario A pudo quedar OK)
  SELECT id INTO v_contratoB
  FROM proparcon.alquiler_contrato
  WHERE estancia_id = v_estB
    AND fecha_inicio = v_ctr_inicio
  ORDER BY id DESC
  LIMIT 1;

  IF v_contratoB IS NULL THEN
    RAISE NOTICE 'MORE_DATA: escenario A=% (estancia=%). Escenario B omitido.',
                 (v_estA IS NOT NULL), v_estA;
    RETURN;
  END IF;

  -- 8) Persona demo (o la primera)
  SELECT id INTO v_pers FROM proparcon.persona ORDER BY id LIMIT 1;
  IF v_pers IS NULL THEN
    INSERT INTO proparcon.persona DEFAULT VALUES RETURNING id INTO v_pers;
  END IF;

  -- 9) Asociar inquilino (puente1 → puente2 → columna directa)
  SELECT CASE
           WHEN EXISTS (SELECT 1 FROM information_schema.columns
                        WHERE table_schema='proparcon' AND table_name='alquiler_contrato'
                          AND column_name='inquilino_persona_id')    THEN 'inquilino_persona_id'
           WHEN EXISTS (SELECT 1 FROM information_schema.columns
                        WHERE table_schema='proparcon' AND table_name='alquiler_contrato'
                          AND column_name='arrendatario_persona_id') THEN 'arrendatario_persona_id'
           ELSE NULL
         END INTO v_col_inq;

  IF v_tbl_p1 IS NOT NULL THEN
    INSERT INTO proparcon.alquiler_contrato_inquilino (contrato_id, persona_id)
    SELECT v_contratoB, v_pers
    WHERE NOT EXISTS (
      SELECT 1 FROM proparcon.alquiler_contrato_inquilino
      WHERE contrato_id = v_contratoB AND persona_id = v_pers
    );
  ELSIF v_tbl_p2 IS NOT NULL THEN
    INSERT INTO proparcon.alquiler_contrato_persona (contrato_id, persona_id, rol)
    SELECT v_contratoB, v_pers, 'inquilino'
    WHERE NOT EXISTS (
      SELECT 1 FROM proparcon.alquiler_contrato_persona
      WHERE contrato_id = v_contratoB
        AND persona_id  = v_pers
        AND (rol = 'inquilino' OR rol IS NULL)
    );
  ELSIF v_col_inq IS NOT NULL THEN
    EXECUTE format('UPDATE proparcon.alquiler_contrato SET %I=$1 WHERE id=$2', v_col_inq)
    USING v_pers, v_contratoB;
  ELSE
    RAISE NOTICE 'MORE_DATA: sin mecanismo de asociación de inquilino; contrato permanece INACTIVO.';
    RETURN;
  END IF;

  -- 10) Activar contrato B
  UPDATE proparcon.alquiler_contrato SET activo = TRUE WHERE id = v_contratoB;

  -- 11) Log final
  RAISE NOTICE 'MORE_DATA OK · InmuebleA=%(EstanciaA=%) · InmuebleB=%(EstanciaB=%, ContratoB=%)',
               v_inmA, v_estA, v_inmB, v_estB, v_contratoB;
END;
$procedure$
;

-- Permissions

ALTER PROCEDURE proparcon.sp_demo_more_data() OWNER TO "admin";
GRANT ALL ON PROCEDURE proparcon.sp_demo_more_data() TO "admin";

-- DROP FUNCTION proparcon.trg_assert_contrato_tiene_inquilino_titular();

CREATE OR REPLACE FUNCTION proparcon.trg_assert_contrato_tiene_inquilino_titular()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE 
  v_count int;
  v_activo_id int;
BEGIN
  -- 1. Obtener el ID del estado 'ACTIVO'
  SELECT id INTO v_activo_id FROM proparcon.cat_estado_contrato WHERE codigo = 'ACTIVO';

  -- 2. Solo ejecutar el chequeo si el nuevo estado es 'ACTIVO'
  IF NEW.estado_id = v_activo_id THEN
    -- Contamos inquilinos que tienen es_titular = TRUE.
    SELECT COUNT(*) INTO v_count
    FROM proparcon.alquiler_contrato_inquilino i
    WHERE i.contrato_id = NEW.id
      AND i.es_titular IS TRUE;

    IF v_count < 1 THEN
      RAISE EXCEPTION 'El contrato debe tener al menos un inquilino titular para pasar a ACTIVO.'
        USING HINT = 'Regla de Negocio (3. Reglas de Negocio): Un contrato ACTIVO requiere un titular.';
    END IF;
  END IF; -- Si no es ACTIVO, la función retorna sin hacer nada.
  
  RETURN NEW;
END; $function$
;

-- Permissions

ALTER FUNCTION proparcon.trg_assert_contrato_tiene_inquilino_titular() OWNER TO "admin";
GRANT ALL ON FUNCTION proparcon.trg_assert_contrato_tiene_inquilino_titular() TO "admin";

-- DROP FUNCTION proparcon.trg_check_exclusion_alquiler_estancia();

CREATE OR REPLACE FUNCTION proparcon.trg_check_exclusion_alquiler_estancia()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_estancia bigint;
  v_count int;
  v_activo_id int;
BEGIN
  v_estancia := NEW.estancia_id;
  SELECT id INTO v_activo_id FROM proparcon.cat_estado_contrato WHERE codigo = 'ACTIVO';
  
  -- Solo se verifica si el nuevo estado es ACTIVO (ID 2).
  IF NEW.estado_id = v_activo_id THEN
    SELECT COUNT(*)
    INTO v_count
    FROM proparcon.alquiler_contrato ac
    WHERE ac.estancia_id = v_estancia
      AND ac.estado_id = v_activo_id
      AND ac.id <> COALESCE(NEW.id, 0);

    IF v_count > 0 THEN
      RAISE EXCEPTION 'Ya existe un contrato ACTIVO en la estancia %.', v_estancia
        USING HINT = 'La regla de negocio (2. Reglas de Negocio) impide dos contratos ACTIVO en la misma estancia.';
    END IF;
  END IF;
  
  RETURN NEW;
END; $function$
;

-- Permissions

ALTER FUNCTION proparcon.trg_check_exclusion_alquiler_estancia() OWNER TO "admin";
GRANT ALL ON FUNCTION proparcon.trg_check_exclusion_alquiler_estancia() TO "admin";

-- DROP FUNCTION proparcon.trg_check_propiedades_100();

CREATE OR REPLACE FUNCTION proparcon.trg_check_propiedades_100()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_inmueble bigint;
  v_sum_usufructo numeric(7,2);
  v_sum_nuda numeric(7,2);
  v_sum_pleno numeric(7,2);
BEGIN
  IF TG_OP = 'DELETE' THEN v_inmueble := OLD.inmueble_id; ELSE v_inmueble := NEW.inmueble_id; END IF;

  SELECT COALESCE(SUM(ip.porcentaje),0) INTO v_sum_usufructo
  FROM proparcon.inmueble_propiedad ip
  JOIN proparcon.cat_tipo_derecho_propiedad t ON t.id = ip.tipo_derecho_id
  WHERE ip.inmueble_id = v_inmueble AND t.codigo = 'USUFRUCTO';

  SELECT COALESCE(SUM(ip.porcentaje),0) INTO v_sum_nuda
  FROM proparcon.inmueble_propiedad ip
  JOIN proparcon.cat_tipo_derecho_propiedad t ON t.id = ip.tipo_derecho_id
  WHERE ip.inmueble_id = v_inmueble AND t.codigo = 'NUDA';

  SELECT COALESCE(SUM(ip.porcentaje),0) INTO v_sum_pleno
  FROM proparcon.inmueble_propiedad ip
  JOIN proparcon.cat_tipo_derecho_propiedad t ON t.id = ip.tipo_derecho_id
  WHERE ip.inmueble_id = v_inmueble AND t.codigo = 'PLENO';

  IF v_sum_pleno > 100 THEN
    RAISE EXCEPTION 'Pleno dominio (%.2f) excede 100%% en inmueble %', v_sum_pleno, v_inmueble;
  END IF;
  IF (v_sum_usufructo + v_sum_pleno) > 100 THEN
    RAISE EXCEPTION 'Usufructo+Pleno (%.2f) excede 100%% en inmueble %', (v_sum_usufructo + v_sum_pleno), v_inmueble;
  END IF;
  IF (v_sum_nuda + v_sum_pleno) > 100 THEN
    RAISE EXCEPTION 'Nuda+Pleno (%.2f) excede 100%% en inmueble %', (v_sum_nuda + v_sum_pleno), v_inmueble;
  END IF;

  RETURN COALESCE(NEW, OLD);
END; $function$
;

-- Permissions

ALTER FUNCTION proparcon.trg_check_propiedades_100() OWNER TO "admin";
GRANT ALL ON FUNCTION proparcon.trg_check_propiedades_100() TO "admin";


-- Permissions

GRANT ALL ON SCHEMA proparcon TO "admin";