import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function Login() {
  const { user, login } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (user) navigate("/dashboard", { replace: true });
  }, [user, navigate]);

  return (
    <div className="login-page">
      <div className="login-card">
        <h2>Bienvenido a EduCloud</h2>
        <p>Inicia sesión con tu cuenta para acceder a tus cursos y evaluaciones.</p>
        <button className="login-btn-cognito" onClick={login}>
          Continuar
        </button>
        <div className="login-divider">Plataforma segura · AWS Cognito</div>
      </div>
    </div>
  );
}