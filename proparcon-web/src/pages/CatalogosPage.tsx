import { useEffect, useMemo, useState } from "react";
import {
  listarCatalogo,
  crearCatalogo,
  actualizarCatalogo,
  borrarCatalogo,
} from "../services/catalogosService";
import type { CatalogoItem, CatalogoKey } from "../types/catalogos";

const CATALOGOS = [
  "estado_oferta",
  "estado_contrato",
  "tipo_inmueble",
  "tipo_via",
  "pais",
  "rol",
  "tipo_avaliador",
  "tipo_contrato",
  "tipo_derecho_propiedad",
  "tipo_estancia",
  "tipo_ingreso",
  "provincia",
] as const satisfies readonly CatalogoKey[];

export default function CatalogosPage() {
  const [catalogo, setCatalogo] = useState<CatalogoKey>(CATALOGOS[0]);
  const [items, setItems] = useState<CatalogoItem[]>([]);

  // Para provincia: selector de país
  const [paises, setPaises] = useState<CatalogoItem[]>([]);
  const [paisId, setPaisId] = useState<number | null>(null);

  const [descripcion, setDescripcion] = useState("");
  const [codigo, setCodigo] = useState("");

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Edición inline
  const [editingId, setEditingId] = useState<number | null>(null);
  const [editDescripcion, setEditDescripcion] = useState("");
  const [editCodigo, setEditCodigo] = useState("");

  const isProvincia = catalogo === "provincia";

  const canSubmitCreate = useMemo(() => {
    if (isProvincia && typeof paisId !== "number") return false;
    return descripcion.trim().length > 0 && codigo.trim().length > 0;
  }, [descripcion, codigo, isProvincia, paisId]);

  async function cargarPaisesSiHaceFalta() {
    if (!isProvincia) return;
    try {
      const data = await listarCatalogo("pais");
      setPaises(data);
    } catch {
      // Silencioso: si no carga, ya verás el error al intentar listar provincia.
    }
  }

  async function cargar() {
    setLoading(true);
    setError(null);
    try {
      const data = isProvincia
        ? await listarCatalogo("provincia", { pais_id: typeof paisId === "number" ? paisId : undefined })
        : await listarCatalogo(catalogo);

      setItems(data);
    } catch (e: any) {
      setError(e?.message || "Error cargando catálogo");
      setItems([]);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    // Al cambiar de catálogo, resetea edición y datos dependientes
    setItems([]);
    setError(null);
    setEditingId(null);
    setEditDescripcion("");
    setEditCodigo("");

    if (catalogo !== "provincia") {
      setPaisId(null);
    }

    // Carga países si procede (para dropdown) y luego carga el catálogo
    (async () => {
      await cargarPaisesSiHaceFalta();
      await cargar();
    })();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [catalogo]);

  // Cuando cambia paisId y estamos en provincia, recargar
  useEffect(() => {
    if (!isProvincia) return;
    cargar();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [paisId]);

  async function crear() {
    if (!canSubmitCreate || loading) return;

    const c = codigo.trim();
    const d = descripcion.trim();

    setLoading(true);
    setError(null);
    try {
      await crearCatalogo(catalogo, {
        nombre: d,
        codigo: c,
        ...(isProvincia && typeof paisId === "number" ? { pais_id: paisId } : {}),
      });

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
    setEditDescripcion(it.descripcion ?? it.nombre ?? "");
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

    if (!c) return setError("El código no puede estar vacío.");
    if (!d) return setError("La descripción no puede estar vacía.");

    setLoading(true);
    setError(null);
    try {
      await actualizarCatalogo(catalogo, id, {
        nombre: d,
        codigo: c,
        ...(isProvincia && typeof paisId === "number" ? { pais_id: paisId } : {}),
      });

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
      await borrarCatalogo(
        catalogo,
        id,
        isProvincia && typeof paisId === "number" ? { pais_id: paisId } : undefined
      );
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
            setCatalogo(e.target.value as CatalogoKey);
          }}
          disabled={loading}
        >
          {CATALOGOS.map((c) => (
            <option key={c} value={c}>
              {c}
            </option>
          ))}
        </select>

        {isProvincia && (
          <select
            className="border p-2"
            value={paisId ?? ""}
            onChange={(e) => setPaisId(e.target.value ? Number(e.target.value) : null)}
            disabled={loading}
          >
            <option value="">Selecciona país…</option>
            {paises.map((p) => (
              <option key={p.id} value={p.id}>
                {(p.descripcion ?? p.nombre ?? "").toString()}
              </option>
            ))}
          </select>
        )}

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
          title={isProvincia && typeof paisId !== "number" ? "Selecciona un país primero" : undefined}
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
                    it.descripcion ?? it.nombre ?? ""
                  )}
                </td>

                <td className="border p-2">
                  <div className="flex gap-2">
                    {!isEditing ? (
                      <>
                        <button className="text-blue-700" onClick={() => empezarEdicion(it)} disabled={loading}>
                          Editar
                        </button>
                        <button className="text-red-700" onClick={() => borrar(it.id)} disabled={loading}>
                          Borrar
                        </button>
                      </>
                    ) : (
                      <>
                        <button className="text-green-700" onClick={() => guardarEdicion(it.id)} disabled={loading}>
                          Guardar
                        </button>
                        <button className="text-gray-700" onClick={cancelarEdicion} disabled={loading}>
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
