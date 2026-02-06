/**
 * ============================================================================
 * COMPONENTE: PropiedadForm.tsx
 * DISEÑO: Jerarquía Inmueble -> Propietarios con sangría y cabecera única.
 * ============================================================================
 */
import React, { useEffect, useState } from 'react';
import { apiGet, apiPost, apiDelete, apiPatch } from '../api';

export default function PropiedadForm() {
  const [items, setItems] = useState<any[]>([]);
  const [inmuebles, setInmuebles] = useState<any[]>([]);
  const [personas, setPersonas] = useState<any[]>([]);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [form, setForm] = useState({ inmueble_id: '', persona_id: '', tipo_derecho_id: '1', porcentaje: '100' });

  const load = async () => {
    const [dProp, dInm, dPers] = await Promise.all([
      apiGet('/api/propiedad'), apiGet('/api/inmueble'), apiGet('/api/persona')
    ]);
    setItems(Array.isArray(dProp) ? dProp : []);
    setInmuebles(Array.isArray(dInm) ? dInm : []);
    setPersonas(Array.isArray(dPers) ? dPers : []);
  };

  useEffect(() => { load(); }, []);

  const agrupados = items.reduce((acc: any, curr: any) => {
    const key = curr.inmueble_id;
    if (!acc[key]) acc[key] = { nombre: curr.inmueble_nombre, propietarios: [] };
    acc[key].propietarios.push(curr);
    return acc;
  }, {});

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const payload = { 
      inmueble_id: parseInt(form.inmueble_id), persona_id: parseInt(form.persona_id), 
      tipo_derecho_id: parseInt(form.tipo_derecho_id), porcentaje: parseFloat(form.porcentaje) 
    };
    if (editingId) await apiPatch(`/api/propiedad/${editingId}`, payload);
    else await apiPost('/api/propiedad', payload);
    setEditingId(null);
    setForm({ inmueble_id: '', persona_id: '', tipo_derecho_id: '1', porcentaje: '100' });
    load();
  };

  return (
    <div className="p-6 bg-white rounded-lg shadow">
      <h2 className="text-2xl font-bold mb-6 text-blue-900 border-b pb-2">Gestión de Propiedades</h2>

      <form onSubmit={handleSubmit} className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-10 bg-blue-50 p-4 rounded-md border">
        <select value={form.inmueble_id} onChange={e => setForm({...form, inmueble_id: e.target.value})} className="p-2 border rounded" required disabled={!!editingId}>
          <option value="">Inmueble...</option>
          {inmuebles.map(i => <option key={i.id} value={i.id}>{i.nombre_publico}</option>)}
        </select>
        <select value={form.persona_id} onChange={e => setForm({...form, persona_id: e.target.value})} className="p-2 border rounded" required>
          <option value="">Titular...</option>
          {personas.map(p => <option key={p.id} value={p.id}>{p.nombre} {p.apellido1}</option>)}
        </select>
        <input type="number" step="0.01" value={form.porcentaje} onChange={e => setForm({...form, porcentaje: e.target.value})} className="p-2 border rounded" placeholder="%" required />
        <button type="submit" className={`p-2 rounded text-white font-bold ${editingId ? 'bg-orange-500' : 'bg-blue-600'}`}>{editingId ? 'Actualizar' : 'Asignar'}</button>
      </form>

      <div className="space-y-8">
        {Object.keys(agrupados).map(inmId => (
          <div key={inmId}>
            <div className="flex items-center bg-blue-900 p-3 rounded-t-lg text-white">
              <span className="text-lg font-bold">🏢 INMUEBLE: {agrupados[inmId].nombre}</span>
              <span className="ml-3 text-xs opacity-60">(ID: {inmId})</span>
            </div>
            <div className="ml-12 border-l border-b border-r rounded-b-lg overflow-hidden">
              <table className="w-full text-sm">
                <thead className="bg-gray-100 text-[10px] uppercase text-gray-500">
                  <tr>
                    <th className="p-2 text-left">Titular / Doc.</th>
                    <th className="p-2 text-center">Derecho</th>
                    <th className="p-2 text-center">% Participación</th>
                    <th className="p-2 text-right">Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  {agrupados[inmId].propietarios.map((p: any) => (
                    <tr key={p.id} className="border-t hover:bg-blue-50">
                      <td className="p-2">
                        <div className="font-bold">{p.titular_nombre}</div>
                        <div className="text-[10px] text-gray-400 font-mono">{p.titular_doc}</div>
                      </td>
                      <td className="p-2 text-center text-xs font-semibold">{p.derecho_desc}</td>
                      <td className="p-2 text-center font-bold text-blue-700">{p.porcentaje}%</td>
                      <td className="p-2 text-right space-x-4">
                        <button onClick={() => { setEditingId(p.id); setForm({inmueble_id: p.inmueble_id.toString(), persona_id: p.persona_id.toString(), porcentaje: p.porcentaje.toString(), tipo_derecho_id: p.tipo_derecho_id.toString()}); }} className="text-blue-500 font-bold">Editar</button>
                        <button onClick={() => apiDelete(`/api/propiedad/${p.id}`).then(load)} className="text-red-500">Borrar</button>
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