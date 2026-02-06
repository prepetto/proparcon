// vite.config.ts
// Comentario: configuración mínima de Vite con React y TS
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    watch: {
      usePolling: true, // Vital para Docker en algunos sistemas
    },
    host: true, // Esto complementa tu comando de Docker
    strictPort: true,
    port: 5173,
  }
})