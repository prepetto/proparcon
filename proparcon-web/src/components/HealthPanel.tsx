/**
 * ============================================================================
 * COMPONENTE: HealthPanel.tsx
 * ============================================================================
 * Descripción: Panel de control para verificar la salud de la conexión.
 * Sección: DIAGNÓSTICO - Verifica latencia y estado del Backend.
 * ============================================================================
 */
import React, { useState } from 'react';
import { apiGet } from '../api';

export default function HealthPanel() {
  const [status, setStatus] = useState<any>(null);

  const check = async () => {
    try {
      const res = await apiGet('/health');
      setStatus(res);
    } catch (e) {
      setStatus({ status: "Error de conexión" });
    }
  };

  return (
    <div className="alert alert-info mt-4">
      <h5>Estado del Servidor</h5>
      <button onClick={check} className="btn btn-primary btn-sm">Refrescar Estado</button>
      {status && (
        <pre className="mt-2 bg-dark text-white p-2 rounded">
          {JSON.stringify(status, null, 2)}
        </pre>
      )}
    </div>
  );
}