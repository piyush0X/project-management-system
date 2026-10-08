import { NavLink, Outlet, useNavigate } from "react-router-dom";
import {
  LayoutDashboard,
  FolderKanban,
  LogOut,
} from "lucide-react";

import { useAuth } from "../context/AuthContext";

export default function Layout() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  async function handleLogout() {
    await logout();
    navigate("/login", { replace: true });
  }

  return (
    <div className="app-layout">

      <header className="navbar">

        <div className="navbar-brand">
          Project Manager
        </div>

        <nav className="navbar-links">

          <NavLink
            to="/dashboard"
            className={({ isActive }) =>
              isActive
                ? "nav-link active"
                : "nav-link"
            }
          >
            <LayoutDashboard size={18} />
            <span>Dashboard</span>
          </NavLink>

          <NavLink
            to="/projects"
            className={({ isActive }) =>
              isActive
                ? "nav-link active"
                : "nav-link"
            }
          >
            <FolderKanban size={18} />
            <span>Projects</span>
          </NavLink>

        </nav>

        <div className="navbar-user">

          <span className="user-name">
            {user?.full_name}
          </span>

          <button
            type="button"
            className="logout-button"
            onClick={handleLogout}
          >
            <LogOut size={17} />
            <span>Logout</span>
          </button>

        </div>

      </header>

      <main>
        <Outlet />
      </main>

    </div>
  );
}