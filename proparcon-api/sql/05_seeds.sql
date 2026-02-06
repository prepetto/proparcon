-- País / Provincia
INSERT INTO proparcon.cat_pais (iso2, nombre) VALUES ('ES','España') ON CONFLICT (iso2) DO NOTHING;

INSERT INTO proparcon.cat_provincia (pais_id, nombre)
SELECT id, 'Madrid' FROM proparcon.cat_pais WHERE iso2='ES'
ON CONFLICT DO NOTHING;

-- Tipos de vía
INSERT INTO proparcon.cat_tipo_via (codigo, descripcion) VALUES
 ('CL','Calle'), ('AV','Avenida'), ('PS','Paseo'), ('TR','Travesía')
ON CONFLICT (codigo) DO NOTHING;

-- Roles
INSERT INTO proparcon.cat_rol (codigo, descripcion) VALUES
 ('GESTOR','Gestor'), ('ENCARGADO','Encargado'), ('PREINQUILINO','PreInquilino'),
 ('INQUILINO','Inquilino'), ('OCUPANTE','Ocupante'), ('PROPIETARIO','Propietario'),
 ('GESTORIA','Gestoría'), ('FIADOR','Fiador'), ('EMPLEADO','Empleado')
ON CONFLICT (codigo) DO NOTHING;

-- Tipos de inmueble
INSERT INTO proparcon.cat_tipo_inmueble (codigo, descripcion) VALUES
 ('PISO','Piso'), ('CHALET','Chalet'), ('LOCAL','Local'),
 ('NAVE','Nave'), ('GARAJE','Plaza de garaje'), ('TRASTERO','Trastero'),
 ('RUSTICA','Rústica'), ('SOLAR','Solar'), ('URBANO','Urbano')
ON CONFLICT (codigo) DO NOTHING;

-- Tipos de estancia
INSERT INTO proparcon.cat_tipo_estancia (codigo, descripcion, alquilable, es_raiz) VALUES
 ('INMUEBLE','Inmueble completo', true, true),
 ('DEPENDENCIA','Dependencia alquilable', true, false),
 ('COCINA','Cocina (no alquilable)', false, false),
 ('BANIO','Baño (no alquilable)', false, false),
 ('SALON','Salón (no alquilable)', false, false),
 ('ASEO','Aseo (no alquilable)', false, false),
 ('TERRAZA','Terraza (no alquilable)', false, false),
 ('BALCON','Balcón (no alquilable)', false, false),
 ('SOLARIUM','Solarium (no alquilable)', false, false)
ON CONFLICT (codigo) DO NOTHING;

-- Derechos de propiedad
INSERT INTO proparcon.cat_tipo_derecho_propiedad (codigo, descripcion) VALUES
 ('USUFRUCTO','Usufructo'), ('NUDA','Nuda propiedad'), ('PLENO','Pleno dominio')
ON CONFLICT (codigo) DO NOTHING;

-- Estados de oferta
INSERT INTO proparcon.cat_estado_oferta_alquiler (codigo, descripcion) VALUES
 ('VACIO','Disponible'), ('RESERVADO','Reservado'), ('EN_OBRA','En obra')
ON CONFLICT (codigo) DO NOTHING;

-- Tipos de aval
INSERT INTO proparcon.cat_tipo_avaliador (codigo, descripcion) VALUES
 ('PERSONA','Aval personal (fiador)'),
 ('SEGURO_IMPAGO','Seguro de impago'),
 ('AVAL_BANCARIO','Aval bancario')
ON CONFLICT (codigo) DO NOTHING;

-- Tipos de ingreso
INSERT INTO proparcon.cat_tipo_ingreso (codigo, descripcion) VALUES
 ('NOMINA','Nómina'), ('NOMINA_B','Nómina en B'), ('PENSION','Pensión'),
 ('AUTONOMO','Autónomo'), ('ESTUDIANTE','Ayuda familiar'),
 ('BECARIO','Beca / ayuda estatal'), ('AHORROS','Ahorros')
ON CONFLICT (codigo) DO NOTHING;

-- Órganos de administración
INSERT INTO proparcon.org_admin_tipo (codigo, descripcion) VALUES
 ('ADM_UNICO','Administrador único'),
 ('SOLIDARIOS','Administradores solidarios'),
 ('MANCOMUNADOS','Administradores mancomunados'),
 ('CONSEJO','Consejo de administración')
ON CONFLICT (codigo) DO NOTHING;
