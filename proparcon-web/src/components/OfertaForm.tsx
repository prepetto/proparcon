/**
 * ============================================================================
 * COMPONENTE: OfertaForm.tsx
 * DISEÑO: Jerarquía Inmueble -> Ofertas con sangría y cabecera única.
 * ============================================================================
 * ACTUALIZACIÓN REALIZADA:
 * ✅ REINTEGRACIÓN CREATE/UPDATE: Formulario funcional en la parte superior.
 * ✅ DISEÑO JERÁRQUICO: Agrupación por Inmueble y sangría ml-12.
 * ✅ CABECERA ÚNICA: Solo una fila de etiquetas por cada inmueble.
 * ============================================================================
 */
import React, { useEffect, useState } from 'react';
import { apiGet, apiPost, apiDelete, apiPatch } from '../api';

export default function OfertaForm() {
  const [items, setItems] = useState<any[]>([]);
  const [estancias, setEstancias] = useState<any[]>([]);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [form, setForm] = useState({
    estancia_id: '',
    renta_mensual: '',
    fecha_alta: new Date().toISOString().split('T')[0],
    estado_id: 1
  });

  const load = async () => {
    const [dOff, dEst] = await Promise.all([apiGet('/api/oferta'), apiGet('/api/estancia')]);
    setItems(Array.isArray(dOff) ? dOff : []);
    setEstancias(Array.isArray(dEst) ? dEst : []);
  };

  useEffect(() => { load(); }, []);

  const agrupados = items.reduce((acc: any, curr: any) => {
    const key = curr.inmueble_id;
    if (!acc[key]) acc[key] = { nombre: curr.inmueble_nombre, ofertas: [] };
    acc[key].ofertas.push(curr);
    return acc;
  }, {});

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const payload = {
      ...form,
      estancia_id: parseInt(form.estancia_id),
      renta_mensual: parseFloat(form.renta_mensual)
    };
    if (editingId) await apiPatch(`/api/oferta/${editingId}`, payload);
    else await apiPost('/api/oferta', payload);
    setEditingId(null);
    setForm({ estancia_id: '', renta_mensual: '', fecha_alta: new Date().toISOString().split('T')[0], estado_id: 1 });
    load();
  };

  const handleEdit = (o: any) => {
    setEditingId(o.id);
    setForm({
      estancia_id: o.estancia_id.toString(),
      renta_mensual: o.renta_mensual.toString(),
      fecha_alta: o.fecha_alta,
      estado_id: o.estado_id
    });
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  return (
    <div className="p-6 bg-white rounded-lg shadow-lg">
      <h2 className="text-2xl font-bold mb-6 text-orange-900 border-b pb-2">
        {editingId ? '🛠️ Editar Oferta' : '📢 Publicar Oferta Comercial'}
      </h2>

      {/* Formulario de Registro/Edición */}
      <form onSubmit={handleSubmit} className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-10 bg-orange-50 p-4 rounded-md border border-orange-200">
        <select value={form.estancia_id} onChange={e => setForm({...form, estancia_id: e.target.value})} className="p-2 border rounded" required disabled={!!editingId}>
          <option value="">Seleccione Estancia...</option>
          {estancias.map(est => (
            <option key={est.id} value={est.id}>{est.inmueble_nombre} - {est.nombre}</option>
          ))}
        </select>
        <input type="number" step="0.01" value={form.renta_mensual} onChange={e => setForm({...form, renta_mensual: e.target.value})} className="p-2 border rounded" placeholder="Renta Mensual (€)" required />
        <input type="date" value={form.fecha_alta} onChange={e => setForm({...form, fecha_alta: e.target.value})} className="p-2 border rounded" required />
        <button type="submit" className={`p-2 rounded text-white font-bold transition-colors ${editingId ? 'bg-orange-600' : 'bg-orange-800 hover:bg-orange-900'}`}>
          {editingId ? 'Actualizar' : 'Publicar'}
        </button>
      </form>

      {/* Listado Jerárquico con Sangría */}
      <div className="space-y-10">
        {Object.keys(agrupados).map(inmId => (
          <div key={inmId}>
            <div className="flex items-center bg-orange-900 p-3 rounded-t-lg text-white">
              <span className="text-lg font-bold">🏢 INMUEBLE: {agrupados[inmId].nombre}</span>
              <span className="ml-3 text-xs opacity-60">(ID: {inmId})</span>
            </div>

            <div className="ml-12 border-l border-b border-r rounded-b-lg overflow-hidden">
              <table className="w-full text-sm">
                <thead className="bg-gray-100 text-[10px] uppercase text-gray-500">
                  <tr>
                    <th className="p-2 text-left">Estancia</th>
                    <th className="p-2 text-center">Renta Mensual</th>
                    <th className="p-2 text-center">Fecha Alta</th>
                    <th className="p-2 text-right">Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  {agrupados[inmId].ofertas.map((o: any) => (
                    <tr key={o.id} className="border-t hover:bg-orange-50">
                      <td className="p-2 font-bold text-gray-700">{o.estancia_nombre}</td>
                      <td className="p-2 text-center font-bold text-orange-700">{o.renta_mensual} €</td>
                      <td className="p-2 text-center text-xs text-gray-500">{o.fecha_alta}</td>
                      <td className="p-2 text-right space-x-4">
                        <button onClick={() => handleEdit(o)} className="text-blue-600 font-bold hover:underline">Editar</button>
                        <button onClick={() => apiDelete(`/api/oferta/${o.id}`).then(load)} className="text-red-500 hover:underline">Borrar</button>
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