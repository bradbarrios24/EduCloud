import { useEffect, useState } from "react";
import { useAuth } from "../context/AuthContext";
import { getEvaluaciones, crearEvaluacion, entregarEvaluacion } from "../services/evaluaciones";
import { notifyTareaCreada } from "../services/notifications";
import Footer from "../components/Footer";

export default function Evaluaciones() {
  const { user, idToken } = useAuth();
  const [evaluaciones, setEvaluaciones] = useState([]);
  const [error, setError] = useState(null);
  const [nueva, setNueva] = useState({ titulo: "", curso: "", fecha_entrega: "" });
  const [respuestas, setRespuestas] = useState({});

  const esDocente = user?.role === "docente" || user?.role === "admin";

  useEffect(() => {
    getEvaluaciones(idToken, "todos")
      .then((data) => setEvaluaciones(data.evaluaciones || []))
      .catch((err) => setError(err.message));
  }, [idToken]);

  const handleCrear = async (e) => {
    e.preventDefault();
    try {
      await crearEvaluacion(idToken, nueva);
      await notifyTareaCreada(idToken, {
        cursoNombre: nueva.curso,
        tareaTitulo: nueva.titulo,
        fechaEntrega: nueva.fecha_entrega,
      });
      setEvaluaciones((prev) => [...prev, nueva]);
      setNueva({ titulo: "", curso: "", fecha_entrega: "" });
    } catch (err) {
      setError(`No se pudo crear la evaluación: ${err.message}`);
    }
  };

  const handleEntregar = async (evalId) => {
    try {
      await entregarEvaluacion(idToken, evalId, respuestas[evalId] || "");
      setRespuestas((prev) => ({ ...prev, [evalId]: "" }));
    } catch (err) {
      setError(`No se pudo entregar: ${err.message}`);
    }
  };

  return (
    <>
      <div className="section" style={{ paddingTop: "6rem" }}>
        <h1 className="section-title">Evaluaciones</h1>
        {error && <p className="error-msg">{error}</p>}

        {esDocente && (
          <form className="curso-form" onSubmit={handleCrear}>
            <h3>Crear evaluación</h3>
            <input
              placeholder="Título"
              value={nueva.titulo}
              onChange={(e) => setNueva({ ...nueva, titulo: e.target.value })}
              required
            />
            <input
              placeholder="Curso"
              value={nueva.curso}
              onChange={(e) => setNueva({ ...nueva, curso: e.target.value })}
              required
            />
            <input
              type="datetime-local"
              value={nueva.fecha_entrega}
              onChange={(e) => setNueva({ ...nueva, fecha_entrega: e.target.value })}
              required
            />
            <button type="submit" className="btn-primary">Crear evaluación</button>
          </form>
        )}

        <div className="evaluaciones-list">
          {evaluaciones.map((ev, i) => (
            <div className="evaluacion-card" key={ev.id || i}>
              <h3>{ev.titulo}</h3>
              <p>Curso: {ev.curso}</p>
              <p>Entrega: {ev.fecha_entrega}</p>

              {!esDocente && (
                <div className="entrega-box">
                  <textarea
                    placeholder="Tu respuesta..."
                    value={respuestas[ev.id] || ""}
                    onChange={(e) =>
                      setRespuestas((prev) => ({ ...prev, [ev.id]: e.target.value }))
                    }
                  />
                  <button className="btn-primary" onClick={() => handleEntregar(ev.id)}>
                    Entregar
                  </button>
                </div>
              )}

              {esDocente && (
                <div className="docente-actions">
                  <button className="btn-secondary">Editar</button>
                  <button className="btn-secondary">Ver entregas</button>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
      <Footer />
    </>
  );
}