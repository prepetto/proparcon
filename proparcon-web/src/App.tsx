/**
 * ============================================================================
 * APP COMPONENT (App.tsx)
 * ============================================================================
 * Función: Actúa como el contenedor principal de la aplicación.
 * Actualmente delega toda la lógica de navegación al Menú Principal.
 * ============================================================================
 */

import React from "react";
import ProparconMainMenu from "./ProparconMainMenu";

export default function App() {
  return (
    // Contenedor principal con fondo suave para toda la web
    <div className="min-h-screen bg-slate-50 text-slate-900">
      <ProparconMainMenu />
    </div>
  );
}
