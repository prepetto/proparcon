/**
 * ============================================================================
 * COMPONENTE: EstanciaForm.tsx
 * DISEÑO: Jerarquía Inmueble -> Estancia con sangría y cabecera única.
 * ============================================================================
 * ACTUALIZACIÓN REALIZADA:
 * ✅ DISEÑO JERÁRQUICO: Agrupación por Inmueble.
 * ✅ SANGRÍA (ml-12): El bloque de estancias se desplaza a la derecha.
 * ✅ CABECERA ÚNICA: Solo se muestra una cabecera de tabla por inmueble.
 * ============================================================================
 */

import React, { useEffect, useState } from 'react';
import { apiGet, apiPost, apiDelete, apiPatch } from '../api';

export default function EstanciaForm() {
  const [items, setItems] = useState<any[]>([]);
  const [inmuebles, setInmuebles] = useState<any[]>([]);
  const [tipos, setTipos] = useState<any[]>([]);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [form, setForm] = useState({ inmueble_id: '', tipo_estancia_id: '', nombre: '' });

  const load = async () => {
    try {
      const [dEst, dInm, dTipos] = await Promise.all([
        apiGet('/api/estancia'),
        apiGet('/api/inmueble'),
        apiGet('/api/estancia/tipos')
      ]);
      setItems(Array.isArray(dEst) ? dEst : []);
      setInmuebles(Array.isArray(dInm) ? dInm : []);
      setTipos(Array.isArray(dTipos) ? dTipos : []);
    } catch (e) { console.error("Error cargando estancias"); }
  };

  useEffect(() => { load(); }, []);

  // Agrupamiento por Inmueble
  const agrupados = items.reduce((acc: any, curr: any) => {
    const key = curr.inmueble_id;
    if (!acc[key]) acc[key] = { nombre: curr.inmueble_nombre, estancias: [] };
    acc[key].estancias.push(curr);
    return acc;
  }, {});

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const payload = { ...form, inmueble_id: parseInt(form.inmueble_id), tipo_estancia_id: parseInt(form.tipo_estancia_id) };
    if (editingId) await apiPatch(`/api/estancia/${editingId}`, payload);
    else await apiPost('/api/estancia', payload);
    setEditingId(null);
    setForm({ inmueble_id: '', tipo_estancia_id: '', nombre: '' });
    load();
  };

  return (
    <div className="p-6 bg-white rounded-lg shadow-lg">
      <h2 className="text-2xl font-bold mb-6 text-green-900 border-b pb-2">Gestión de Estancias</h2>

      {/* Formulario de Entrada */}
      <form onSubmit={handleSubmit} className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-10 bg-green-50 p-4 rounded border">
        <select value={form.inmueble_id} onChange={e => setForm({...form, inmueble_id: e.target.value})} className="p-2 border rounded" required disabled={!!editingId}>
          <option value="">Inmueble...</option>
          {inmuebles.map(i => <option key={i.id} value={i.id}>{i.nombre_publico}</option>)}
        </select>
        <select value={form.tipo_estancia_id} onChange={e => setForm({...form, tipo_estancia_id: e.target.value})} className="p-2 border rounded" required>
          <option value="">Tipo...</option>
          {tipos.map(t => <option key={t.id} value={t.id}>{t.descripcion}</option>)}
        </select>
        <input value={form.nombre} onChange={e => setForm({...form, nombre: e.target.value})} className="p-2 border rounded" placeholder="Nombre Estancia" required />
        <button type="submit" className={`p-2 rounded text-white font-bold ${editingId ? 'bg-orange-500' : 'bg-green-700'}`}>
          {editingId ? 'Actualizar' : 'Guardar'}
        </button>
      </form>

      {/* Listado con Jerarquía y Sangría */}
      <div className="space-y-10">
        {Object.keys(agrupados).map(inmId => (
          <div key={inmId}>
            {/* Cabecera de Inmueble */}
            <div className="flex items-center bg-green-800 p-3 rounded-t-lg text-white">
              <span className="text-lg font-bold">🏢 INMUEBLE: {agrupados[inmId].nombre}</span>
              <span className="ml-3 text-xs opacity-60 font-mono">(ID: {inmId})</span>
            </div>

            {/* Bloque con sangría ml-12 */}
            <div className="ml-12 border-l border-b border-r rounded-b-lg overflow-hidden">
              <table className="w-full text-sm">
                <thead className="bg-gray-100 text-[10px] uppercase text-gray-500">
                  <tr>
                    <th className="p-2 text-left w-20">ID</th>
                    <th className="p-2 text-left">Estancia</th>
                    <th className="p-2 text-left">Tipo de Estancia</th>
                    <th className="p-2 text-right">Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  {agrupados[inmId].estancias.map((est: any) => (
                    <tr key={est.id} className="border-t hover:bg-green-50">
                      <td className="p-2 font-mono text-gray-400">{est.id}</td>
                      <td className="p-2 font-bold text-gray-700">{est.nombre}</td>
                      <td className="p-2 text-green-700 font-semibold text-xs uppercase">{est.tipo_estancia_desc}</td>
                      <td className="p-2 text-right space-x-4">
                        <button onClick={() => { setEditingId(est.id); setForm({inmueble_id: est.inmueble_id.toString(), tipo_estancia_id: est.tipo_estancia_id.toString(), nombre: est.nombre}); }} className="text-blue-500 font-bold">Editar</button>
                        <button onClick={() => apiDelete(`/api/estancia/${est.id}`).then(load)} className="text-red-500">Borrar</button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}