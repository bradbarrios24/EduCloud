// ============================================
// CONFIGURACIÓN AWS - EduCloud
// ============================================
const isProd = globalThis.location.hostname !== "localhost";

export const awsConfig = {
  region: "us-east-1",
  cognito: {
    userPoolId: "us-east-1_SRtb6h9Gi",
    clientId: "60vdacjp2bn8a8hu4egva3u3tf",
    domain: "auth-dev-educloud.auth.us-east-1.amazoncognito.com",
    redirectUri: isProd
      ? "https://d13h6elhc0kb8t.cloudfront.net"
      : "http://localhost:3000",
    scopes: ["email", "openid", "profile"],
  },
  api: {
    // FIX: faltaba la base URL del API Gateway, necesaria para todos los servicios
    baseUrl: isProd
      ? "https://76lqn23j4h.execute-api.us-east-1.amazonaws.com/dev"
      : "https://76lqn23j4h.execute-api.us-east-1.amazonaws.com/dev",
  },
};