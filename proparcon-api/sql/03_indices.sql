CREATE INDEX proparcon_idx_persona_doc           ON proparcon.persona (tipo_doc, doc_identidad);
CREATE INDEX proparcon_idx_persona_rol           ON proparcon.persona_rol (persona_id, rol_id);
CREATE INDEX proparcon_idx_inmueble_gestor       ON proparcon.inmueble (gestor_persona_id);
CREATE INDEX proparcon_idx_estancia_inmueble     ON proparcon.estancia (inmueble_id);
CREATE INDEX proparcon_idx_inm_prop_inmueble     ON proparcon.inmueble_propiedad(inmueble_id);
CREATE INDEX proparcon_idx_inm_prop_tipo         ON proparcon.inmueble_propiedad(tipo_derecho_id);
CREATE INDEX proparcon_idx_alq_oferta_estancia   ON proparcon.alquiler_oferta(estancia_id);
CREATE INDEX proparcon_idx_alq_contrato_estancia ON proparcon.alquiler_contrato(estancia_id);
CREATE INDEX proparcon_idx_alq_contrato_activo   ON proparcon.alquiler_contrato(activo);
