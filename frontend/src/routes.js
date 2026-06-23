import Home from "./pages/Home";
import Dashboard from "./pages/Dashboard";
import Cursos from "./pages/Cursos";
import Login from "./components/Login";

const routes = (user, onLogin) => [
  { path: "/",          element: <Home /> },
  { path: "/cursos",    element: <Cursos /> },
  { path: "/login",     element: <Login user={user} onLogin={onLogin} /> },
  { path: "/dashboard", element: <Dashboard user={user} /> },
];

export default routes;