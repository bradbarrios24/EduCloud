import { useState } from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Navbar from "./components/Navbar";
import Home from "./pages/Home";
import Dashboard from "./pages/Dashboard";
import Cursos from "./pages/Cursos";
import Login from "./components/Login";
import "./styles/App.css";

export default function App() {
  const [user, setUser] = useState(() => {
    const saved = sessionStorage.getItem("educloud_user");
    return saved ? JSON.parse(saved) : null;
  });

  const handleLogin = (userData) => {
    setUser(userData);
    sessionStorage.setItem("educloud_user", JSON.stringify(userData));
  };

  const handleLogout = () => {
    setUser(null);
    sessionStorage.removeItem("educloud_user");
  };

  return (
    <BrowserRouter>
      <Navbar user={user} onLogout={handleLogout} />
      <Routes>
        <Route path="/"          element={<Home />} />
        <Route path="/cursos"    element={<Cursos />} />
        <Route path="/login"     element={<Login user={user} onLogin={handleLogin} />} />
        <Route path="/dashboard" element={<Dashboard user={user} />} />
      </Routes>
    </BrowserRouter>
  );
}