import PropTypes from "prop-types";
import { Link } from "react-router-dom";
import { getLoginUrl } from "../services/aws-config";

export default function Navbar({ user, onLogout }) {
  // FIX: eliminado useNavigate porque no se usaba
  const handleLogin = () => {
    // FIX: globalThis en lugar de window
    globalThis.location.href = getLoginUrl();
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
        <button className="btn-secondary" onClick={onLogout}>
          Cerrar sesión
        </button>
      ) : (
        <button className="navbar-cta" onClick={handleLogin}>
          Ingresar
        </button>
      )}
    </nav>
  );
}

// FIX: PropTypes definidos
Navbar.propTypes = {
  user: PropTypes.shape({
    name: PropTypes.string,
    email: PropTypes.string,
  }),
  onLogout: PropTypes.func,
};

Navbar.defaultProps = {
  user: null,
  onLogout: () => {},
};