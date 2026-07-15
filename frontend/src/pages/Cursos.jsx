import { useEffect, useState } from "react";
import { useAuth } from "../context/AuthContext";
import { getCursos, crearCurso, subirDocumentoCurso } from "../services/cursos";
import { notifyCursoCreado } from "../services/notifications";
import Footer from "../components/Footer";

export default function Cursos() {
  const { user, idToken } = useAuth();
  const [cursos, setCursos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [nuevoCurso, setNuevoCurso] = useState({ titulo: "", descripcion: "" });

  const esDocente = user?.role === "docente" || user?.role === "admin";

  useEffect(() => {
    getCursos(idToken)
      .then((data) => setCursos(data.cursos || []))
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, [idToken]);

  const handleCrearCurso = async (e) => {
    e.preventDefault();
    try {
      await crearCurso(idToken, nuevoCurso);
      await notifyCursoCreado(idToken, {
        cursoNombre: nuevoCurso.titulo,
        docente: user.name,
      });
      setCursos((prev) => [...prev, nuevoCurso]);
      setNuevoCurso({ titulo: "", descripcion: "" });
    } catch (err) {
      setError(`No se pudo crear el curso: ${err.message}`);
    }
  };

  const handleSubirDocumento = async (cursoId, e) => {
    const file = e.target.files[0];
    if (!file) return;
    try {
      await subirDocumentoCurso(idToken, cursoId, file);
    } catch (err) {
      setError(`No se pudo subir el documento: ${err.message}`);
    }
  };

  return (
    <>
      <div className="section" style={{ paddingTop: "6rem" }}>
        <div className="section-label">Catálogo</div>
        <h1 className="section-title">Cursos disponibles</h1>

        {error && <p className="error-msg">{error}</p>}

        {esDocente && (
          <form className="curso-form" onSubmit={handleCrearCurso}>
            <h3>Crear nuevo curso</h3>
            <input
              placeholder="Título"
              value={nuevoCurso.titulo}
              onChange={(e) => setNuevoCurso({ ...nuevoCurso, titulo: e.target.value })}
              required
            />
            <textarea
              placeholder="Descripción"
              value={nuevoCurso.descripcion}
              onChange={(e) => setNuevoCurso({ ...nuevoCurso, descripcion: e.target.value })}
            />
            <button type="submit" className="btn-primary">Crear curso</button>
          </form>
        )}

        {loading ? (
          <p>Cargando cursos...</p>
        ) : (
          <div className="cursos-grid">
            {cursos.map((c, i) => (
              <div className="curso-card" key={c.id || i}>
                <div className="curso-card-body">
                  <h3>{c.titulo}</h3>
                  <p>{c.descripcion}</p>
                  <label className="btn-upload">
                    Subir documento
                    <input
                      type="file"
                      hidden
                      onChange={(e) => handleSubirDocumento(c.id, e)}
                    />
                  </label>
                  {esDocente && <button className="btn-secondary">Editar curso</button>}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
      <Footer />
    </>
  );
}