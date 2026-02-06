/**
 * ============================================================================
 * COMPONENTE: ProparconMainMenu.tsx
 * ============================================================================
 * DESCRIPCIÓN:
 *  - Menú principal con pestañas.
 *
 * CAMBIO CLAVE:
 *  - CatalogosPage ahora se carga en lazy (dinámico) y con fallback seguro.
 *  - Si el fichero no existe / falla el chunk, NO deja pantalla en blanco.
 * ============================================================================
 */

import React, { Suspense, lazy, useEffect, useMemo, useState } from "react";

import InmuebleForm from "./components/InmuebleForm";
import EstanciaForm from "./components/EstanciaForm";
import OfertaForm from "./components/OfertaForm";
import PersonaForm from "./components/PersonaForm";
import PropiedadForm from "./components/PropiedadForm";
// import ContratoForm from "./components/ContratoForm";

import { apiLogout, getCurrentUserRole } from "./api";

/**
 * Carga diferida y segura:
 * - Si ./pages/CatalogosPage no existe o falla al cargar, devolvemos un componente fallback.
 */
const CatalogosPage = lazy(() =>
  import("./pages/CatalogosPage").catch(() => ({
    default: () => (
      <div className="p-4 bg-yellow-50 border border-yellow-200 rounded">
        <h2 className="font-semibold">Catálogos no disponible</h2>
        <p className="text-sm">
          No se ha encontrado <code>src/pages/CatalogosPage</code> o ha fallado
          su carga. Revisa el nombre y la ruta del fichero.
        </p>
      </div>
    ),
  }))
);

type Tab =
  | "inmueble"
  | "estancia"
  | "oferta"
  | "persona"
  | "propiedad"
  | "contrato"
  | "catalogos";

export default function ProparconMainMenu() {
  const [selectedTab, setSelectedTab] = useState<Tab>("inmueble");

  // Role desde JWT (UI only). Si no hay role, será "".
  const role = useMemo(() => (getCurrentUserRole() || "").toLowerCase(), []);
  const isAdmin = role === "admin";

  // Guardia: si alguien fuerza "catalogos" sin ser admin, lo devolvemos.
  useEffect(() => {
    if (selectedTab === "catalogos" && !isAdmin) {
      setSelectedTab("inmueble");
    }
  }, [selectedTab, isAdmin]);

  const renderContent = () => {
    switch (selectedTab) {
      case "inmueble":
        return <InmuebleForm />;
      case "estancia":
        return <EstanciaForm />;
      case "oferta":
        return <OfertaForm />;
      case "persona":
        return <PersonaForm />;
      case "propiedad":
        return <PropiedadForm />;
      case "contrato":
        return <div className="p-4">Contrato: pendiente de desarrollo</div>;

      case "catalogos":
        return (
          <Suspense
            fallback={
              <div className="p-4 bg-gray-100 rounded">
                Cargando Catálogos…
              </div>
            }
          >
            <CatalogosPage />
          </Suspense>
        );

      default:
        return <InmuebleForm />;
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white border-b">
        <div className="max-w-6xl mx-auto px-4 py-4 flex items-center justify-between">
          <h1 className="text-xl font-semibold text-gray-900">PROPARCON</h1>

          <div className="flex gap-2">
            <button
              className="px-3 py-2 rounded bg-gray-900 text-white hover:bg-black"
              onClick={() => apiLogout()}
              title="Cerrar sesión"
            >
              Logout
            </button>
          </div>
        </div>

        <nav className="max-w-6xl mx-auto px-4 pb-4 flex flex-wrap gap-2">
          <button
            className={`px-3 py-2 rounded border ${
              selectedTab === "inmueble" ? "bg-white" : "bg-gray-100"
            }`}
            onClick={() => setSelectedTab("inmueble")}
          >
            Inmueble
          </button>

          <button
            className={`px-3 py-2 rounded border ${
              selectedTab === "estancia" ? "bg-white" : "bg-gray-100"
            }`}
            onClick={() => setSelectedTab("estancia")}
          >
            Estancia
          </button>

          <button
            className={`px-3 py-2 rounded border ${
              selectedTab === "oferta" ? "bg-white" : "bg-gray-100"
            }`}
            onClick={() => setSelectedTab("oferta")}
          >
            Oferta
          </button>

          <button
            className={`px-3 py-2 rounded border ${
              selectedTab === "persona" ? "bg-white" : "bg-gray-100"
            }`}
            onClick={() => setSelectedTab("persona")}
          >
            Persona
          </button>

          <button
            className={`px-3 py-2 rounded border ${
              selectedTab === "propiedad" ? "bg-white" : "bg-gray-100"
            }`}
            onClick={() => setSelectedTab("propiedad")}
          >
            Propiedad
          </button>

          <button
            className={`px-3 py-2 rounded border ${
              selectedTab === "contrato" ? "bg-white" : "bg-gray-100"
            }`}
            onClick={() => setSelectedTab("contrato")}
          >
            Contrato
          </button>

          {/* Solo ADMIN ve Catálogos */}
          {isAdmin && (
            <button
              className={`px-3 py-2 rounded border ${
                selectedTab === "catalogos" ? "bg-white" : "bg-gray-100"
              }`}
              onClick={() => setSelectedTab("catalogos")}
            >
              Catálogos
            </button>
          )}
        </nav>
      </header>

      <main className="max-w-6xl mx-auto px-4 py-6">{renderContent()}</main>
    </div>
  );
}
