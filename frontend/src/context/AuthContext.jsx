import PropTypes from "prop-types";
import { createContext, useContext, useEffect, useState, useCallback } from "react";
import { decodeJwt } from "../utils/jwt";
import {
  redirectToLogin,
  redirectToLogout,
  exchangeCodeForTokens,
  getRoleFromGroups,
} from "../services/auth";

const AuthContext = createContext(null);
const STORAGE_KEY = "educloud_session";

function buildUserFromIdToken(idToken) {
  const payload = decodeJwt(idToken);
  if (!payload) return null;
  const groups = payload["cognito:groups"] || [];
  return {
    email: payload.email,
    name: payload.name || payload.email,
    groups,
    role: getRoleFromGroups(groups),
    sub: payload.sub,
  };
}

export function AuthProvider({ children }) {
  const [session, setSession] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const raw = sessionStorage.getItem(STORAGE_KEY);
    if (raw) {
      try {
        const parsed = JSON.parse(raw);
        if (parsed.expiresAt > Date.now()) {
          setSession(parsed);
        } else {
          sessionStorage.removeItem(STORAGE_KEY);
        }
      } catch {
        sessionStorage.removeItem(STORAGE_KEY);
      }
    }
    setLoading(false);
  }, []);

  const handleAuthCallback = useCallback(async (code) => {
    setLoading(true);
    try {
      const tokens = await exchangeCodeForTokens(code);
      const user = buildUserFromIdToken(tokens.id_token);
      const newSession = {
        idToken: tokens.id_token,
        accessToken: tokens.access_token,
        refreshToken: tokens.refresh_token,
        expiresAt: Date.now() + tokens.expires_in * 1000,
        user,
      };
      sessionStorage.setItem(STORAGE_KEY, JSON.stringify(newSession));
      sessionStorage.removeItem("pkce_verifier");
      setSession(newSession);
      return true;
    } catch (err) {
      console.error("Error en el login:", err);
      return false;
    } finally {
      setLoading(false);
    }
  }, []);

  const login = useCallback(() => {
    redirectToLogin();
  }, []);

  // FUNCIÓN DE LOGOUT que pediste
  const logout = useCallback(() => {
    sessionStorage.removeItem(STORAGE_KEY);
    setSession(null);
    redirectToLogout();
  }, []);

  const value = {
    user: session?.user || null,
    idToken: session?.idToken || null,
    loading,
    login,
    logout,
    handleAuthCallback,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

AuthProvider.propTypes = {
  children: PropTypes.node.isRequired,
};

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth debe usarse dentro de <AuthProvider>");
  return ctx;
}