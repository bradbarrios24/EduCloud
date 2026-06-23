const stats = [
  { number: "99.9%", label: "Uptime garantizado" },
  { number: "<50ms", label: "Latencia promedio" },
  { number: "AWS", label: "Infraestructura" },
  { number: "24/7", label: "Disponibilidad" },
];

export default function About() {
  return (
    <section className="section" id="about">
      <div className="section-label">Nosotros</div>
      <h2 className="section-title">Educación respaldada por tecnología real</h2>
      <p className="section-sub">
        EduCloud nació como proyecto universitario en UPAO y evolucionó a una
        plataforma cloud-native completa. Cada componente está diseñado con
        buenas prácticas de arquitectura AWS.
      </p>
      <div className="stats-row">
        {stats.map((s) => (
          <div className="stat-card" key={s.label}>
            <div className="stat-number">{s.number}</div>
            <div className="stat-label">{s.label}</div>
          </div>
        ))}
      </div>
    </section>
  );
}