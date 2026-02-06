/// <reference types="vite/client" />
/**
 * =============================================================================
 * api.ts — Cliente HTTP + Auth helpers (React/Vite)
 * =============================================================================
 *
 * OBJETIVO:
 *  - Cliente HTTP basado en fetch.
 *  - Inyección automática de Bearer token (salvo que se desactive por request).
 *  - Helpers REST: apiGet/apiPost/apiPatch/apiDelete.
 *  - Auth: apiLogin (JSON), apiLogout.
 *  - JWT helpers (solo UI): getJwtPayload/getCurrentUserRole (NO valida firma).
 *
 * IMPORTANTE (tu 422 en /v1/auth/login):
 *  - El backend ACTIVO es: app/api/v1/endpoints/auth.py
 *  - Ese endpoint espera JSON:
 *        { "email": "...", "password": "..." }
 *  - NO uses form-urlencoded aquí.
 * =============================================================================
 */

export type HttpMethod = "GET" | "POST" | "PATCH" | "DELETE";

/* =============================================================================
 * Sección 1: Tipos y errores normalizados
 * ============================================================================= */

export type ApiErrorPayload = {
  detail?: unknown;
  message?: string;
  error?: string;
};

export class ApiError extends Error {
  status: number;
  payload?: unknown;

  constructor(message: string, status: number, payload?: unknown) {
    super(message);
    this.name = "ApiError";
    this.status = status;
    this.payload = payload;
  }
}

/* =============================================================================
 * Sección 2: Config / Token helpers
 * ============================================================================= */

function getApiBaseUrl(): string {
  // Compatibilidad con distintos nombres de env var
  const envBase =
    import.meta.env.VITE_API_BASE_URL ??
    import.meta.env.VITE_API_URL ??
    import.meta.env.VITE_API_BASE ??
    "http://localhost:8000";

  return String(envBase).replace(/\/+$/, "");
}

export function getToken(): string | null {
  const token = localStorage.getItem("token");
  if (!token || token === "null" || token === "undefined") return null;
  return token;
}

export function setToken(token: string) {
  localStorage.setItem("token", token);
}

/* =============================================================================
 * Sección 3: HTTP core (fetch) + parseo de respuestas
 * ============================================================================= */

async function parseResponse<T>(res: Response): Promise<T> {
  if (res.status === 204) return undefined as unknown as T;

  const contentType = res.headers.get("content-type") || "";

  if (contentType.includes("application/json")) {
    return (await res.json()) as T;
  }

  const txt = await res.text();
  return txt as unknown as T;
}

export type ApiRequestOptions = {
  /**
   * Por defecto true. En login conviene false para no adjuntar un Bearer viejo.
   */
  auth?: boolean;

  /**
   * Por defecto JSON si hay body y no es FormData.
   */
  contentType?: "application/json";
};

async function apiRequest<T>(
  method: HttpMethod,
  path: string,
  body?: unknown,
  options: ApiRequestOptions = {}
): Promise<T> {
  const baseUrl = getApiBaseUrl();
  const url = `${baseUrl}${path.startsWith("/") ? "" : "/"}${path}`;

  const headers: Record<string, string> = {};

  // Bearer token si procede
  if (options.auth !== false) {
    const token = getToken();
    if (token) headers.Authorization = `Bearer ${token}`;
  }

  const hasBody = body !== undefined && body !== null && method !== "GET";

  if (hasBody && !(body instanceof FormData)) {
    headers["Content-Type"] = options.contentType ?? "application/json";
  }

  const init: RequestInit = {
    method,
    headers,
  };

  if (hasBody) {
    if (body instanceof FormData) {
      init.body = body; // No tocar content-type; el browser pone boundary
    } else if (headers["Content-Type"] === "application/json") {
      init.body = JSON.stringify(body);
    } else {
      init.body = body as any;
    }
  }

  const res = await fetch(url, init);

  if (!res.ok) {
    const payload = await parseResponse<ApiErrorPayload>(res).catch(
      () => undefined
    );
    throw new ApiError(
      `HTTP ${res.status} ${res.statusText}`,
      res.status,
      payload
    );
  }

  return parseResponse<T>(res);
}

/* =============================================================================
 * Sección 4: Helpers REST
 * ============================================================================= */

export function apiGet<T>(path: string, options?: ApiRequestOptions) {
  return apiRequest<T>("GET", path, undefined, options ?? {});
}

export function apiPost<T>(path: string, body?: unknown, options?: ApiRequestOptions) {
  return apiRequest<T>("POST", path, body, options ?? {});
}

export function apiPatch<T>(path: string, body?: unknown, options?: ApiRequestOptions) {
  return apiRequest<T>("PATCH", path, body, options ?? {});
}

export function apiDelete<T>(path: string, options?: ApiRequestOptions) {
  return apiRequest<T>("DELETE", path, undefined, options ?? {});
}

/* =============================================================================
 * Sección 5: Auth (Login / Logout)
 * ============================================================================= */

export type LoginResponse = {
  access_token: string;
  token_type?: string;
  role?: string;
  full_name?: string;
};

/**
 * Login para backend app/api/v1/endpoints/auth.py
 * Espera JSON: { email, password }
 */
export async function apiLogin(
  email: string,
  password: string
): Promise<LoginResponse> {
  const data = await apiRequest<LoginResponse>(
    "POST",
    "/v1/auth/login",
    { email, password },
    { auth: false, contentType: "application/json" }
  );

  if (!data?.access_token) {
    throw new ApiError("Respuesta de login inválida (sin access_token)", 500, data);
  }

  setToken(data.access_token);
  return data;
}

export function apiLogout() {
  localStorage.removeItem("token");
  localStorage.removeItem("access_token");
  localStorage.removeItem("user");
  window.location.replace("/");
}

/* =============================================================================
 * Sección 6: JWT helpers (solo UI — NO valida firma)
 * ============================================================================= */

function base64UrlToBase64(input: string): string {
  const base64 = input.replace(/-/g, "+").replace(/_/g, "/");
  return base64 + "=".repeat((4 - (base64.length % 4)) % 4);
}

function safeAtob(base64: string): string | null {
  try {
    return atob(base64);
  } catch {
    return null;
  }
}

function decodeUtf8FromBinaryString(binary: string): string {
  try {
    return decodeURIComponent(
      binary
        .split("")
        .map((c) => "%" + c.charCodeAt(0).toString(16).padStart(2, "0"))
        .join("")
    );
  } catch {
    return binary;
  }
}

export function getJwtPayload<
  T extends Record<string, unknown> = Record<string, unknown>
>(): T | null {
  const token = getToken();
  if (!token) return null;

  const parts = token.split(".");
  if (parts.length !== 3) return null;

  const payloadB64 = base64UrlToBase64(parts[1]);
  const decoded = safeAtob(payloadB64);
  if (!decoded) return null;

  const json = decodeUtf8FromBinaryString(decoded);

  try {
    return JSON.parse(json) as T;
  } catch {
    return null;
  }
}

export function getCurrentUserRole(): string | null {
  const payload = getJwtPayload<{ role?: unknown }>();
  const role = payload?.role;

  if (role == null) return null;

  const normalized = String(role).trim().toLowerCase();
  return normalized.length ? normalized : null;
}
