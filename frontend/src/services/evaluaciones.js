import { apiFetch } from "./api";

export function getEvaluaciones(idToken, cursoId) {
  return apiFetch(`/api/evaluaciones?curso=${cursoId}`, { idToken });
}

// ⚠️ Requiere POST /api/evaluaciones (docente) — no existe aún
export function crearEvaluacion(idToken, evaluacion) {
  return apiFetch("/api/evaluaciones", { method: "POST", idToken, body: evaluacion });
}

// ⚠️ Requiere POST /api/entregas (estudiante) — no existe aún
export function entregarEvaluacion(idToken, evaluacionId, respuesta) {
  return apiFetch("/api/entregas", {
    method: "POST",
    idToken,
    body: { evaluacion_id: evaluacionId, respuesta },
  });
}