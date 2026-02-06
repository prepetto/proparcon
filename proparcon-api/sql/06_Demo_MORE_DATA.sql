-- ============================================================
-- PROPARCON · 06_Demo_MORE_DATA.sql (versión a prueba de exclusión)
-- Procedimiento: proparcon.sp_demo_more_data()
-- ------------------------------------------------------------
-- Objetivo
--   Generar escenarios extra de demo sin violar el trigger de exclusión
--   a nivel de INMUEBLE:
--     A) Inmueble libre → OFERTA futura (2026-01-10)
--     B) Inmueble libre → CONTRATO futuro (2026-02-01, activo con inquilino)
-- Diseño
--   - No crea inmuebles (evita NOT NULL en tipo_inmueble_id).
--   - Crea estancias (o reutiliza una si hay NOT NULL adicionales).
--   - Idempotente y con guardas a NIVEL INMUEBLE + manejo de excepciones.
--   - Si no hay inmueble libre para una fecha, omite el escenario con NOTICE.
-- Uso
--   CALL proparcon.sp_demo_more_data();
-- ============================================================

SET search_path TO proparcon, public;

CREATE OR REPLACE PROCEDURE proparcon.sp_demo_more_data()
LANGUAGE plpgsql
AS $$
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
$$;
