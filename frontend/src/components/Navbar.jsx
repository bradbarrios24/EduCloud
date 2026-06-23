import { Link, useNavigate } from "react-router-dom";
import { getLoginUrl } from "../services/aws-config";

export default function Navbar({ user, onLogout }) {
  const navigate = useNavigate();

  const handleLogin = () => {
    window.location.href = getLoginUrl();
  };

  return (
    <nav className="navbar">
      <Link to="/" className="navbar-brand">EduCloud</Link>

      <ul className="navbar-links">
        <li><Link to="/#features">Características</Link></li>
        <li><Link to="/#about">Nosotros</Link></li>
        <li><Link to="/cursos">Cursos</Link></li>
        {user && <li><Link to="/dashboard">Dashboard</Link></li>}
      </ul>

      {user ? (
        <button className="btn-secondary" onClick={onLogout} style={{ padding: "0.45rem 1rem", fontSize: "0.875rem" }}>
          Cerrar sesión
        </button>
      ) : (
        <button className="navbar-cta navbar-links a" onClick={handleLogin}>
          Ingresar
        </button>
      )}
    </nav>
  );
}