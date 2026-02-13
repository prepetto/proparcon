--
-- PostgreSQL database dump
--

\restrict GWD7xa0IJmN7jK0Hf0BbtC0jzhR68hLKrTFwfct1B5QolNcP3YNxIqFwGTee3hR

-- Dumped from database version 15.15 (Debian 15.15-1.pgdg13+1)
-- Dumped by pg_dump version 15.15 (Debian 15.15-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: proparcon; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA proparcon;


--
-- Name: fn_inmueble_de_estancia(bigint); Type: FUNCTION; Schema: proparcon; Owner: -
--

CREATE FUNCTION proparcon.fn_inmueble_de_estancia(in_estancia_id bigint) RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE v_inmueble_id bigint;
BEGIN
  SELECT e.inmueble_id INTO v_inmueble_id FROM proparcon.estancia e WHERE e.id = in_estancia_id;
  RETURN v_inmueble_id;
END; $$;


--
-- Name: sp_demo_final(date, date, numeric, date, date, numeric); Type: PROCEDURE; Schema: proparcon; Owner: -
--

CREATE PROCEDURE proparcon.sp_demo_final(IN p_oferta_inicio date DEFAULT '2025-11-01'::date, IN p_oferta_fin date DEFAULT NULL::date, IN p_oferta_renta numeric DEFAULT 850, IN p_contrato_inicio date DEFAULT '2025-12-01'::date, IN p_contrato_fin date DEFAULT NULL::date, IN p_contrato_renta numeric DEFAULT 900)
    LANGUAGE plpgsql
    AS $_$
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
$_$;


--
-- Name: sp_demo_more_data(); Type: PROCEDURE; Schema: proparcon; Owner: -
--

CREATE PROCEDURE proparcon.sp_demo_more_data()
    LANGUAGE plpgsql
    AS $_$
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
$_$;


--
-- Name: trg_assert_contrato_tiene_inquilino_titular(); Type: FUNCTION; Schema: proparcon; Owner: -
--

CREATE FUNCTION proparcon.trg_assert_contrato_tiene_inquilino_titular() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
END; $$;


--
-- Name: trg_check_exclusion_alquiler_estancia(); Type: FUNCTION; Schema: proparcon; Owner: -
--

CREATE FUNCTION proparcon.trg_check_exclusion_alquiler_estancia() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
END; $$;


--
-- Name: trg_check_propiedades_100(); Type: FUNCTION; Schema: proparcon; Owner: -
--

CREATE FUNCTION proparcon.trg_check_propiedades_100() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
END; $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alquiler_contrato; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.alquiler_contrato (
    id bigint NOT NULL,
    estancia_id bigint NOT NULL,
    fecha_inicio date NOT NULL,
    fecha_fin date,
    contrato_pdf_url text,
    gestor_persona_id bigint,
    encargado_persona_id bigint,
    renta_mensual numeric(12,2) NOT NULL,
    estado_id integer DEFAULT 1 NOT NULL,
    oferta_id bigint,
    fianza numeric(12,2),
    tipo_contrato_id integer,
    CONSTRAINT alquiler_contrato_fianza_check CHECK ((fianza >= (0)::numeric)),
    CONSTRAINT alquiler_contrato_renta_mensual_check CHECK ((renta_mensual >= (0)::numeric))
);


--
-- Name: alquiler_contrato_aval; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.alquiler_contrato_aval (
    id bigint NOT NULL,
    contrato_id bigint NOT NULL,
    tipo_avaliador_id integer NOT NULL,
    persona_id bigint,
    juridica_id bigint,
    entidad_bancaria_id bigint,
    importe_maximo numeric(12,2),
    plazo_meses integer,
    detalles text,
    CONSTRAINT alquiler_contrato_aval_check CHECK (((tipo_avaliador_id IS NOT NULL) AND (((persona_id IS NOT NULL) AND (juridica_id IS NULL)) OR ((persona_id IS NULL) AND (juridica_id IS NOT NULL)) OR (entidad_bancaria_id IS NOT NULL))))
);


--
-- Name: alquiler_contrato_aval_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.alquiler_contrato_aval ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.alquiler_contrato_aval_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: alquiler_contrato_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.alquiler_contrato ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.alquiler_contrato_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: alquiler_contrato_inquilino; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.alquiler_contrato_inquilino (
    id bigint NOT NULL,
    contrato_id bigint NOT NULL,
    persona_id bigint,
    juridica_id bigint,
    es_titular boolean DEFAULT false NOT NULL,
    CONSTRAINT alquiler_contrato_inquilino_check CHECK ((((persona_id IS NOT NULL) AND (juridica_id IS NULL)) OR ((persona_id IS NULL) AND (juridica_id IS NOT NULL))))
);


--
-- Name: alquiler_contrato_inquilino_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.alquiler_contrato_inquilino ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.alquiler_contrato_inquilino_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: alquiler_oferta; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.alquiler_oferta (
    id bigint NOT NULL,
    estancia_id bigint NOT NULL,
    estado_id integer NOT NULL,
    renta_mensual numeric(12,2) NOT NULL,
    gestor_persona_id bigint,
    encargado_persona_id bigint,
    fecha_alta date DEFAULT now() NOT NULL,
    fecha_baja date,
    CONSTRAINT alquiler_oferta_renta_mensual_check CHECK ((renta_mensual >= (0)::numeric))
);


--
-- Name: alquiler_oferta_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.alquiler_oferta ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.alquiler_oferta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cat_estado_contrato; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.cat_estado_contrato (
    id integer NOT NULL,
    codigo character varying(40) NOT NULL,
    descripcion text NOT NULL
);


--
-- Name: cat_estado_contrato_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.cat_estado_contrato ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.cat_estado_contrato_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cat_estado_oferta_alquiler; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.cat_estado_oferta_alquiler (
    id integer NOT NULL,
    codigo character varying(40) NOT NULL,
    descripcion text NOT NULL
);


--
-- Name: cat_estado_oferta_alquiler_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.cat_estado_oferta_alquiler ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.cat_estado_oferta_alquiler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cat_pais; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.cat_pais (
    id integer NOT NULL,
    iso2 character(2) NOT NULL,
    nombre text NOT NULL
);


--
-- Name: cat_pais_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.cat_pais ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.cat_pais_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cat_provincia; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.cat_provincia (
    id integer NOT NULL,
    pais_id integer NOT NULL,
    nombre text NOT NULL
);


--
-- Name: cat_provincia_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.cat_provincia ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.cat_provincia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cat_rol; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.cat_rol (
    id integer NOT NULL,
    codigo character varying(40) NOT NULL,
    descripcion text NOT NULL
);


--
-- Name: cat_rol_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.cat_rol ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.cat_rol_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cat_tipo_avaliador; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.cat_tipo_avaliador (
    id integer NOT NULL,
    codigo character varying(40) NOT NULL,
    descripcion text NOT NULL
);


--
-- Name: cat_tipo_avaliador_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.cat_tipo_avaliador ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.cat_tipo_avaliador_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cat_tipo_contrato; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.cat_tipo_contrato (
    id integer NOT NULL,
    codigo character varying(40) NOT NULL,
    descripcion text NOT NULL
);


--
-- Name: cat_tipo_contrato_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.cat_tipo_contrato ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.cat_tipo_contrato_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cat_tipo_derecho_propiedad; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.cat_tipo_derecho_propiedad (
    id integer NOT NULL,
    codigo character varying(40) NOT NULL,
    descripcion text NOT NULL
);


--
-- Name: cat_tipo_derecho_propiedad_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.cat_tipo_derecho_propiedad ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.cat_tipo_derecho_propiedad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cat_tipo_estancia; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.cat_tipo_estancia (
    id integer NOT NULL,
    codigo character varying(40) NOT NULL,
    descripcion text NOT NULL,
    alquilable boolean DEFAULT false NOT NULL,
    es_raiz boolean DEFAULT false NOT NULL
);


--
-- Name: cat_tipo_estancia_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.cat_tipo_estancia ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.cat_tipo_estancia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cat_tipo_ingreso; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.cat_tipo_ingreso (
    id integer NOT NULL,
    codigo character varying(40) NOT NULL,
    descripcion text NOT NULL
);


--
-- Name: cat_tipo_ingreso_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.cat_tipo_ingreso ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.cat_tipo_ingreso_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cat_tipo_inmueble; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.cat_tipo_inmueble (
    id integer NOT NULL,
    codigo character varying(40) NOT NULL,
    descripcion text NOT NULL
);


--
-- Name: cat_tipo_inmueble_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.cat_tipo_inmueble ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.cat_tipo_inmueble_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cat_tipo_via; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.cat_tipo_via (
    id integer NOT NULL,
    codigo character varying(20) NOT NULL,
    descripcion text NOT NULL
);


--
-- Name: cat_tipo_via_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.cat_tipo_via ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.cat_tipo_via_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: catastro; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.catastro (
    id bigint NOT NULL,
    inmueble_id bigint NOT NULL,
    ref_catastral character varying(20) NOT NULL,
    direccion_catastral_id bigint,
    uso text,
    anio_construccion integer,
    coef_participacion numeric(5,2),
    sup_construida numeric(10,2),
    sup_parcela numeric(10,2),
    CONSTRAINT catastro_coef_participacion_check CHECK (((coef_participacion >= (0)::numeric) AND (coef_participacion <= (100)::numeric)))
);


--
-- Name: catastro_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.catastro ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.catastro_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: centro_trabajo; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.centro_trabajo (
    id bigint NOT NULL,
    juridica_id bigint NOT NULL,
    direccion_id bigint NOT NULL
);


--
-- Name: centro_trabajo_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.centro_trabajo ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.centro_trabajo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: databasechangelog; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.databasechangelog (
    id character varying(255) NOT NULL,
    author character varying(255) NOT NULL,
    filename character varying(255) NOT NULL,
    dateexecuted timestamp without time zone NOT NULL,
    orderexecuted integer NOT NULL,
    exectype character varying(10) NOT NULL,
    md5sum character varying(35),
    description character varying(255),
    comments character varying(255),
    tag character varying(255),
    liquibase character varying(20),
    contexts character varying(255),
    labels character varying(255),
    deployment_id character varying(10)
);


--
-- Name: databasechangeloglock; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.databasechangeloglock (
    id integer NOT NULL,
    locked boolean NOT NULL,
    lockgranted timestamp without time zone,
    lockedby character varying(255)
);


--
-- Name: direccion; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.direccion (
    id bigint NOT NULL,
    tipo_via_id integer,
    via_nombre text NOT NULL,
    numero character varying(10),
    escalera character varying(10),
    piso character varying(10),
    puerta character varying(10),
    cp character varying(10),
    municipio text,
    provincia_id integer,
    pais_id integer,
    observaciones text
);


--
-- Name: direccion_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.direccion ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.direccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: empleado; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.empleado (
    id bigint NOT NULL,
    persona_id bigint NOT NULL,
    juridica_id bigint NOT NULL,
    centro_trabajo_id bigint
);


--
-- Name: empleado_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.empleado ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.empleado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: entidad_bancaria; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.entidad_bancaria (
    id bigint NOT NULL,
    nombre text NOT NULL,
    cod_banco_esp character(4),
    swift_bic character varying(11)
);


--
-- Name: entidad_bancaria_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.entidad_bancaria ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.entidad_bancaria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: estancia; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.estancia (
    id bigint NOT NULL,
    inmueble_id bigint NOT NULL,
    tipo_estancia_id integer NOT NULL,
    nombre text,
    parent_estancia_id bigint
);


--
-- Name: estancia_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.estancia ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.estancia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: inmueble; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.inmueble (
    id bigint NOT NULL,
    tipo_inmueble_id integer NOT NULL,
    nombre_publico text,
    direccion_id bigint,
    gestor_persona_id bigint,
    encargado_persona_id bigint,
    gestoria_juridica_id bigint,
    cod_inm integer NOT NULL
);


--
-- Name: COLUMN inmueble.cod_inm; Type: COMMENT; Schema: proparcon; Owner: -
--

COMMENT ON COLUMN proparcon.inmueble.cod_inm IS 'Código de negocio único de inmueble';


--
-- Name: inmueble_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.inmueble ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.inmueble_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: inmueble_propiedad; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.inmueble_propiedad (
    id bigint NOT NULL,
    inmueble_id bigint NOT NULL,
    persona_id bigint,
    juridica_id bigint,
    tipo_derecho_id integer NOT NULL,
    porcentaje numeric(5,2) NOT NULL,
    CONSTRAINT inmueble_propiedad_check CHECK ((((persona_id IS NOT NULL) AND (juridica_id IS NULL)) OR ((persona_id IS NULL) AND (juridica_id IS NOT NULL)))),
    CONSTRAINT inmueble_propiedad_porcentaje_check CHECK (((porcentaje >= (0)::numeric) AND (porcentaje <= (100)::numeric)))
);


--
-- Name: inmueble_propiedad_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.inmueble_propiedad ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.inmueble_propiedad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: juridica; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.juridica (
    id bigint NOT NULL,
    cif character varying(20) NOT NULL,
    denominacion_social text NOT NULL,
    abreviatura character varying(10),
    domicilio_fiscal_id bigint,
    acta_titularidad_real date
);


--
-- Name: juridica_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.juridica ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.juridica_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: org_admin; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.org_admin (
    id bigint NOT NULL,
    juridica_id bigint NOT NULL,
    tipo_id integer NOT NULL,
    fecha_escritura date
);


--
-- Name: org_admin_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.org_admin ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.org_admin_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: org_admin_miembro; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.org_admin_miembro (
    id bigint NOT NULL,
    org_admin_id bigint NOT NULL,
    persona_id bigint,
    juridica_id bigint,
    representante_persona_id bigint,
    CONSTRAINT org_admin_miembro_check CHECK ((((persona_id IS NOT NULL) AND (juridica_id IS NULL)) OR ((persona_id IS NULL) AND (juridica_id IS NOT NULL))))
);


--
-- Name: org_admin_miembro_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.org_admin_miembro ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.org_admin_miembro_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: org_admin_tipo; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.org_admin_tipo (
    id integer NOT NULL,
    codigo character varying(40) NOT NULL,
    descripcion text NOT NULL
);


--
-- Name: org_admin_tipo_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.org_admin_tipo ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.org_admin_tipo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: persona; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.persona (
    id bigint NOT NULL,
    tipo_doc character varying(20) NOT NULL,
    doc_identidad text NOT NULL,
    nombre text NOT NULL,
    apellido1 text NOT NULL,
    apellido2 text,
    fecha_nacimiento date,
    lugar_nacimiento text,
    nacionalidad text,
    profesion text,
    direccion_id bigint,
    telefono_fijo character varying(25),
    telefono_movil character varying(25),
    email_particular text,
    email_laboral text,
    nick text,
    linkedin text,
    iban text,
    CONSTRAINT persona_doc_identidad_check CHECK (((length(doc_identidad) >= 3) AND (length(doc_identidad) <= 64)))
);


--
-- Name: persona_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.persona ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.persona_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: persona_rol; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.persona_rol (
    id bigint NOT NULL,
    persona_id bigint NOT NULL,
    rol_id integer NOT NULL,
    gestor_supervisor_id bigint,
    fecha_alta date DEFAULT now(),
    fecha_baja date
);


--
-- Name: persona_rol_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.persona_rol ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.persona_rol_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: registro_propiedad; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.registro_propiedad (
    id bigint NOT NULL,
    inmueble_id bigint NOT NULL,
    localidad text NOT NULL,
    registro_numero text NOT NULL,
    seccion text,
    finca text NOT NULL,
    cru_idufir text,
    arp_fecha date,
    nota_simple_url text
);


--
-- Name: registro_propiedad_id_seq; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.registro_propiedad ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.registro_propiedad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: users; Type: TABLE; Schema: proparcon; Owner: -
--

CREATE TABLE proparcon.users (
    id bigint NOT NULL,
    persona_id bigint NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now(),
    role character varying(20) DEFAULT 'lector'::character varying NOT NULL
);


--
-- Name: users_id_seq1; Type: SEQUENCE; Schema: proparcon; Owner: -
--

ALTER TABLE proparcon.users ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME proparcon.users_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: alquiler_contrato_aval alquiler_contrato_aval_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_contrato_aval
    ADD CONSTRAINT alquiler_contrato_aval_pkey PRIMARY KEY (id);


--
-- Name: alquiler_contrato_inquilino alquiler_contrato_inquilino_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_contrato_inquilino
    ADD CONSTRAINT alquiler_contrato_inquilino_pkey PRIMARY KEY (id);


--
-- Name: alquiler_contrato alquiler_contrato_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_contrato
    ADD CONSTRAINT alquiler_contrato_pkey PRIMARY KEY (id);


--
-- Name: alquiler_oferta alquiler_oferta_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_oferta
    ADD CONSTRAINT alquiler_oferta_pkey PRIMARY KEY (id);


--
-- Name: cat_estado_contrato cat_estado_contrato_codigo_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_estado_contrato
    ADD CONSTRAINT cat_estado_contrato_codigo_key UNIQUE (codigo);


--
-- Name: cat_estado_contrato cat_estado_contrato_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_estado_contrato
    ADD CONSTRAINT cat_estado_contrato_pkey PRIMARY KEY (id);


--
-- Name: cat_estado_oferta_alquiler cat_estado_oferta_alquiler_codigo_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_estado_oferta_alquiler
    ADD CONSTRAINT cat_estado_oferta_alquiler_codigo_key UNIQUE (codigo);


--
-- Name: cat_estado_oferta_alquiler cat_estado_oferta_alquiler_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_estado_oferta_alquiler
    ADD CONSTRAINT cat_estado_oferta_alquiler_pkey PRIMARY KEY (id);


--
-- Name: cat_pais cat_pais_iso2_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_pais
    ADD CONSTRAINT cat_pais_iso2_key UNIQUE (iso2);


--
-- Name: cat_pais cat_pais_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_pais
    ADD CONSTRAINT cat_pais_pkey PRIMARY KEY (id);


--
-- Name: cat_provincia cat_provincia_pais_id_nombre_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_provincia
    ADD CONSTRAINT cat_provincia_pais_id_nombre_key UNIQUE (pais_id, nombre);


--
-- Name: cat_provincia cat_provincia_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_provincia
    ADD CONSTRAINT cat_provincia_pkey PRIMARY KEY (id);


--
-- Name: cat_rol cat_rol_codigo_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_rol
    ADD CONSTRAINT cat_rol_codigo_key UNIQUE (codigo);


--
-- Name: cat_rol cat_rol_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_rol
    ADD CONSTRAINT cat_rol_pkey PRIMARY KEY (id);


--
-- Name: cat_tipo_avaliador cat_tipo_avaliador_codigo_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_tipo_avaliador
    ADD CONSTRAINT cat_tipo_avaliador_codigo_key UNIQUE (codigo);


--
-- Name: cat_tipo_avaliador cat_tipo_avaliador_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_tipo_avaliador
    ADD CONSTRAINT cat_tipo_avaliador_pkey PRIMARY KEY (id);


--
-- Name: cat_tipo_contrato cat_tipo_contrato_codigo_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_tipo_contrato
    ADD CONSTRAINT cat_tipo_contrato_codigo_key UNIQUE (codigo);


--
-- Name: cat_tipo_contrato cat_tipo_contrato_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_tipo_contrato
    ADD CONSTRAINT cat_tipo_contrato_pkey PRIMARY KEY (id);


--
-- Name: cat_tipo_derecho_propiedad cat_tipo_derecho_propiedad_codigo_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_tipo_derecho_propiedad
    ADD CONSTRAINT cat_tipo_derecho_propiedad_codigo_key UNIQUE (codigo);


--
-- Name: cat_tipo_derecho_propiedad cat_tipo_derecho_propiedad_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_tipo_derecho_propiedad
    ADD CONSTRAINT cat_tipo_derecho_propiedad_pkey PRIMARY KEY (id);


--
-- Name: cat_tipo_estancia cat_tipo_estancia_codigo_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_tipo_estancia
    ADD CONSTRAINT cat_tipo_estancia_codigo_key UNIQUE (codigo);


--
-- Name: cat_tipo_estancia cat_tipo_estancia_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_tipo_estancia
    ADD CONSTRAINT cat_tipo_estancia_pkey PRIMARY KEY (id);


--
-- Name: cat_tipo_ingreso cat_tipo_ingreso_codigo_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_tipo_ingreso
    ADD CONSTRAINT cat_tipo_ingreso_codigo_key UNIQUE (codigo);


--
-- Name: cat_tipo_ingreso cat_tipo_ingreso_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_tipo_ingreso
    ADD CONSTRAINT cat_tipo_ingreso_pkey PRIMARY KEY (id);


--
-- Name: cat_tipo_inmueble cat_tipo_inmueble_codigo_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_tipo_inmueble
    ADD CONSTRAINT cat_tipo_inmueble_codigo_key UNIQUE (codigo);


--
-- Name: cat_tipo_inmueble cat_tipo_inmueble_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_tipo_inmueble
    ADD CONSTRAINT cat_tipo_inmueble_pkey PRIMARY KEY (id);


--
-- Name: cat_tipo_via cat_tipo_via_codigo_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_tipo_via
    ADD CONSTRAINT cat_tipo_via_codigo_key UNIQUE (codigo);


--
-- Name: cat_tipo_via cat_tipo_via_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_tipo_via
    ADD CONSTRAINT cat_tipo_via_pkey PRIMARY KEY (id);


--
-- Name: catastro catastro_inmueble_id_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.catastro
    ADD CONSTRAINT catastro_inmueble_id_key UNIQUE (inmueble_id);


--
-- Name: catastro catastro_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.catastro
    ADD CONSTRAINT catastro_pkey PRIMARY KEY (id);


--
-- Name: catastro catastro_ref_catastral_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.catastro
    ADD CONSTRAINT catastro_ref_catastral_key UNIQUE (ref_catastral);


--
-- Name: centro_trabajo centro_trabajo_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.centro_trabajo
    ADD CONSTRAINT centro_trabajo_pkey PRIMARY KEY (id);


--
-- Name: databasechangeloglock databasechangeloglock_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.databasechangeloglock
    ADD CONSTRAINT databasechangeloglock_pkey PRIMARY KEY (id);


--
-- Name: direccion direccion_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.direccion
    ADD CONSTRAINT direccion_pkey PRIMARY KEY (id);


--
-- Name: empleado empleado_persona_id_juridica_id_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.empleado
    ADD CONSTRAINT empleado_persona_id_juridica_id_key UNIQUE (persona_id, juridica_id);


--
-- Name: empleado empleado_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.empleado
    ADD CONSTRAINT empleado_pkey PRIMARY KEY (id);


--
-- Name: entidad_bancaria entidad_bancaria_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.entidad_bancaria
    ADD CONSTRAINT entidad_bancaria_pkey PRIMARY KEY (id);


--
-- Name: estancia estancia_inmueble_id_nombre_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.estancia
    ADD CONSTRAINT estancia_inmueble_id_nombre_key UNIQUE (inmueble_id, nombre);


--
-- Name: estancia estancia_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.estancia
    ADD CONSTRAINT estancia_pkey PRIMARY KEY (id);


--
-- Name: inmueble inmueble_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.inmueble
    ADD CONSTRAINT inmueble_pkey PRIMARY KEY (id);


--
-- Name: inmueble_propiedad inmueble_propiedad_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.inmueble_propiedad
    ADD CONSTRAINT inmueble_propiedad_pkey PRIMARY KEY (id);


--
-- Name: juridica juridica_cif_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.juridica
    ADD CONSTRAINT juridica_cif_key UNIQUE (cif);


--
-- Name: juridica juridica_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.juridica
    ADD CONSTRAINT juridica_pkey PRIMARY KEY (id);


--
-- Name: org_admin_miembro org_admin_miembro_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.org_admin_miembro
    ADD CONSTRAINT org_admin_miembro_pkey PRIMARY KEY (id);


--
-- Name: org_admin org_admin_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.org_admin
    ADD CONSTRAINT org_admin_pkey PRIMARY KEY (id);


--
-- Name: org_admin_tipo org_admin_tipo_codigo_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.org_admin_tipo
    ADD CONSTRAINT org_admin_tipo_codigo_key UNIQUE (codigo);


--
-- Name: org_admin_tipo org_admin_tipo_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.org_admin_tipo
    ADD CONSTRAINT org_admin_tipo_pkey PRIMARY KEY (id);


--
-- Name: persona persona_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.persona
    ADD CONSTRAINT persona_pkey PRIMARY KEY (id);


--
-- Name: persona_rol persona_rol_persona_id_rol_id_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.persona_rol
    ADD CONSTRAINT persona_rol_persona_id_rol_id_key UNIQUE (persona_id, rol_id);


--
-- Name: persona_rol persona_rol_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.persona_rol
    ADD CONSTRAINT persona_rol_pkey PRIMARY KEY (id);


--
-- Name: persona persona_tipo_doc_doc_identidad_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.persona
    ADD CONSTRAINT persona_tipo_doc_doc_identidad_key UNIQUE (tipo_doc, doc_identidad);


--
-- Name: registro_propiedad registro_propiedad_cru_idufir_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.registro_propiedad
    ADD CONSTRAINT registro_propiedad_cru_idufir_key UNIQUE (cru_idufir);


--
-- Name: registro_propiedad registro_propiedad_inmueble_id_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.registro_propiedad
    ADD CONSTRAINT registro_propiedad_inmueble_id_key UNIQUE (inmueble_id);


--
-- Name: registro_propiedad registro_propiedad_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.registro_propiedad
    ADD CONSTRAINT registro_propiedad_pkey PRIMARY KEY (id);


--
-- Name: alquiler_contrato_inquilino uq_contrato_inquilino; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_contrato_inquilino
    ADD CONSTRAINT uq_contrato_inquilino UNIQUE (contrato_id, persona_id) DEFERRABLE;


--
-- Name: inmueble uq_inmueble_cod_inm; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.inmueble
    ADD CONSTRAINT uq_inmueble_cod_inm UNIQUE (cod_inm);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_persona_id_key; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.users
    ADD CONSTRAINT users_persona_id_key UNIQUE (persona_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: proparcon_idx_alq_contrato_estancia; Type: INDEX; Schema: proparcon; Owner: -
--

CREATE INDEX proparcon_idx_alq_contrato_estancia ON proparcon.alquiler_contrato USING btree (estancia_id);


--
-- Name: proparcon_idx_alq_oferta_estancia; Type: INDEX; Schema: proparcon; Owner: -
--

CREATE INDEX proparcon_idx_alq_oferta_estancia ON proparcon.alquiler_oferta USING btree (estancia_id);


--
-- Name: proparcon_idx_estancia_inmueble; Type: INDEX; Schema: proparcon; Owner: -
--

CREATE INDEX proparcon_idx_estancia_inmueble ON proparcon.estancia USING btree (inmueble_id);


--
-- Name: proparcon_idx_inm_prop_inmueble; Type: INDEX; Schema: proparcon; Owner: -
--

CREATE INDEX proparcon_idx_inm_prop_inmueble ON proparcon.inmueble_propiedad USING btree (inmueble_id);


--
-- Name: proparcon_idx_inm_prop_tipo; Type: INDEX; Schema: proparcon; Owner: -
--

CREATE INDEX proparcon_idx_inm_prop_tipo ON proparcon.inmueble_propiedad USING btree (tipo_derecho_id);


--
-- Name: proparcon_idx_inmueble_gestor; Type: INDEX; Schema: proparcon; Owner: -
--

CREATE INDEX proparcon_idx_inmueble_gestor ON proparcon.inmueble USING btree (gestor_persona_id);


--
-- Name: proparcon_idx_persona_doc; Type: INDEX; Schema: proparcon; Owner: -
--

CREATE INDEX proparcon_idx_persona_doc ON proparcon.persona USING btree (tipo_doc, doc_identidad);


--
-- Name: proparcon_idx_persona_rol; Type: INDEX; Schema: proparcon; Owner: -
--

CREATE INDEX proparcon_idx_persona_rol ON proparcon.persona_rol USING btree (persona_id, rol_id);


--
-- Name: alquiler_contrato trg_assert_contrato_tiene_titular; Type: TRIGGER; Schema: proparcon; Owner: -
--

CREATE CONSTRAINT TRIGGER trg_assert_contrato_tiene_titular AFTER UPDATE OF estado_id ON proparcon.alquiler_contrato DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION proparcon.trg_assert_contrato_tiene_inquilino_titular();


--
-- Name: alquiler_contrato trg_exclusion_alquiler_contrato_estancia; Type: TRIGGER; Schema: proparcon; Owner: -
--

CREATE TRIGGER trg_exclusion_alquiler_contrato_estancia BEFORE INSERT OR UPDATE OF estancia_id, estado_id ON proparcon.alquiler_contrato FOR EACH ROW EXECUTE FUNCTION proparcon.trg_check_exclusion_alquiler_estancia();


--
-- Name: inmueble_propiedad trg_propiedades_100; Type: TRIGGER; Schema: proparcon; Owner: -
--

CREATE TRIGGER trg_propiedades_100 AFTER INSERT OR DELETE OR UPDATE ON proparcon.inmueble_propiedad FOR EACH STATEMENT EXECUTE FUNCTION proparcon.trg_check_propiedades_100();


--
-- Name: alquiler_contrato_aval alquiler_contrato_aval_contrato_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_contrato_aval
    ADD CONSTRAINT alquiler_contrato_aval_contrato_id_fkey FOREIGN KEY (contrato_id) REFERENCES proparcon.alquiler_contrato(id) ON DELETE CASCADE;


--
-- Name: alquiler_contrato_aval alquiler_contrato_aval_entidad_bancaria_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_contrato_aval
    ADD CONSTRAINT alquiler_contrato_aval_entidad_bancaria_id_fkey FOREIGN KEY (entidad_bancaria_id) REFERENCES proparcon.entidad_bancaria(id);


--
-- Name: alquiler_contrato_aval alquiler_contrato_aval_juridica_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_contrato_aval
    ADD CONSTRAINT alquiler_contrato_aval_juridica_id_fkey FOREIGN KEY (juridica_id) REFERENCES proparcon.juridica(id);


--
-- Name: alquiler_contrato_aval alquiler_contrato_aval_persona_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_contrato_aval
    ADD CONSTRAINT alquiler_contrato_aval_persona_id_fkey FOREIGN KEY (persona_id) REFERENCES proparcon.persona(id);


--
-- Name: alquiler_contrato_aval alquiler_contrato_aval_tipo_avaliador_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_contrato_aval
    ADD CONSTRAINT alquiler_contrato_aval_tipo_avaliador_id_fkey FOREIGN KEY (tipo_avaliador_id) REFERENCES proparcon.cat_tipo_avaliador(id);


--
-- Name: alquiler_contrato alquiler_contrato_encargado_persona_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_contrato
    ADD CONSTRAINT alquiler_contrato_encargado_persona_id_fkey FOREIGN KEY (encargado_persona_id) REFERENCES proparcon.persona(id);


--
-- Name: alquiler_contrato alquiler_contrato_estado_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_contrato
    ADD CONSTRAINT alquiler_contrato_estado_id_fkey FOREIGN KEY (estado_id) REFERENCES proparcon.cat_estado_contrato(id);


--
-- Name: alquiler_contrato alquiler_contrato_estancia_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_contrato
    ADD CONSTRAINT alquiler_contrato_estancia_id_fkey FOREIGN KEY (estancia_id) REFERENCES proparcon.estancia(id) ON DELETE CASCADE;


--
-- Name: alquiler_contrato alquiler_contrato_gestor_persona_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_contrato
    ADD CONSTRAINT alquiler_contrato_gestor_persona_id_fkey FOREIGN KEY (gestor_persona_id) REFERENCES proparcon.persona(id);


--
-- Name: alquiler_contrato_inquilino alquiler_contrato_inquilino_contrato_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_contrato_inquilino
    ADD CONSTRAINT alquiler_contrato_inquilino_contrato_id_fkey FOREIGN KEY (contrato_id) REFERENCES proparcon.alquiler_contrato(id) ON DELETE CASCADE;


--
-- Name: alquiler_contrato_inquilino alquiler_contrato_inquilino_juridica_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_contrato_inquilino
    ADD CONSTRAINT alquiler_contrato_inquilino_juridica_id_fkey FOREIGN KEY (juridica_id) REFERENCES proparcon.juridica(id);


--
-- Name: alquiler_contrato_inquilino alquiler_contrato_inquilino_persona_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_contrato_inquilino
    ADD CONSTRAINT alquiler_contrato_inquilino_persona_id_fkey FOREIGN KEY (persona_id) REFERENCES proparcon.persona(id);


--
-- Name: alquiler_contrato alquiler_contrato_oferta_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_contrato
    ADD CONSTRAINT alquiler_contrato_oferta_id_fkey FOREIGN KEY (oferta_id) REFERENCES proparcon.alquiler_oferta(id);


--
-- Name: alquiler_contrato alquiler_contrato_tipo_contrato_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_contrato
    ADD CONSTRAINT alquiler_contrato_tipo_contrato_id_fkey FOREIGN KEY (tipo_contrato_id) REFERENCES proparcon.cat_tipo_contrato(id);


--
-- Name: alquiler_oferta alquiler_oferta_encargado_persona_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_oferta
    ADD CONSTRAINT alquiler_oferta_encargado_persona_id_fkey FOREIGN KEY (encargado_persona_id) REFERENCES proparcon.persona(id);


--
-- Name: alquiler_oferta alquiler_oferta_estado_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_oferta
    ADD CONSTRAINT alquiler_oferta_estado_id_fkey FOREIGN KEY (estado_id) REFERENCES proparcon.cat_estado_oferta_alquiler(id);


--
-- Name: alquiler_oferta alquiler_oferta_estancia_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_oferta
    ADD CONSTRAINT alquiler_oferta_estancia_id_fkey FOREIGN KEY (estancia_id) REFERENCES proparcon.estancia(id) ON DELETE CASCADE;


--
-- Name: alquiler_oferta alquiler_oferta_gestor_persona_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.alquiler_oferta
    ADD CONSTRAINT alquiler_oferta_gestor_persona_id_fkey FOREIGN KEY (gestor_persona_id) REFERENCES proparcon.persona(id);


--
-- Name: cat_provincia cat_provincia_pais_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.cat_provincia
    ADD CONSTRAINT cat_provincia_pais_id_fkey FOREIGN KEY (pais_id) REFERENCES proparcon.cat_pais(id);


--
-- Name: catastro catastro_direccion_catastral_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.catastro
    ADD CONSTRAINT catastro_direccion_catastral_id_fkey FOREIGN KEY (direccion_catastral_id) REFERENCES proparcon.direccion(id);


--
-- Name: catastro catastro_inmueble_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.catastro
    ADD CONSTRAINT catastro_inmueble_id_fkey FOREIGN KEY (inmueble_id) REFERENCES proparcon.inmueble(id) ON DELETE CASCADE;


--
-- Name: centro_trabajo centro_trabajo_direccion_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.centro_trabajo
    ADD CONSTRAINT centro_trabajo_direccion_id_fkey FOREIGN KEY (direccion_id) REFERENCES proparcon.direccion(id);


--
-- Name: centro_trabajo centro_trabajo_juridica_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.centro_trabajo
    ADD CONSTRAINT centro_trabajo_juridica_id_fkey FOREIGN KEY (juridica_id) REFERENCES proparcon.juridica(id) ON DELETE CASCADE;


--
-- Name: direccion direccion_pais_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.direccion
    ADD CONSTRAINT direccion_pais_id_fkey FOREIGN KEY (pais_id) REFERENCES proparcon.cat_pais(id);


--
-- Name: direccion direccion_provincia_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.direccion
    ADD CONSTRAINT direccion_provincia_id_fkey FOREIGN KEY (provincia_id) REFERENCES proparcon.cat_provincia(id);


--
-- Name: direccion direccion_tipo_via_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.direccion
    ADD CONSTRAINT direccion_tipo_via_id_fkey FOREIGN KEY (tipo_via_id) REFERENCES proparcon.cat_tipo_via(id);


--
-- Name: empleado empleado_centro_trabajo_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.empleado
    ADD CONSTRAINT empleado_centro_trabajo_id_fkey FOREIGN KEY (centro_trabajo_id) REFERENCES proparcon.centro_trabajo(id);


--
-- Name: empleado empleado_juridica_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.empleado
    ADD CONSTRAINT empleado_juridica_id_fkey FOREIGN KEY (juridica_id) REFERENCES proparcon.juridica(id) ON DELETE CASCADE;


--
-- Name: empleado empleado_persona_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.empleado
    ADD CONSTRAINT empleado_persona_id_fkey FOREIGN KEY (persona_id) REFERENCES proparcon.persona(id) ON DELETE CASCADE;


--
-- Name: estancia estancia_inmueble_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.estancia
    ADD CONSTRAINT estancia_inmueble_id_fkey FOREIGN KEY (inmueble_id) REFERENCES proparcon.inmueble(id) ON DELETE CASCADE;


--
-- Name: estancia estancia_parent_estancia_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.estancia
    ADD CONSTRAINT estancia_parent_estancia_id_fkey FOREIGN KEY (parent_estancia_id) REFERENCES proparcon.estancia(id);


--
-- Name: estancia estancia_tipo_estancia_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.estancia
    ADD CONSTRAINT estancia_tipo_estancia_id_fkey FOREIGN KEY (tipo_estancia_id) REFERENCES proparcon.cat_tipo_estancia(id);


--
-- Name: inmueble inmueble_direccion_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.inmueble
    ADD CONSTRAINT inmueble_direccion_id_fkey FOREIGN KEY (direccion_id) REFERENCES proparcon.direccion(id);


--
-- Name: inmueble inmueble_encargado_persona_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.inmueble
    ADD CONSTRAINT inmueble_encargado_persona_id_fkey FOREIGN KEY (encargado_persona_id) REFERENCES proparcon.persona(id);


--
-- Name: inmueble inmueble_gestor_persona_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.inmueble
    ADD CONSTRAINT inmueble_gestor_persona_id_fkey FOREIGN KEY (gestor_persona_id) REFERENCES proparcon.persona(id);


--
-- Name: inmueble inmueble_gestoria_juridica_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.inmueble
    ADD CONSTRAINT inmueble_gestoria_juridica_id_fkey FOREIGN KEY (gestoria_juridica_id) REFERENCES proparcon.juridica(id);


--
-- Name: inmueble_propiedad inmueble_propiedad_inmueble_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.inmueble_propiedad
    ADD CONSTRAINT inmueble_propiedad_inmueble_id_fkey FOREIGN KEY (inmueble_id) REFERENCES proparcon.inmueble(id) ON DELETE CASCADE;


--
-- Name: inmueble_propiedad inmueble_propiedad_juridica_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.inmueble_propiedad
    ADD CONSTRAINT inmueble_propiedad_juridica_id_fkey FOREIGN KEY (juridica_id) REFERENCES proparcon.juridica(id);


--
-- Name: inmueble_propiedad inmueble_propiedad_persona_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.inmueble_propiedad
    ADD CONSTRAINT inmueble_propiedad_persona_id_fkey FOREIGN KEY (persona_id) REFERENCES proparcon.persona(id);


--
-- Name: inmueble_propiedad inmueble_propiedad_tipo_derecho_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.inmueble_propiedad
    ADD CONSTRAINT inmueble_propiedad_tipo_derecho_id_fkey FOREIGN KEY (tipo_derecho_id) REFERENCES proparcon.cat_tipo_derecho_propiedad(id);


--
-- Name: inmueble inmueble_tipo_inmueble_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.inmueble
    ADD CONSTRAINT inmueble_tipo_inmueble_id_fkey FOREIGN KEY (tipo_inmueble_id) REFERENCES proparcon.cat_tipo_inmueble(id);


--
-- Name: juridica juridica_domicilio_fiscal_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.juridica
    ADD CONSTRAINT juridica_domicilio_fiscal_id_fkey FOREIGN KEY (domicilio_fiscal_id) REFERENCES proparcon.direccion(id);


--
-- Name: org_admin org_admin_juridica_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.org_admin
    ADD CONSTRAINT org_admin_juridica_id_fkey FOREIGN KEY (juridica_id) REFERENCES proparcon.juridica(id) ON DELETE CASCADE;


--
-- Name: org_admin_miembro org_admin_miembro_juridica_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.org_admin_miembro
    ADD CONSTRAINT org_admin_miembro_juridica_id_fkey FOREIGN KEY (juridica_id) REFERENCES proparcon.juridica(id);


--
-- Name: org_admin_miembro org_admin_miembro_org_admin_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.org_admin_miembro
    ADD CONSTRAINT org_admin_miembro_org_admin_id_fkey FOREIGN KEY (org_admin_id) REFERENCES proparcon.org_admin(id) ON DELETE CASCADE;


--
-- Name: org_admin_miembro org_admin_miembro_persona_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.org_admin_miembro
    ADD CONSTRAINT org_admin_miembro_persona_id_fkey FOREIGN KEY (persona_id) REFERENCES proparcon.persona(id);


--
-- Name: org_admin_miembro org_admin_miembro_representante_persona_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.org_admin_miembro
    ADD CONSTRAINT org_admin_miembro_representante_persona_id_fkey FOREIGN KEY (representante_persona_id) REFERENCES proparcon.persona(id);


--
-- Name: org_admin org_admin_tipo_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.org_admin
    ADD CONSTRAINT org_admin_tipo_id_fkey FOREIGN KEY (tipo_id) REFERENCES proparcon.org_admin_tipo(id);


--
-- Name: persona persona_direccion_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.persona
    ADD CONSTRAINT persona_direccion_id_fkey FOREIGN KEY (direccion_id) REFERENCES proparcon.direccion(id);


--
-- Name: persona_rol persona_rol_gestor_supervisor_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.persona_rol
    ADD CONSTRAINT persona_rol_gestor_supervisor_id_fkey FOREIGN KEY (gestor_supervisor_id) REFERENCES proparcon.persona(id);


--
-- Name: persona_rol persona_rol_persona_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.persona_rol
    ADD CONSTRAINT persona_rol_persona_id_fkey FOREIGN KEY (persona_id) REFERENCES proparcon.persona(id) ON DELETE CASCADE;


--
-- Name: persona_rol persona_rol_rol_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.persona_rol
    ADD CONSTRAINT persona_rol_rol_id_fkey FOREIGN KEY (rol_id) REFERENCES proparcon.cat_rol(id);


--
-- Name: registro_propiedad registro_propiedad_inmueble_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.registro_propiedad
    ADD CONSTRAINT registro_propiedad_inmueble_id_fkey FOREIGN KEY (inmueble_id) REFERENCES proparcon.inmueble(id) ON DELETE CASCADE;


--
-- Name: users users_persona_id_fkey; Type: FK CONSTRAINT; Schema: proparcon; Owner: -
--

ALTER TABLE ONLY proparcon.users
    ADD CONSTRAINT users_persona_id_fkey FOREIGN KEY (persona_id) REFERENCES proparcon.persona(id);


--
-- PostgreSQL database dump complete
--

\unrestrict GWD7xa0IJmN7jK0Hf0BbtC0jzhR68hLKrTFwfct1B5QolNcP3YNxIqFwGTee3hR

