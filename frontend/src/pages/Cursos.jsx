import Footer from "../components/Footer";

const cursos = [
  {
    tag: "AWS",
    title: "Fundamentos de Cloud Computing",
    desc: "Aprende los conceptos básicos de la nube con AWS. S3, EC2, IAM y más.",
    duracion: "12h",
    nivel: "Principiante",
  },
  {
    tag: "DevOps",
    title: "Infraestructura como Código con Terraform",
    desc: "Automatiza tu infraestructura AWS usando Terraform y buenas prácticas de IaC.",
    duracion: "18h",
    nivel: "Intermedio",
  },
  {
    tag: "Seguridad",
    title: "Seguridad en AWS: WAF y Cognito",
    desc: "Protege tus aplicaciones con WAF, gestiona identidades con Cognito y aplica el principio de mínimo privilegio.",
    duracion: "10h",
    nivel: "Intermedio",
  },
  {
    tag: "Frontend",
    title: "React + AWS Amplify",
    desc: "Construye aplicaciones React integradas con servicios AWS: Cognito, S3 y CloudFront.",
    duracion: "15h",
    nivel: "Intermedio",
  },
  {
    tag: "Backend",
    title: "APIs Serverless con Lambda",
    desc: "Crea APIs escalables sin servidores usando AWS Lambda, API Gateway y DynamoDB.",
    duracion: "20h",
    nivel: "Avanzado",
  },
  {
    tag: "IA",
    title: "Machine Learning en AWS SageMaker",
    desc: "Entrena y despliega modelos de ML en la nube usando SageMaker y servicios de IA de AWS.",
    duracion: "24h",
    nivel: "Avanzado",
  },
];

export default function Cursos() {
  return (
    <>
      <div className="section" style={{ paddingTop: "6rem" }}>
        <div className="section-label">Catálogo</div>
        <h1 className="section-title">Cursos disponibles</h1>
        <p className="section-sub">
          Contenido práctico orientado a tecnologías AWS y desarrollo de software moderno.
        </p>
        <div className="cursos-grid">
          {cursos.map((c) => (
            <div className="curso-card" key={c.title}>
              <div className="curso-card-body">
                <span className="curso-tag">{c.tag}</span>
                <h3>{c.title}</h3>
                <p>{c.desc}</p>
                <div className="curso-meta">
                  <span>⏱ {c.duracion}</span>
                  <span>📊 {c.nivel}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
      <Footer />
    </>
  );
}