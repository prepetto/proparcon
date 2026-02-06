/**
 * ============================================================================
 * COMPONENTE: InmuebleForm.tsx
 * PROYECTO: PROPARCON Web Client
 * DESCRIPCIÓN: Gestión centralizada de activos inmobiliarios y catastro.
 * ============================================================================
 * ACTUALIZACIÓN REALIZADA:
 * ✅ ALINEACIÓN DE CAMPOS: Sincronizado con 'nombre_publico' y 'referencia_catastral'
 * según el esquema InmuebleCreate del backend.
 * ✅ FULL CRUD UI: Implementado soporte para Listar (GET), Crear (POST), 
 * Actualizar (PATCH) y Eliminar (DELETE).
 * ✅ MODO EDICIÓN: El formulario conmuta dinámicamente entre alta y edición.
 * ✅ NORMALIZACIÓN: Uso de apiPatch para actualizaciones parciales.
 * ============================================================================
 */

import React, { useEffect, useState } from 'react';
import { apiGet, apiPost, apiDelete, apiPatch } from '../api';

export default function InmuebleForm() {
  // --- SECCIÓN 1: ESTADO Y VARIABLES ---
  const [items, setItems] = useState<any[]>([]);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [loading, setLoading] = useState(false);
  
  // Estado alineado con InmuebleCreate e InmuebleUpdate del backend
  const [form, setForm] = useState({ 
    tipo_inmueble_id: 1, 
    nombre_publico: '', 
    direccion_id: 1, 
    referencia_catastral: '' 
  });

  // --- SECCIÓN 2: CARGA DE DATOS (READ) ---
  const load = async () => {
    try {
      setLoading(true);
      // Llama al nuevo endpoint de listado global implementado en inmueble.py
      const data = await apiGet('/api/inmueble');
      setItems(Array.isArray(data) ? data : []);
    } catch (e) { 
      console.error("Error al cargar la cartera de inmuebles", e); 
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, []);

  // --- SECCIÓN 3: GESTIÓN DE EDICIÓN ---
  const handleEdit = (item: any) => {
    setEditingId(item.id);
    // Cargamos los datos actuales en el formulario
    setForm({
      tipo_inmueble_id: item.tipo_inmueble_id || 1,
      nombre_publico: item.nombre_publico || '',
      direccion_id: item.direccion_id || 1,
      referencia_catastral: item.ref_catastral || '' // Viene del LEFT JOIN de la API
    });
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const cancelEdit = () => {
    setEditingId(null);
    setForm({ tipo_inmueble_id: 1, nombre_publico: '', direccion_id: 1, referencia_catastral: '' });
  };

  // --- SECCIÓN 4: ACCIONES DE PERSISTENCIA (CREATE / UPDATE) ---
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editingId) {
        // Ejecuta PATCH alineado con actualizar_inmueble en el backend
        await apiPatch(`/api/inmueble/${editingId}`, form);
      } else {
        // Ejecuta POST alineado con crear_inmueble_completo en el backend
        await apiPost('/api/inmueble', form);
      }
      cancelEdit();
      load();
    } catch (e) { 
      alert("Error al procesar el inmueble. Verifique los datos técnicos."); 
    }
  };

  // --- SECCIÓN 5: RENDERIZADO DE INTERFAZ ---
  return (
    <div className="p-4 bg-white rounded shadow">
      <h2 className="text-xl font-bold mb-4 border-b">
        {editingId ? '🛠️ Editando Inmueble' : '🏠 Cartera de Inmuebles'}
      </h2>

      {/* Formulario de Inmueble */}
      <form onSubmit={handleSubmit} className="grid grid-cols-2 gap-4 mb-8 bg-gray-50 p-4 border rounded">
        <div className="flex flex-col">
          <label className="text-xs font-bold text-gray-500 uppercase">Nombre Público / Alias</label>
          <input 
            value={form.nombre_publico} 
            onChange={e => setForm({...form, nombre_publico: e.target.value})} 
            className="p-2 border rounded bg-white" 
            placeholder="Ej: Apartamento Centro"
            required 
          />
        </div>
        
        <div className="flex flex-col">
          <label className="text-xs font-bold text-gray-500 uppercase">Referencia Catastral</label>
          <input 
            value={form.referencia_catastral} 
            onChange={e => setForm({...form, referencia_catastral: e.target.value})} 
            className="p-2 border rounded bg-white" 
            placeholder="20 caracteres alfanuméricos"
          />
        </div>

        <div className="flex flex-col">
          <label className="text-xs font-bold text-gray-500 uppercase">ID Tipo Inmueble</label>
          <input 
            type="number"
            value={form.tipo_inmueble_id} 
            onChange={e => setForm({...form, tipo_inmueble_id: parseInt(e.target.value)})} 
            className="p-2 border rounded bg-white" 
            required
          />
        </div>

        <div className="flex flex-col">
          <label className="text-xs font-bold text-gray-500 uppercase">ID Dirección</label>
          <input 
            type="number"
            value={form.direccion_id} 
            onChange={e => setForm({...form, direccion_id: parseInt(e.target.value)})} 
            className="p-2 border rounded bg-white" 
            required
          />
        </div>

        <div className="col-span-2 flex gap-2 pt-2">
          <button 
            type="submit" 
            className={`flex-1 p-2 rounded text-white font-bold transition-colors ${editingId ? 'bg-orange-500 hover:bg-orange-600' : 'bg-blue-600 hover:bg-blue-700'}`}
          >
            {editingId ? 'Actualizar Inmueble' : 'Guardar Inmueble'}
          </button>
          {editingId && (
            <button 
              type="button" 
              onClick={cancelEdit} 
              className="px-4 p-2 bg-gray-300 rounded hover:bg-gray-400 transition-colors"
            >
              Cancelar
            </button>
          )}
        </div>
      </form>

      {/* Tabla de Resultados (Listado Global) */}
      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-gray-100 text-xs uppercase text-gray-600">
              <th className="p-2 border">ID</th>
              <th className="p-2 border">Nombre Público</th>
              <th className="p-2 border">Ref. Catastral</th>
              <th className="p-2 border">Acciones</th>
            </tr>
          </thead>
          <tbody className="text-sm">
            {loading ? (
              <tr><td colSpan={4} className="p-4 text-center">Cargando activos...</td></tr>
            ) : items.map((i) => (
              <tr key={i.id} className="hover:bg-blue-50 transition-colors">
                <td className="p-2 border text-gray-500">{i.id}</td>
                <td className="p-2 border font-medium">{i.nombre_publico}</td>
                <td className="p-2 border font-mono text-xs">{i.ref_catastral || 'Sin asignar'}</td>
                <td className="p-2 border">
                  <div className="flex gap-4">
                    <button 
                      onClick={() => handleEdit(i)} 
                      className="text-blue-600 hover:text-blue-800 font-bold"
                    >
                      Editar
                    </button>
                    <button 
                      onClick={() => apiDelete(`/api/inmueble/${i.id}`).then(load)} 
                      className="text-red-600 hover:text-red-800"
                    >
                      Borrar
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      
      {!loading && items.length === 0 && (
        <p className="py-6 text-center text-gray-500 italic">No hay inmuebles registrados en la cartera.</p>
      )}
    </div>
  );
}