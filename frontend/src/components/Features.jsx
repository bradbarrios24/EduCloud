const features = [
  {
    icon: "⚡",
    title: "Entrega ultrarrápida",
    desc: "Contenido distribuido globalmente vía CloudFront CDN. Latencia mínima sin importar dónde estés.",
  },
  {
    icon: "🔒",
    title: "Autenticación segura",
    desc: "Login gestionado por Amazon Cognito. OAuth 2.0, tokens JWT y control de sesiones robusto.",
  },
  {
    icon: "☁️",
    title: "Infraestructura escalable",
    desc: "Backend en AWS que crece contigo. Sin preocuparte por servidores ni capacidad.",
  },
  {
    icon: "🛡️",
    title: "Protección WAF",
    desc: "Firewall de aplicaciones web activo. Bloqueo de SQL injection, XSS y ataques de fuerza bruta.",
  },
  {
    icon: "📚",
    title: "Cursos en línea",
    desc: "Accede a contenido estructurado por módulos, con seguimiento de progreso en tiempo real.",
  },
  {
    icon: "🎓",
    title: "Certificaciones",
    desc: "Completa cursos y obtén certificados verificables respaldados por la plataforma.",
  },
];

export default function Features() {
  return (
    <section className="section" id="features">
      <div className="section-label">Características</div>
      <h2 className="section-title">Todo lo que necesitas para aprender</h2>
      <p className="section-sub">
        Construido sobre servicios AWS de nivel empresarial, diseñado para estudiantes.
      </p>
      <div className="features-grid">
        {features.map((f) => (
          <div className="feature-card" key={f.title}>
            <div className="feature-icon">{f.icon}</div>
            <h3>{f.title}</h3>
            <p>{f.desc}</p>
          </div>
        ))}
      </div>
    </section>
  );
}