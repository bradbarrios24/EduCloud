// ============================================
// CONFIGURACIÓN AWS - EduCloud
// ============================================
export const awsConfig = {
  region: "us-east-1",
  cognito: {
    userPoolId: "us-east-1_SRtb6h9Gi",
    clientId: "60vdacjp2bn8a8hu4egva3u3tf",
    domain: "auth-dev-educloud.auth.us-east-1.amazoncognito.com",
    loginUrl: "https://auth-dev-educloud.auth.us-east-1.amazoncognito.com/login",
    redirectUri: "http://localhost:3000",
    scopes: ["email", "openid", "profile"],
  },
  cloudfront: {
    url: "https://d13h6elhc0kb8t.cloudfront.net",
    distributionId: "E18QSB741HKZIT",
  },
  s3: {
    bucket: "frontend-7ca3a3fa",
  },
};

// ============================================
// HELPERS DE AUTENTICACIÓN
// ============================================
export const getLoginUrl = () => {
  const { domain, clientId, redirectUri, scopes } = awsConfig.cognito;
  const params = new URLSearchParams({
    client_id: clientId,
    response_type: "code",
    scope: scopes.join(" "),
    redirect_uri: redirectUri,
  });
  return `https://${domain}/login?${params.toString()}`;
};

export const getLogoutUrl = () => {
  const { domain, clientId, redirectUri } = awsConfig.cognito;
  const params = new URLSearchParams({
    client_id: clientId,
    logout_uri: redirectUri,
  });
  return `https://${domain}/logout?${params.toString()}`;
};

export const parseCallbackCode = () => {
  // FIX: globalThis en lugar de window
  const params = new URLSearchParams(globalThis.location.search);
  return params.get("code");
};