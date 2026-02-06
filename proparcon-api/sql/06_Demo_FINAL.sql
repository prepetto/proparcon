-- ============================================================
-- PROPARCON · 06_Demo_FINAL.sql
-- Crea/actualiza el procedimiento sp_demo_final(...)
-- Objetivo:
--   - Cargar/recargar la demo base (inmueble → estancia → oferta → contrato)
--   - Idempotente (no duplica si existe solape)
--   - Contrato se inserta INACTIVO, se asocia un inquilino y se activa
-- Uso típico:
--   CALL proparcon.sp_demo_final();  -- usa parámetros por defecto
--   CALL proparcon.sp_demo_final('2025-11-01', NULL, 850, '2025-12-01', NULL, 900);
-- Requisitos:
--   - Esquema proparcon con tablas: inmueble, estancia, alquiler_oferta, alquiler_contrato
--   - (Opcional) Tablas puente: alquiler_contrato_inquilino o alquiler_contrato_persona
--   - Triggers de exclusión/validación compatibles con que primero se asocia inquilino y luego se activa el contrato
-- Compatibilidad: PostgreSQL 14+
-- ============================================================

SET search_path TO proparcon, public;

CREATE OR REPLACE PROCEDURE proparcon.sp_demo_final(
  IN p_oferta_inicio   date    DEFAULT DATE '2025-11-01',  -- inicio OFERTA demo
  IN p_oferta_fin      date    DEFAULT NULL,               -- fin OFERTA demo (NULL = abierta)
  IN p_oferta_renta    numeric DEFAULT 850,                 -- renta mensual oferta
  IN p_contrato_inicio date    DEFAULT DATE '2025-12-01',   -- inicio CONTRATO demo
  IN p_contrato_fin    date    DEFAULT NULL,                -- fin CONTRATO demo (NULL = abierto)
  IN p_contrato_renta  numeric DEFAULT 900                  -- renta mensual contrato
)
LANGUAGE plpgsql
AS $$
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
$$;
