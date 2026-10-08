import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  Plus,
  Search,
  Pencil,
  Trash2,
  X,
  CalendarDays,
} from "lucide-react";

import api from "../services/api";


const initialForm = {
  name: "",
  description: "",
  status: "Not Started",
  start_date: "",
  end_date: "",
};


export default function Projects() {

  const [projects, setProjects] = useState([]);

  const [loading, setLoading] = useState(true);

  const [error, setError] = useState("");

  const [search, setSearch] = useState("");
  const navigate = useNavigate();

  const [status, setStatus] = useState("");

  const [showForm, setShowForm] = useState(false);

  const [editingProject, setEditingProject] = useState(null);

  const [form, setForm] = useState(initialForm);

  const [saving, setSaving] = useState(false);

  const [deletingId, setDeletingId] = useState(null);


  // ==========================================
  // LOAD PROJECTS
  // ==========================================

  async function loadProjects() {

    try {

      setLoading(true);
      setError("");

      const params = new URLSearchParams();

      if (search.trim()) {
        params.append("search", search.trim());
      }

      if (status) {
        params.append("status", status);
      }

      const queryString = params.toString();

      const url = queryString
        ? `/projects?${queryString}`
        : "/projects";

      const response = await api.get(url);

      setProjects(
        response.data.data.projects
      );

    } catch (error) {

      setError(
        error.response?.data?.message ||
        "Unable to load projects."
      );

    } finally {

      setLoading(false);
    }
  }


  useEffect(() => {
    loadProjects();
  }, [status]);


  // ==========================================
  // SEARCH
  // ==========================================

  function handleSearch(event) {

    event.preventDefault();

    loadProjects();
  }


  // ==========================================
  // FORM
  // ==========================================

  function handleInputChange(event) {

    const {
      name,
      value,
    } = event.target;

    setForm((previous) => ({
      ...previous,
      [name]: value,
    }));
  }


  function openCreateForm() {

    setEditingProject(null);

    setForm(initialForm);

    setShowForm(true);
  }


  function openEditForm(project) {

    setEditingProject(project);

    setForm({
      name: project.name || "",
      description: project.description || "",
      status: project.status || "Not Started",
      start_date: project.start_date
        ? project.start_date.substring(0, 10)
        : "",
      end_date: project.end_date
        ? project.end_date.substring(0, 10)
        : "",
    });

    setShowForm(true);
  }


  function closeForm() {

    if (saving) {
      return;
    }

    setShowForm(false);

    setEditingProject(null);

    setForm(initialForm);
  }


  // ==========================================
  // CREATE / UPDATE
  // ==========================================

  async function handleSubmit(event) {

    event.preventDefault();

    setError("");


    if (!form.name.trim()) {

      setError(
        "Project name is required."
      );

      return;
    }


    if (
      form.start_date &&
      form.end_date &&
      form.end_date < form.start_date
    ) {

      setError(
        "End date cannot be before start date."
      );

      return;
    }


    try {

      setSaving(true);


      if (editingProject) {

        await api.put(
          `/projects/${editingProject.id}`,
          form
        );

      } else {

        await api.post(
          "/projects",
          form
        );

      }


      closeForm();

      await loadProjects();

    } catch (error) {

      setError(
        error.response?.data?.message ||
        "Unable to save project."
      );

    } finally {

      setSaving(false);
    }
  }


  // ==========================================
  // DELETE
  // ==========================================

  async function handleDelete(project) {

    const confirmed =
      window.confirm(
        `Delete "${project.name}"? This will also delete its tasks.`
      );

    if (!confirmed) {
      return;
    }


    try {

      setDeletingId(project.id);

      setError("");

      await api.delete(
        `/projects/${project.id}`
      );

      await loadProjects();

    } catch (error) {

      setError(
        error.response?.data?.message ||
        "Unable to delete project."
      );

    } finally {

      setDeletingId(null);
    }
  }


  return (
    <div className="page">

      {/* ====================================
          HEADER
      ==================================== */}

      <div className="page-header">

        <div>
          <h1>Projects</h1>

          <p>
            Create and manage your projects.
          </p>
        </div>

        <button
          className="primary-button"
          onClick={openCreateForm}
        >
          <Plus size={18} />
          New Project
        </button>

      </div>


      {/* ====================================
          ERROR
      ==================================== */}

      {error && (
        <div className="alert error">
          {error}
        </div>
      )}


      {/* ====================================
          SEARCH + FILTER
      ==================================== */}

      <div className="filters-card">

        <form
          className="search-form"
          onSubmit={handleSearch}
        >

          <div className="search-input-wrapper">

            <Search size={18} />

            <input
              type="text"
              placeholder="Search projects..."
              value={search}
              onChange={(event) =>
                setSearch(event.target.value)
              }
            />

          </div>

          <button
            type="submit"
            className="secondary-button"
          >
            Search
          </button>

        </form>


        <select
          value={status}
          onChange={(event) =>
            setStatus(event.target.value)
          }
        >

          <option value="">
            All statuses
          </option>

          <option value="Not Started">
            Not Started
          </option>

          <option value="In Progress">
            In Progress
          </option>

          <option value="Completed">
            Completed
          </option>

        </select>

      </div>


      {/* ====================================
          PROJECTS
      ==================================== */}

      {loading ? (

        <div className="loading">
          Loading projects...
        </div>

      ) : projects.length === 0 ? (

        <div className="empty-state">

          <h3>
            No projects found
          </h3>

          <p>
            Create your first project to get started.
          </p>

          <button
            className="primary-button"
            onClick={openCreateForm}
          >
            <Plus size={18} />
            Create Project
          </button>

        </div>

      ) : (

        <div className="projects-grid">

          {projects.map((project) => (

            <div
              className="project-card"
              key={project.id}
            >

              <div className="project-card-header">

                <div>

                  <h3>
                    {project.name}
                  </h3>

                  <span
                    className={`status-badge ${getStatusClass(project.status)}`}
                  >
                    {project.status}
                  </span>

                </div>

              </div>


              <p className="project-description">

                {project.description ||
                  "No description provided."}

              </p>


              <div className="project-dates">

                <div>
                  <CalendarDays size={16} />

                  <span>
                    Start:{" "}
                    {formatDate(
                      project.start_date
                    )}
                  </span>
                </div>

                <div>
                  <CalendarDays size={16} />

                  <span>
                    End:{" "}
                    {formatDate(
                      project.end_date
                    )}
                  </span>
                </div>

              </div>


              <div className="project-actions">

  <button
    className="primary-button"
    onClick={() =>
      navigate(`/projects/${project.id}`)
    }
  >
    Open
  </button>

  <button
    className="icon-button"
    onClick={() =>
      openEditForm(project)
    }
  >
    <Pencil size={17} />
    Edit
  </button>

  <button
    className="icon-button danger"
    disabled={
      deletingId === project.id
    }
    onClick={() =>
      handleDelete(project)
    }
  >
    <Trash2 size={17} />

    {deletingId === project.id
      ? "Deleting..."
      : "Delete"}
  </button>

</div>

            </div>

          ))}

        </div>

      )}


      {/* ====================================
          FORM MODAL
      ==================================== */}

      {showForm && (

        <div className="modal-overlay">

          <div className="modal">

            <div className="modal-header">

              <div>

                <h2>
                  {editingProject
                    ? "Edit Project"
                    : "Create Project"}
                </h2>

                <p>
                  Enter your project details.
                </p>

              </div>

              <button
                className="close-button"
                onClick={closeForm}
                disabled={saving}
              >
                <X size={20} />
              </button>

            </div>


            <form
              className="project-form"
              onSubmit={handleSubmit}
            >

              <label>
                Project Name *
              </label>

              <input
                name="name"
                type="text"
                placeholder="Enter project name"
                value={form.name}
                onChange={handleInputChange}
              />


              <label>
                Description
              </label>

              <textarea
                name="description"
                rows="4"
                placeholder="Describe your project..."
                value={form.description}
                onChange={handleInputChange}
              />


              <label>
                Status
              </label>

              <select
                name="status"
                value={form.status}
                onChange={handleInputChange}
              >

                <option value="Not Started">
                  Not Started
                </option>

                <option value="In Progress">
                  In Progress
                </option>

                <option value="Completed">
                  Completed
                </option>

              </select>


              <div className="date-fields">

                <div>

                  <label>
                    Start Date
                  </label>

                  <input
                    name="start_date"
                    type="date"
                    value={form.start_date}
                    onChange={handleInputChange}
                  />

                </div>


                <div>

                  <label>
                    End Date
                  </label>

                  <input
                    name="end_date"
                    type="date"
                    value={form.end_date}
                    onChange={handleInputChange}
                  />

                </div>

              </div>


              <div className="modal-actions">

                <button
                  type="button"
                  className="secondary-button"
                  onClick={closeForm}
                  disabled={saving}
                >
                  Cancel
                </button>

                <button
                  type="submit"
                  className="primary-button"
                  disabled={saving}
                >
                  {saving
                    ? "Saving..."
                    : editingProject
                      ? "Update Project"
                      : "Create Project"}
                </button>

              </div>

            </form>

          </div>

        </div>

      )}

    </div>
  );
}


// ==========================================
// HELPERS
// ==========================================

function formatDate(date) {

  if (!date) {
    return "Not set";
  }

  return new Date(date).toLocaleDateString(
    "en-IN",
    {
      day: "2-digit",
      month: "short",
      year: "numeric",
    }
  );
}


function getStatusClass(status) {

  switch (status) {

    case "Completed":
      return "completed";

    case "In Progress":
      return "in-progress";

    default:
      return "not-started";
  }
}