/**
 * =============================================================================
 * CatalogosPage.tsx — Administración CRUD genérica de Catálogos (CAT)
 * =============================================================================
 * Funcionalidad:
 *  - Lista catálogo (GET)
 *  - Crea registro (POST)
 *  - Edita registro (PATCH)
 *  - Borra registro (DELETE)
 *
 * Alineación con BD/API PROPARCON (DDL):
 *  - Columnas: id, codigo, descripcion
 *  - El frontend debe usar "descripcion" (no "nombre").
 * =============================================================================
 */

import { useEffect, useMemo, useState } from "react";
import {
  listarCatalogo,
  crearCatalogo,
  actualizarCatalogo,
  borrarCatalogo,
} from "../services/catalogosService";
import type { CatalogoItem } from "../types/catalogos";

const CATALOGOS = ["estado_oferta", "estado_contrato", "tipo_inmueble", "tipo_via"];

export default function CatalogosPage() {
  const [catalogo, setCatalogo] = useState(CATALOGOS[0]);
  const [items, setItems] = useState<CatalogoItem[]>([]);

  const [descripcion, setDescripcion] = useState("");
  const [codigo, setCodigo] = useState("");

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Edición inline
  const [editingId, setEditingId] = useState<number | null>(null);
  const [editDescripcion, setEditDescripcion] = useState("");
  const [editCodigo, setEditCodigo] = useState("");

  const canSubmitCreate = useMemo(
    () => descripcion.trim().length > 0 && codigo.trim().length > 0,
    [descripcion, codigo]
  );

  async function cargar() {
    setLoading(true);
    setError(null);
    try {
      const data = await listarCatalogo(catalogo);
      setItems(data);
    } catch (e: any) {
      setError(e?.message || "Error cargando catálogo");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    cargar();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [catalogo]);

  async function crear() {
    if (!canSubmitCreate || loading) return;

    const c = codigo.trim();
    const d = descripcion.trim();

    setLoading(true);
    setError(null);
    try {
      await crearCatalogo(catalogo, { codigo: c, descripcion: d });
      setDescripcion("");
      setCodigo("");
      await cargar();
    } catch (e: any) {
      setError(e?.message || "Error creando registro");
    } finally {
      setLoading(false);
    }
  }

  function empezarEdicion(it: CatalogoItem) {
    setEditingId(it.id);
    setEditDescripcion(it.descripcion ?? "");
    setEditCodigo(it.codigo ?? "");
    setError(null);
  }

  function cancelarEdicion() {
    setEditingId(null);
    setEditDescripcion("");
    setEditCodigo("");
  }

  async function guardarEdicion(id: number) {
    if (loading) return;

    const d = editDescripcion.trim();
    const c = editCodigo.trim();

    if (!c) {
      setError("El código no puede estar vacío.");
      return;
    }
    if (!d) {
      setError("La descripción no puede estar vacía.");
      return;
    }

    setLoading(true);
    setError(null);
    try {
      await actualizarCatalogo(catalogo, id, { codigo: c, descripcion: d });
      cancelarEdicion();
      await cargar();
    } catch (e: any) {
      setError(e?.message || "Error actualizando registro");
    } finally {
      setLoading(false);
    }
  }

  async function borrar(id: number) {
    if (loading) return;
    if (!confirm("¿Eliminar registro?")) return;

    setLoading(true);
    setError(null);
    try {
      await borrarCatalogo(catalogo, id);
      await cargar();
    } catch (e: any) {
      setError(e?.message || "Error borrando registro");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="p-4 space-y-4">
      <div>
        <h1 className="text-xl font-bold">Administración · Catálogos</h1>
        <p className="text-sm text-gray-600">
          Catálogo activo: <span className="font-mono">{catalogo}</span>
        </p>
      </div>

      <div className="flex flex-wrap items-center gap-2">
        <select
          className="border p-2"
          value={catalogo}
          onChange={(e) => {
            cancelarEdicion();
            setCatalogo(e.target.value);
          }}
          disabled={loading}
        >
          {CATALOGOS.map((c) => (
            <option key={c} value={c}>
              {c}
            </option>
          ))}
        </select>

        {loading && <span className="text-sm text-gray-600">Cargando…</span>}
        {error && <span className="text-sm text-red-700">{error}</span>}
      </div>

      <div className="flex flex-wrap gap-2">
        <input
          className="border p-2"
          placeholder="Código"
          value={codigo}
          onChange={(e) => setCodigo(e.target.value)}
          disabled={loading}
        />
        <input
          className="border p-2 flex-1 min-w-[240px]"
          placeholder="Descripción"
          value={descripcion}
          onChange={(e) => setDescripcion(e.target.value)}
          disabled={loading}
        />
        <button
          className="bg-blue-600 text-white px-4 py-2 disabled:opacity-50"
          onClick={crear}
          disabled={!canSubmitCreate || loading}
        >
          Añadir
        </button>
      </div>

      <table className="w-full border bg-white">
        <thead>
          <tr className="bg-gray-100">
            <th className="border p-2 text-left">ID</th>
            <th className="border p-2 text-left">Código</th>
            <th className="border p-2 text-left">Descripción</th>
            <th className="border p-2 text-left">Acciones</th>
          </tr>
        </thead>

        <tbody>
          {items.map((it) => {
            const isEditing = editingId === it.id;

            return (
              <tr key={it.id}>
                <td className="border p-2">{it.id}</td>

                <td className="border p-2">
                  {isEditing ? (
                    <input
                      className="border p-2 w-full"
                      value={editCodigo}
                      onChange={(e) => setEditCodigo(e.target.value)}
                      disabled={loading}
                    />
                  ) : (
                    it.codigo ?? ""
                  )}
                </td>

                <td className="border p-2">
                  {isEditing ? (
                    <input
                      className="border p-2 w-full"
                      value={editDescripcion}
                      onChange={(e) => setEditDescripcion(e.target.value)}
                      disabled={loading}
                    />
                  ) : (
                    it.descripcion ?? ""
                  )}
                </td>

                <td className="border p-2">
                  <div className="flex gap-2">
                    {!isEditing ? (
                      <>
                        <button
                          className="text-blue-700"
                          onClick={() => empezarEdicion(it)}
                          disabled={loading}
                        >
                          Editar
                        </button>
                        <button
                          className="text-red-700"
                          onClick={() => borrar(it.id)}
                          disabled={loading}
                        >
                          Borrar
                        </button>
                      </>
                    ) : (
                      <>
                        <button
                          className="text-green-700"
                          onClick={() => guardarEdicion(it.id)}
                          disabled={loading}
                        >
                          Guardar
                        </button>
                        <button
                          className="text-gray-700"
                          onClick={cancelarEdicion}
                          disabled={loading}
                        >
                          Cancelar
                        </button>
                      </>
                    )}
                  </div>
                </td>
              </tr>
            );
          })}

          {!loading && items.length === 0 && (
            <tr>
              <td className="border p-2 text-gray-600" colSpan={4}>
                Sin registros.
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}

