/**
 * ============================================================================
 * ARCHIVO: main.tsx
 * ============================================================================
 * DESCRIPCIÓN:
 *  - Punto de entrada raíz de React.
 *  - Control de acceso mínimo.
 *
 * CAMBIO CLAVE:
 *  - Antes: "si existe token => estás autenticado" (demasiado optimista).
 *  - Ahora: validación básica de estructura JWT (3 partes) + limpieza si no cuadra.
 *
 * NOTA:
 *  - Esto NO valida la firma del JWT (eso se valida en backend).
 *  - Solo evita que un token basura deje la UI en blanco.
 * ============================================================================
 */

import React from "react";
import ReactDOM from "react-dom/client";
import ProparconLogin from "./ProparconLogin";
import ProparconMainMenu from "./ProparconMainMenu";

function looksLikeJwt(token: string): boolean {
  // JWT típico: header.payload.signature
  const parts = token.split(".");
  return parts.length === 3 && parts.every((p) => p.trim().length > 0);
}

function getValidTokenOrNull(): string | null {
  const token = localStorage.getItem("token");
  if (!token) return null;

  // Evita valores “raros” típicos
  if (token === "null" || token === "undefined") return null;

  // Si no parece JWT, lo consideramos inválido
  if (!looksLikeJwt(token)) return null;

  return token;
}

const RootApp: React.FC = () => {
  const token = getValidTokenOrNull();

  // Si hay token inválido, lo limpiamos para que no te mande al menú y casque.
  if (!token && localStorage.getItem("token")) {
    localStorage.removeItem("token");
  }

  const isAuthenticated = !!token;

  return (
    <React.StrictMode>
      {isAuthenticated ? <ProparconMainMenu /> : <ProparconLogin />}
    </React.StrictMode>
  );
};

ReactDOM.createRoot(document.getElementById("root")!).render(<RootApp />);
