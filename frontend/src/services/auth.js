import { awsConfig } from "./aws-config";

// ============================================
// PKCE (Proof Key for Code Exchange) — reemplaza el uso de client secret
// ============================================
function base64UrlEncode(buffer) {
  return btoa(String.fromCharCode(...new Uint8Array(buffer)))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");
}

function generateCodeVerifier() {
  const array = new Uint8Array(32);
  crypto.getRandomValues(array);
  return base64UrlEncode(array.buffer);
}

async function generateCodeChallenge(verifier) {
  const data = new TextEncoder().encode(verifier);
  const digest = await crypto.subtle.digest("SHA-256", data);
  return base64UrlEncode(digest);
}

// ============================================
// LOGIN
// ============================================
export async function redirectToLogin() {
  const verifier = generateCodeVerifier();
  sessionStorage.setItem("pkce_verifier", verifier);
  const challenge = await generateCodeChallenge(verifier);

  const { domain, clientId, redirectUri, scopes } = awsConfig.cognito;
  const params = new URLSearchParams({
    client_id: clientId,
    response_type: "code",
    scope: scopes.join(" "),
    redirect_uri: redirectUri,
    code_challenge: challenge,
    code_challenge_method: "S256",
  });
  globalThis.location.href = `https://${domain}/login?${params.toString()}`;
}

// ============================================
// INTERCAMBIO DE CÓDIGO POR TOKENS
// ============================================
export async function exchangeCodeForTokens(code) {
  const verifier = sessionStorage.getItem("pkce_verifier");
  const { domain, clientId, redirectUri } = awsConfig.cognito;

  const body = new URLSearchParams({
    grant_type: "authorization_code",
    client_id: clientId,
    code,
    redirect_uri: redirectUri,
    code_verifier: verifier || "",
  });

  const res = await fetch(`https://${domain}/oauth2/token`, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: body.toString(),
  });

  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`Error al intercambiar el código (${res.status}): ${text}`);
  }
  return res.json(); // { id_token, access_token, refresh_token, expires_in, token_type }
}

// ============================================
// LOGOUT
// ============================================
export function redirectToLogout() {
  const { domain, clientId, redirectUri } = awsConfig.cognito;
  const params = new URLSearchParams({
    client_id: clientId,
    logout_uri: redirectUri,
  });
  globalThis.location.href = `https://${domain}/logout?${params.toString()}`;
}

// ============================================
// ROLES — mapea grupos de Cognito a roles de la app
// AJUSTA estos nombres a los grupos reales de tu User Pool
// ============================================
const GROUP_ROLE_MAP = {
  Administradores: "admin",
  Docentes: "docente",
  Estudiantes: "estudiante",
};
const ROLE_PRIORITY = ["admin", "docente", "estudiante"];

export function getRoleFromGroups(groups = []) {
  const mapped = groups.map((g) => GROUP_ROLE_MAP[g]).filter(Boolean);
  for (const role of ROLE_PRIORITY) {
    if (mapped.includes(role)) return role;
  }
  return "estudiante"; // rol por defecto más restrictivo si no matchea ningún grupo
}