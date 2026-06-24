import PropTypes from "prop-types";
import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { getLoginUrl, parseCallbackCode } from "../services/aws-config";

export default function Login({ user, onLogin }) {
  const navigate = useNavigate();

  // Si ya hay sesión, redirigir al dashboard
  useEffect(() => {
    if (user) navigate("/dashboard");
  }, [user, navigate]);

  // Manejar el callback de Cognito con el código de autorización
  useEffect(() => {
    const code = parseCallbackCode();
    if (code) {
      const mockUser = { email: "usuario@educloud.com", name: "Estudiante" };
      onLogin(mockUser);
      navigate("/dashboard");
    }
  }, [navigate, onLogin]);

  return (
    <div className="login-page">
      <div className="login-card">
        <h2>Bienvenido a EduCloud</h2>
        <p>Inicia sesión con tu cuenta para acceder a los cursos y tu progreso.</p>
        <button
          className="login-btn-cognito"
          onClick={() => { globalThis.location.href = getLoginUrl(); }}
        >
          Continuar con Cognito
        </button>
        <div className="login-divider">Plataforma segura · AWS Cognito</div>
      </div>
    </div>
  );
}

// FIX: PropTypes definidos
Login.propTypes = {
  user: PropTypes.shape({
    name: PropTypes.string,
    email: PropTypes.string,
  }),
  onLogin: PropTypes.func.isRequired,
};

Login.defaultProps = {
  user: null,
};