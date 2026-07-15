import { awsConfig } from "./aws-config";

export async function apiFetch(path, { method = "GET", body, idToken, headers = {} } = {}) {
  const res = await fetch(`${awsConfig.api.baseUrl}${path}`, {
    method,
    headers: {
      "Content-Type": "application/json",
      ...(idToken ? { Authorization: idToken } : {}),
      ...headers,
    },
    body: body ? JSON.stringify(body) : undefined,
  });

  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`API error ${res.status}: ${text}`);
  }
  return res.json();
}