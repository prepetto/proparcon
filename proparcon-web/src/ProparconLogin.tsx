/**
 * ============================================================================
 * ARCHIVO: ProparconLogin.tsx
 * ============================================================================
 * DESCRIPCIÓN: Pantalla de inicio de sesión.
 * SECCIÓN: FORMULARIO - Captura NIF/Email y contraseña.
 * ============================================================================
 */
import React, { useState } from 'react';
import { apiLogin } from './api';

const ProparconLogin: React.FC = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    try {
      await apiLogin(username, password);
      // Tras éxito, el token se guarda en api.ts y recargamos main.tsx
      window.location.reload();
    } catch (err: any) {
      setError("Fallo en la autenticación. Verifique sus credenciales.");
    }
  };

  return (
    <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh', background: '#ecf0f1' }}>
      <form onSubmit={handleLogin} style={{ background: 'white', padding: '40px', borderRadius: '8px', boxShadow: '0 4px 6px rgba(0,0,0,0.1)', width: '300px' }}>
        <h2 style={{ textAlign: 'center', color: '#2c3e50' }}>Acceso Proparcon</h2>
        <div style={{ marginBottom: '15px' }}>
          <label>Usuario (NIF/Email):</label>
          <input type="text" value={username} onChange={e => setUsername(e.target.value)} style={{ width: '100%', padding: '10px', marginTop: '5px' }} required />
        </div>
        <div style={{ marginBottom: '20px' }}>
          <label>Contraseña:</label>
          <input type="password" value={password} onChange={e => setPassword(e.target.value)} style={{ width: '100%', padding: '10px', marginTop: '5px' }} required />
        </div>
        {error && <p style={{ color: 'red', fontSize: '14px' }}>{error}</p>}
        <button type="submit" style={{ width: '100%', padding: '12px', background: '#3498db', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer' }}>
          Iniciar Sesión
        </button>
      </form>
    </div>
  );
};

export default ProparconLogin;