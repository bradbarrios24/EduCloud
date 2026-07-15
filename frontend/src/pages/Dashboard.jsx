import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import Footer from "../components/Footer";

const cards = [
  { label: "Cursos activos", value: "3" },
  { label: "Lecciones completadas", value: "12" },
  { label: "Horas de estudio", value: "8h" },
  { label: "Certificados", value: "1" },
];

export default function Dashboard() {
  const { user } = useAuth();
  const navigate = useNavigate();

  return (
    <>
      <div className="dashboard">
        <div className="dashboard-header">
          <h1>Hola, {user?.name || "Estudiante"} 👋</h1>
          <p>Aquí está tu progreso en EduCloud</p>
        </div>
        <div className="dashboard-grid">
          {cards.map((c) => (
            <div className="dashboard-card" key={c.label}>
              <div className="dashboard-card-label">{c.label}</div>
              <div className="dashboard-card-value">{c.value}</div>
            </div>
          ))}
        </div>
        <div style={{ marginTop: "1rem" }}>
          <h2>Continuar aprendiendo</h2>
          <button className="btn-primary" onClick={() => navigate("/cursos")}>
            Ver todos los cursos
          </button>
        </div>
      </div>
      <Footer />
    </>
  );
}