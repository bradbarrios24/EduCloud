import { Link } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

const ROLE_LABEL = {
  admin: "Administrador",
  docente: "Docente",
  estudiante: "Estudiante",
};

export default function Navbar() {
  const { user, logout } = useAuth();

  return (
    <nav className="navbar">
      <Link to="/" className="navbar-brand">EduCloud</Link>
      <div className="navbar-links">
        <Link to="/cursos">Cursos</Link>
        {user && <Link to="/evaluaciones">Evaluaciones</Link>}
        {user && <Link to="/dashboard">Dashboard</Link>}
        {user ? (
          <div className="navbar-user">
            <span className="navbar-role-badge">{ROLE_LABEL[user.role]}</span>
            <span>{user.name}</span>
            <button className="btn-logout" onClick={logout}>Cerrar sesión</button>
          </div>
        ) : (
          <Link to="/login" className="btn-primary">Iniciar sesión</Link>
        )}
      </div>
    </nav>
  );
}