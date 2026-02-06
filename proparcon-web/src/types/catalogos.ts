// src/types/catalogos.ts
// =============================================================================
// Tipos para Catálogos (PROPARCON Web)
// =============================================================================
// Alineación con la arquitectura actual (frontend):
// - La UI trabaja con `nombre` (texto visible) + `codigo` opcional.
// - El service (catalogosService.ts) traduce esos inputs a la forma de la API:
//     * Catálogos genéricos: { codigo, descripcion }
//     * País:               { iso2, nombre }
//     * Provincia:          { pais_id, nombre }
// - En UI, el listado se normaliza para mostrar SIEMPRE `descripcion`.
// =============================================================================

export type CatalogoKey =
  | "estado_oferta"
  | "estado_contrato"
  | "tipo_inmueble"
  | "tipo_via"
  | "pais"
  | "rol"
  | "tipo_avaliador"
  | "tipo_contrato"
  | "tipo_derecho_propiedad"
  | "tipo_estancia"
  | "tipo_ingreso"
  | "provincia";

/**
 * Forma normalizada para render en UI.
 * `descripcion` es el texto que se enseña (venga de descripcion/nombre en la API).
 */
export interface CatalogoItem {
  id: number;

  // Muchos catálogos tienen codigo NOT NULL; otros (pais/provincia) no.
  // En UI se modela como opcional (null cuando no aplica).
  codigo: string | null;

  // Texto principal para UI.
  descripcion: string;

  // Alias legacy: algunas pantallas antiguas usan `nombre`.
  // Mantenerlo evita casts y facilita la transición.
  nombre?: string | null;

  // Jerárquicos
  pais_id?: number;

  // Extras opcionales que algunos catálogos pueden devolver
  activo?: boolean | number | null;
  alquilable?: boolean;
  es_raiz?: boolean;
}

/**
 * Payload que la UI entrega al service para crear.
 * (El service lo transforma al payload de API correcto por catálogo.)
 */
export interface CatalogoCreateInput {
  nombre: string;
  codigo?: string | null;
  pais_id?: number;
}

/**
 * Payload que la UI entrega al service para actualizar (PATCH).
 * Importante: campos opcionales para permitir PATCH parcial.
 */
export interface CatalogoUpdateInput {
  nombre?: string;
  codigo?: string | null;
  pais_id?: number;
}

// ----------------------------------------------------------------------------
// Helpers UI
// ----------------------------------------------------------------------------

/**
 * Devuelve el texto que se debe mostrar en UI para un item.
 * Prioriza `descripcion` y usa `nombre` como fallback.
 */
export function getCatalogoLabel(it: Pick<CatalogoItem, "descripcion" | "nombre">): string {
  const v = (it.descripcion ?? it.nombre ?? "").toString().trim();
  return v.length ? v : "(sin descripción)";
}
