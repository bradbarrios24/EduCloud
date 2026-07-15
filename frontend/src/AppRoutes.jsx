import { useEffect } from "react";
import { Routes, Route, useNavigate, useLocation } from "react-router-dom";
import { useAuth } from "./context/AuthContext";
import Navbar from "./components/Navbar";
import ProtectedRoute from "./components/ProtectedRoute";
import Home from "./pages/Home";
import Dashboard from "./pages/Dashboard";
import Cursos from "./pages/Cursos";
import Evaluaciones from "./pages/Evaluaciones";
import Login from "./pages/Login";

export default function AppRoutes() {
  const { handleAuthCallback } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    const params = new URLSearchParams(location.search);
    const code = params.get("code");
    if (code) {
      handleAuthCallback(code).then((ok) => {
        globalThis.history.replaceState({}, "", location.pathname);
        if (ok) navigate("/dashboard");
      });
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <>
      <Navbar />
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/login" element={<Login />} />
        <Route path="/dashboard" element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
        <Route path="/cursos" element={<ProtectedRoute><Cursos /></ProtectedRoute>} />
        <Route path="/evaluaciones" element={<ProtectedRoute><Evaluaciones /></ProtectedRoute>} />
      </Routes>
    </>
  );
}