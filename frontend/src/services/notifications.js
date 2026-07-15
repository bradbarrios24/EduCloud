import { apiFetch } from "./api";

export function notifyCursoCreado(idToken, { cursoNombre, docente }) {
  return apiFetch("/api/mensajes", {
    method: "POST",
    idToken,
    body: {
      tipo: "curso_creado",
      curso: cursoNombre,
      docente,
      fecha: new Date().toISOString(),
    },
  });
}

export function notifyTareaCreada(idToken, { cursoNombre, tareaTitulo, fechaEntrega }) {
  return apiFetch("/api/mensajes", {
    method: "POST",
    idToken,
    body: {
      tipo: "tarea_creada",
      curso: cursoNombre,
      tarea: tareaTitulo,
      fecha_entrega: fechaEntrega,
      fecha: new Date().toISOString(),
    },
  });
}