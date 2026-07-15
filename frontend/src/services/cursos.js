import { apiFetch } from "./api";

export function getCursos(idToken) {
  return apiFetch("/api/cursos", { idToken });
}

// ⚠️ Requiere POST /api/cursos en tu API Gateway + Lambda (no existe aún)
export function crearCurso(idToken, curso) {
  return apiFetch("/api/cursos", { method: "POST", idToken, body: curso });
}

// ⚠️ Requiere endpoint que devuelva una URL prefirmada de S3 hacia tu bucket
// s3_uploads (no existe aún — necesitas una Lambda que genere el presigned URL)
export function subirDocumentoCurso(idToken, cursoId, file) {
  return apiFetch(`/api/cursos/${cursoId}/documentos`, {
    method: "POST",
    idToken,
    body: { nombre: file.name, tipo: file.type },
  }).then(async ({ uploadUrl }) => {
    await fetch(uploadUrl, {
      method: "PUT",
      body: file,
      headers: { "Content-Type": file.type },
    });
  });
}