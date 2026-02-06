/**
 * -----------------------------------------------------------------------------
 * catalogosService.ts
 * -----------------------------------------------------------------------------
 * Objetivo:
 *  - Consumir la API de Catálogos usando apiGet/apiPost/apiPatch/apiDelete.
 *  - Normalizar la respuesta a un tipo único de UI (CatalogoItem).
 *
 * Problema resuelto en esta versión:
 *  - Tu apiGet() acepta SOLO 1 argumento (url).
 *  - Por tanto, NO podemos hacer apiGet(url, { params: ... }).
 *  - Construimos el querystring manualmente en la URL.
 *
 * Compatibilidad UI/API:
 *  - En BD/API muchas tablas usan { codigo, descripcion }.
 *  - En UI se venía usando { nombre, codigo }.
 *  - Este servicio mapea:
 *      - descripcion -> nombre (para UI)
 *      - y SIEMPRE rellena descripcion (para TypeScript)
 * -----------------------------------------------------------------------------
 */

import { apiDelete, apiGet, apiPatch, apiPost } from "../api";
import type { CatalogoItem, CatalogoKey } from "../types/catalogos";

// -----------------------------------------------------------------------------
// Tipos internos (respuesta estándar de API para catálogos)
// -----------------------------------------------------------------------------
type ApiCatalogoRow = {
  id: number;
  // La mayoría de catálogos
  codigo?: string | null;
  descripcion?: string;

  // Especial: pais
  iso2?: string;
  nombre?: string;

  // Extras opcionales
  activo?: boolean | number | null;

  // Jerárquicos
  pais_id?: number;

  // Especial: tipo_estancia
  alquilable?: boolean;
  es_raiz?: boolean;
};

// -----------------------------------------------------------------------------
// Helper: construir URL con querystring (porque apiGet solo acepta 1 argumento)
// -----------------------------------------------------------------------------
function withQuery(url: string, params?: Record<string, string | number | boolean | null | undefined>): string {
  if (!params) return url;

  const qs = new URLSearchParams();
  for (const [k, v] of Object.entries(params)) {
    if (v === undefined || v === null) continue;
    qs.set(k, String(v));
  }

  const query = qs.toString();
  if (!query) return url;

  return url.includes("?") ? `${url}&${query}` : `${url}?${query}`;
}

// -----------------------------------------------------------------------------
// Helper: API -> UI (normalización)
// -----------------------------------------------------------------------------
function mapApiRowToUi(row: ApiCatalogoRow): CatalogoItem {
  /**
   * Normalización API -> UI:
   * - Catálogos simples y tipo_estancia: usan {codigo, descripcion}
   * - provincia: usa {pais_id, nombre}
   * - pais: usa {iso2, nombre}
   *
   * Nota: mantenemos `nombre` como alias opcional si el tipo CatalogoItem lo permite.
   * Si no lo permite, TypeScript lo marcaría; por eso lo añadimos con spread a `any`.
   */
  const codigo = (row.codigo ?? row.iso2 ?? null) as string | null;
  const desc = (row.descripcion ?? row.nombre ?? "") as string;

  const base: CatalogoItem = {
    id: row.id,
    codigo,
    descripcion: desc,
    // Extras opcionales
    activo: row.activo ?? null,
    pais_id: row.pais_id,
    alquilable: row.alquilable,
    es_raiz: row.es_raiz,
  } as CatalogoItem;

  // Alias retrocompatible (sin ensuciar tipos si CatalogoItem no lo declara)
  (base as any).nombre = desc;

  return base;
}

// -----------------------------------------------------------------------------
// Helper: UI -> API (payload)
// -----------------------------------------------------------------------------
function buildApiPayloadCreate(
  catalogo: CatalogoKey,
  input: { nombre: string; codigo?: string | null; pais_id?: number }
): Record<string, unknown> {
  const nombre = input.nombre.trim();
  const codigo = input.codigo ?? null;

  // Casos especiales según backend (catalogos.py)
  if (catalogo === "pais") {
    return {
      iso2: codigo,
      nombre,
    };
  }

  if (catalogo === "provincia") {
    return {
      pais_id: input.pais_id,
      nombre,
    };
  }

  // Catálogos simples y tipo_estancia
  return {
    codigo,
    descripcion: nombre,
  };
}

function buildApiPayloadPatch(
  catalogo: CatalogoKey,
  input: { nombre?: string; codigo?: string | null; pais_id?: number }
): Record<string, unknown> {
  const payload: Record<string, unknown> = {};

  // PATCH: solo enviamos lo que venga definido (no forzamos null)
  if (input.codigo !== undefined) {
    if (catalogo === "pais") payload.iso2 = input.codigo;
    else if (catalogo !== "provincia") payload.codigo = input.codigo;
    // provincia no tiene codigo
  }

  if (input.nombre !== undefined) {
    const nombre = input.nombre.trim();
    if (catalogo === "pais") payload.nombre = nombre;
    else if (catalogo === "provincia") payload.nombre = nombre;
    else payload.descripcion = nombre;
  }

  if (catalogo === "provincia" && typeof input.pais_id === "number") {
    payload.pais_id = input.pais_id;
  }

  return payload;
}

// -----------------------------------------------------------------------------
// API pública: LISTAR
// -----------------------------------------------------------------------------
export async function listarCatalogo(
  catalogo: CatalogoKey,
  opts?: { pais_id?: number }
): Promise<CatalogoItem[]> {
  /**
   * Regla de negocio:
   * - provincia SIEMPRE filtrado por pais_id.
   * - si no hay país seleccionado, devolvemos [] para no romper la UI.
   */
  if (catalogo === "provincia" && typeof opts?.pais_id !== "number") {
    return [];
  }

  const urlBase = `/api/catalogos/${catalogo}`;

  // Si hay filtros (ej: provincia)
  const url = catalogo === "provincia"
    ? withQuery(urlBase, { pais_id: opts?.pais_id })
    : urlBase;

  const rows = await apiGet<ApiCatalogoRow[]>(url);
  return rows.map(mapApiRowToUi);
}

// -----------------------------------------------------------------------------
// API pública: CREAR
// -----------------------------------------------------------------------------
export async function crearCatalogo(
  catalogo: CatalogoKey,
  data: { nombre: string; codigo?: string | null; pais_id?: number }
): Promise<CatalogoItem> {
  const payload = buildApiPayloadCreate(catalogo, data);

  const created = await apiPost<ApiCatalogoRow>(`/api/catalogos/${catalogo}`, payload);
  return mapApiRowToUi(created);
}

// -----------------------------------------------------------------------------
// API pública: ACTUALIZAR
// -----------------------------------------------------------------------------
export async function actualizarCatalogo(
  catalogo: CatalogoKey,
  id: number,
  data: { nombre?: string; codigo?: string | null; pais_id?: number }
): Promise<CatalogoItem> {
  const payload = buildApiPayloadPatch(catalogo, data);

  const updated = await apiPatch<ApiCatalogoRow>(`/api/catalogos/${catalogo}/${id}`, payload);
  return mapApiRowToUi(updated);
}

// -----------------------------------------------------------------------------
// API pública: BORRAR
// -----------------------------------------------------------------------------
export async function borrarCatalogo(
  catalogo: CatalogoKey,
  id: number,
  opts?: { pais_id?: number }
): Promise<void> {
  /**
   * Regla:
   * - provincia delete requiere pais_id (según la API que te propuse).
   * - lo pasamos en querystring.
   */
  const base = `/api/catalogos/${catalogo}/${id}`;
  const url =
    catalogo === "provincia"
      ? withQuery(base, { pais_id: opts?.pais_id })
      : base;

  await apiDelete(url);
}
