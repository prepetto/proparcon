/**
 * ============================================================================
 * COMPONENTE: PersonaForm.tsx
 * PROYECTO: PROPARCON Web Client
 * ============================================================================
 * ACTUALIZACIÓN: 
 * ✅ Implementada funcionalidad de Actualización (UPDATE/PATCH).
 * ✅ Gestión de estado para conmutar entre Creación y Edición.
 * ✅ Alineación de nombres de campo con la API de Postman.
 * ============================================================================
 */
import React, { useEffect, useState } from 'react';
import { apiGet, apiPost, apiDelete, apiPatch } from '../api';

export default function PersonaForm() {
  const [items, setItems] = useState<any[]>([]);
  const [editingId, setEditingId] = useState<number | null>(null);
  
  const [form, setForm] = useState({ 
    doc_identidad: '', 
    nombre: '', 
    apellido1: '', 
    email_particular: '' 
  });

  const load = async () => {
    try {
      const data = await apiGet('/api/persona');
      setItems(Array.isArray(data) ? data : []);
    } catch (err) {
      console.error("Error al cargar personas:", err);
    }
  };

  useEffect(() => { load(); }, []);

  // Prepara el formulario con los datos de la persona seleccionada
  const handleEdit = (persona: any) => {
    setEditingId(persona.id);
    setForm({
      doc_identidad: persona.doc_identidad,
      nombre: persona.nombre,
      apellido1: persona.apellido1,
      email_particular: persona.email_particular || ''
    });
    window.scrollTo(0, 0); // Sube al formulario
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editingId) {
        // UPDATE: Enviamos PATCH a /api/persona/{id}
        await apiPatch(`/api/persona/${editingId}`, form);
      } else {
        // CREATE: Enviamos POST a /api/persona
        await apiPost('/api/persona', form);
      }
      
      // Limpiar y recargar
      setForm({ doc_identidad: '', nombre: '', apellido1: '', email_particular: '' });
      setEditingId(null);
      load();
    } catch (err) {
      alert("Error al procesar la solicitud");
    }
  };

  const cancelEdit = () => {
    setEditingId(null);
    setForm({ doc_identidad: '', nombre: '', apellido1: '', email_particular: '' });
  };

  return (
    <div className="p-4 bg-white rounded shadow">
      <h2 className="text-xl font-bold mb-4 border-b">
        {editingId ? 'Editar Persona' : 'Gestión de Personas'}
      </h2>

      <form onSubmit={handleSubmit} className="grid grid-cols-2 gap-4 mb-8 bg-gray-50 p-4 rounded border">
        <div className="flex flex-col">
          <label className="text-xs font-semibold text-gray-500">Documento</label>
          <input 
            value={form.doc_identidad}
            onChange={e => setForm({...form, doc_identidad: e.target.value})}
            className="p-2 border rounded bg-white"
            disabled={editingId !== null} // Normalmente el DNI no se cambia
          />
        </div>
        <div className="flex flex-col">
          <label className="text-xs font-semibold text-gray-500">Nombre</label>
          <input 
            value={form.nombre}
            onChange={e => setForm({...form, nombre: e.target.value})}
            className="p-2 border rounded bg-white"
            required
          />
        </div>
        <div className="flex flex-col">
          <label className="text-xs font-semibold text-gray-500">Apellido</label>
          <input 
            value={form.apellido1}
            onChange={e => setForm({...form, apellido1: e.target.value})}
            className="p-2 border rounded bg-white"
            required
          />
        </div>
        <div className="flex flex-col">
          <label className="text-xs font-semibold text-gray-500">Email</label>
          <input 
            type="email"
            value={form.email_particular}
            onChange={e => setForm({...form, email_particular: e.target.value})}
            className="p-2 border rounded bg-white"
          />
        </div>
        
        <div className="col-span-2 flex gap-2">
          <button type="submit" className={`flex-1 p-2 rounded text-white ${editingId ? 'bg-orange-500' : 'bg-blue-600'}`}>
            {editingId ? 'Actualizar Datos' : 'Guardar Persona'}
          </button>
          {editingId && (
            <button type="button" onClick={cancelEdit} className="p-2 bg-gray-300 rounded">
              Cancelar
            </button>
          )}
        </div>
      </form>

      <table className="w-full text-left border-collapse">
        <thead>
          <tr className="bg-gray-100 text-sm">
            <th className="p-2 border">Nombre</th>
            <th className="p-2 border">Documento</th>
            <th className="p-2 border">Acciones</th>
          </tr>
        </thead>
        <tbody className="text-sm">
          {items.map((p) => (
            <tr key={p.id} className="hover:bg-blue-50">
              <td className="p-2 border font-medium">{p.nombre} {p.apellido1}</td>
              <td className="p-2 border text-gray-600">{p.doc_identidad}</td>
              <td className="p-2 border">
                <div className="flex gap-3">
                  <button onClick={() => handleEdit(p)} className="text-blue-600 hover:text-blue-800 font-semibold">
                    Editar
                  </button>
                  <button onClick={() => apiDelete(`/api/persona/${p.id}`).then(load)} className="text-red-600 hover:text-red-800">
                    Borrar
                  </button>
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}