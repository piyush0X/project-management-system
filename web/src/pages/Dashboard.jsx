import {
  useEffect,
  useState,
} from "react";

import api from "../services/api";

import { useAuth } from "../context/AuthContext";


export default function Dashboard() {

  const {
    user,
  } = useAuth();


  const [
    dashboard,
    setDashboard,
  ] = useState(null);


  const [
    loading,
    setLoading,
  ] = useState(true);


  const [
    error,
    setError,
  ] = useState("");


  async function loadDashboard() {

    try {

      setLoading(true);
      setError("");

      const response =
        await api.get(
          "/dashboard"
        );

      setDashboard(
        response.data.data
      );

    } catch (error) {

      setError(
        error.response?.data?.message ||
        "Unable to load dashboard."
      );

    } finally {

      setLoading(false);
    }
  }


  useEffect(() => {
    loadDashboard();
  }, []);


  if (loading) {

    return (
      <div className="page">
        <div className="loading">
          Loading dashboard...
        </div>
      </div>
    );
  }


  if (error) {

    return (
      <div className="page">
        <div className="alert error">
          {error}
        </div>
      </div>
    );
  }


  return (
    <div className="page">

      <div className="page-header">

        <div>
          <h1>
            Dashboard
          </h1>

          <p>
            Welcome back,{" "}
            <strong>
              {user?.full_name}
            </strong>
          </p>
        </div>

      </div>


      <div className="stats-grid">

        <div className="stat-card">
          <span>
            Total Projects
          </span>

          <strong>
            {dashboard?.total_projects}
          </strong>
        </div>


        <div className="stat-card">
          <span>
            Total Tasks
          </span>

          <strong>
            {dashboard?.total_tasks}
          </strong>
        </div>


        <div className="stat-card">
          <span>
            Completed Tasks
          </span>

          <strong>
            {dashboard?.completed_tasks}
          </strong>
        </div>


        <div className="stat-card">
          <span>
            Pending Tasks
          </span>

          <strong>
            {dashboard?.pending_tasks}
          </strong>
        </div>


        <div className="stat-card">
          <span>
            Projects In Progress
          </span>

          <strong>
            {dashboard?.in_progress_projects}
          </strong>
        </div>

      </div>

    </div>
  );
}