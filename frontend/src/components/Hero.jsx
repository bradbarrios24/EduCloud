import { getLoginUrl } from "../services/aws-config";

export default function Hero() {
  return (
    <section className="hero">
      <div>
        <span className="hero-eyebrow">Plataforma educativa · AWS Cloud</span>
        <h1>
          Aprende sin límites,<br />
          <span>escala en la nube</span>
        </h1>
        <p className="hero-sub">
          EduCloud conecta estudiantes y docentes en una infraestructura
          segura, rápida y construida sobre AWS.
        </p>
        <div className="hero-actions">
          <a href="#features" className="btn-primary">Ver características</a>
          <button
            className="btn-secondary"
            onClick={() => { globalThis.location.href = getLoginUrl(); }}
          >
            Comenzar gratis
          </button>
        </div>
      </div>
    </section>
  );
}