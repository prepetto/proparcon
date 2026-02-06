-- 1) % de propiedad (PLENO suma con USUFRUCTO/NUDA)
CREATE OR REPLACE FUNCTION proparcon.trg_check_propiedades_100()
RETURNS trigger AS $$
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
END; $$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_propiedades_100 ON proparcon.inmueble_propiedad;
CREATE TRIGGER trg_propiedades_100
AFTER INSERT OR UPDATE OR DELETE ON proparcon.inmueble_propiedad
FOR EACH STATEMENT EXECUTE FUNCTION proparcon.trg_check_propiedades_100();

-- 2) Helper
CREATE OR REPLACE FUNCTION proparcon.fn_inmueble_de_estancia(in_estancia_id bigint)
RETURNS bigint AS $$
DECLARE v_inmueble_id bigint;
BEGIN
  SELECT e.inmueble_id INTO v_inmueble_id FROM proparcon.estancia e WHERE e.id = in_estancia_id;
  RETURN v_inmueble_id;
END; $$ LANGUAGE plpgsql IMMUTABLE;

-- 3) Exclusión: solo 1 actividad activa (oferta o contrato) por inmueble
CREATE OR REPLACE FUNCTION proparcon.trg_check_exclusion_alquiler()
RETURNS trigger AS $$
DECLARE v_inmueble bigint; v_activas int;
BEGIN
  IF TG_OP IN ('INSERT','UPDATE') THEN
    v_inmueble := proparcon.fn_inmueble_de_estancia(NEW.estancia_id);

    SELECT
      (SELECT COUNT(*) FROM proparcon.alquiler_oferta ao
         JOIN proparcon.estancia e1 ON e1.id = ao.estancia_id
       WHERE ao.fecha_baja IS NULL
         AND e1.inmueble_id = v_inmueble
         AND (TG_TABLE_NAME <> 'alquiler_oferta' OR ao.id <> COALESCE(NEW.id,0)))
      +
      (SELECT COUNT(*) FROM proparcon.alquiler_contrato ac
         JOIN proparcon.estancia e2 ON e2.id = ac.estancia_id
       WHERE ac.activo = true
         AND e2.inmueble_id = v_inmueble
         AND (TG_TABLE_NAME <> 'alquiler_contrato' OR ac.id <> COALESCE(NEW.id,0)))
    INTO v_activas;

    IF v_activas > 0 THEN
      RAISE EXCEPTION 'Ya hay alquiler (oferta/contrato) activo en inmueble %', v_inmueble;
    END IF;
  END IF;
  RETURN NEW;
END; $$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_exclusion_alquiler_oferta   ON proparcon.alquiler_oferta;
CREATE TRIGGER trg_exclusion_alquiler_oferta
BEFORE INSERT OR UPDATE ON proparcon.alquiler_oferta
FOR EACH ROW EXECUTE FUNCTION proparcon.trg_check_exclusion_alquiler();

DROP TRIGGER IF EXISTS trg_exclusion_alquiler_contrato ON proparcon.alquiler_contrato;
CREATE TRIGGER trg_exclusion_alquiler_contrato
BEFORE INSERT OR UPDATE ON proparcon.alquiler_contrato
FOR EACH ROW EXECUTE FUNCTION proparcon.trg_check_exclusion_alquiler();

-- 4) Contrato con ≥ 1 inquilino (deferrable)
CREATE OR REPLACE FUNCTION proparcon.trg_assert_contrato_tiene_inquilino()
RETURNS trigger AS $$
DECLARE v_count int;
BEGIN
  SELECT COUNT(*) INTO v_count FROM proparcon.alquiler_contrato_inquilino i WHERE i.contrato_id = NEW.id;
  IF v_count < 1 THEN
    RAISE EXCEPTION 'Contrato % debe tener ≥1 inquilino', NEW.id;
  END IF;
  RETURN NEW;
END; $$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS ctr_contrato_tiene_inquilino ON proparcon.alquiler_contrato;
CREATE CONSTRAINT TRIGGER ctr_contrato_tiene_inquilino
AFTER INSERT OR UPDATE ON proparcon.alquiler_contrato
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION proparcon.trg_assert_contrato_tiene_inquilino();
