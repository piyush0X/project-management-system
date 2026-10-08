import {
  useEffect,
  useState,
} from "react";

import {
  useNavigate,
  useParams,
} from "react-router-dom";

import {
  ArrowLeft,
  Plus,
  Search,
  Pencil,
  Trash2,
  CheckCircle,
  Circle,
  X,
} from "lucide-react";

import api from "../services/api";

const initialForm = {
  name: "",
  description: "",
  priority: "Medium",
  status: "Pending",
  due_date: "",
};

export default function ProjectDetails() {
  const { projectId } = useParams();

  const navigate = useNavigate();

  // ==========================================
  // PROJECT
  // ==========================================

  const [project, setProject] = useState(null);

  // ==========================================
  // TASKS
  // ==========================================

  const [tasks, setTasks] = useState([]);

  // ==========================================
  // LOADING
  // ==========================================

  const [loading, setLoading] = useState(true);

  const [tasksLoading, setTasksLoading] = useState(true);

  // ==========================================
  // ERROR
  // ==========================================

  const [error, setError] = useState("");

  // ==========================================
  // SEARCH / FILTER
  // ==========================================

  const [search, setSearch] = useState("");

  const [status, setStatus] = useState("");

  const [priority, setPriority] = useState("");

  // ==========================================
  // TASK FORM
  // ==========================================

  const [showForm, setShowForm] = useState(false);

  const [editingTask, setEditingTask] = useState(null);

  const [form, setForm] = useState(initialForm);

  const [saving, setSaving] = useState(false);

  const [deletingId, setDeletingId] = useState(null);

  // ==========================================
  // LOAD PROJECT
  // ==========================================

  async function loadProject() {
    try {
      setLoading(true);

      const response = await api.get(
        `/projects/${projectId}`
      );

      // FIX:
      // Backend returns:
      // {
      //   success: true,
      //   data: {
      //     project: {...}
      //   }
      // }

      setProject(response.data.data.project);

    } catch (error) {
      console.error("Load project error:", error);

      setError(
        error.response?.data?.message ||
        "Unable to load project."
      );

      setProject(null);

    } finally {
      setLoading(false);
    }
  }

  // ==========================================
  // LOAD TASKS
  // ==========================================

  async function loadTasks() {
  try {
    setTasksLoading(true);

    const params = new URLSearchParams();

    if (search.trim()) {
      params.append("search", search.trim());
    }

    if (status) {
      params.append("status", status);
    }

    if (priority) {
      params.append("priority", priority);
    }

    const query = params.toString();

    const url = query
      ? `/projects/${projectId}/tasks?${query}`
      : `/projects/${projectId}/tasks`;

    const response = await api.get(url);

    // Backend may return:
    // { data: { tasks: [...] } }
    // or { data: [...] }
    // or directly [...]
    const responseData = response.data;

    let taskList = [];

    if (Array.isArray(responseData)) {
      taskList = responseData;
    } else if (Array.isArray(responseData?.data?.tasks)) {
      taskList = responseData.data.tasks;
    } else if (Array.isArray(responseData?.data)) {
      taskList = responseData.data;
    } else if (Array.isArray(responseData?.tasks)) {
      taskList = responseData.tasks;
    }

    setTasks(taskList);
  } catch (error) {
    console.error("Load tasks error:", error);

    setError(
      error.response?.data?.message ||
        "Unable to load tasks."
    );

    setTasks([]);
  } finally {
    setTasksLoading(false);
  }
}



  // ==========================================
  // INITIAL LOAD
  // ==========================================

  useEffect(() => {
    if (!projectId) {
      return;
    }

    loadProject();
    loadTasks();
  }, [projectId]);

  // ==========================================
  // FILTER CHANGE
  // ==========================================

  useEffect(() => {
    if (!projectId) {
      return;
    }

    loadTasks();
  }, [status, priority]);

  // ==========================================
  // SEARCH
  // ==========================================

  function handleSearch(event) {
    event.preventDefault();

    loadTasks();
  }

  // ==========================================
  // FORM INPUT
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

  // ==========================================
  // CREATE FORM
  // ==========================================

  function openCreateForm() {
    setEditingTask(null);

    setForm(initialForm);

    setShowForm(true);

    setError("");
  }

  // ==========================================
  // EDIT FORM
  // ==========================================

  function openEditForm(task) {
    setEditingTask(task);

    setForm({
      name: task.name || "",

      description:
        task.description || "",

      priority:
        task.priority || "Medium",

      status:
        task.status || "Pending",

      due_date:
        task.due_date
          ? task.due_date.substring(0, 10)
          : "",
    });

    setShowForm(true);

    setError("");
  }

  // ==========================================
  // CLOSE FORM
  // ==========================================

  function closeForm() {
    if (saving) {
      return;
    }

    setShowForm(false);

    setEditingTask(null);

    setForm(initialForm);
  }

  // ==========================================
  // CREATE / UPDATE TASK
  // ==========================================

  async function handleSubmit(event) {
    event.preventDefault();

    setError("");

    if (!form.name.trim()) {
      setError(
        "Task name is required."
      );

      return;
    }

    try {
      setSaving(true);

      if (editingTask) {
        await api.put(
          `/tasks/${editingTask.id}`,
          {
            name: form.name,

            description: form.description,

            priority: form.priority,

            status: form.status,

            due_date:
              form.due_date || null,
          }
        );
      } else {
        await api.post(
          `/projects/${projectId}/tasks`,
          {
            project_id: Number(projectId),

            name: form.name,

            description: form.description,

            priority: form.priority,

            status: form.status,

            due_date:
              form.due_date || null,
          }
        );
      }

      closeForm();

      await loadTasks();

    } catch (error) {
      setError(
        error.response?.data?.message ||
        "Unable to save task."
      );

    } finally {
      setSaving(false);
    }
  }

  // ==========================================
  // DELETE TASK
  // ==========================================

  async function handleDelete(task) {
    const confirmed = window.confirm(
      `Delete "${task.name}"?`
    );

    if (!confirmed) {
      return;
    }

    try {
      setDeletingId(task.id);

      setError("");

      await api.delete(
        `/tasks/${task.id}`
      );

      await loadTasks();

    } catch (error) {
      setError(
        error.response?.data?.message ||
        "Unable to delete task."
      );

    } finally {
      setDeletingId(null);
    }
  }

  // ==========================================
  // COMPLETE TASK
  // ==========================================

  async function handleComplete(task) {
    try {
      setError("");

      await api.put(
        `/tasks/${task.id}`,
        {
          name: task.name,

          description:
            task.description || "",

          priority:
            task.priority,

          status:
            "Completed",

          due_date:
            task.due_date
              ? task.due_date.substring(0, 10)
              : null,
        }
      );

      await loadTasks();

    } catch (error) {
      setError(
        error.response?.data?.message ||
        "Unable to complete task."
      );
    }
  }

  // ==========================================
  // LOADING PROJECT
  // ==========================================

  if (loading) {
    return (
      <div className="page">
        <div className="loading">
          Loading project...
        </div>
      </div>
    );
  }

  // ==========================================
  // PROJECT NOT FOUND
  // ==========================================

  if (!project) {
    return (
      <div className="page">
        <div className="alert error">
          Project could not be found.
        </div>

        <button
          className="secondary-button"
          onClick={() =>
            navigate("/projects")
          }
        >
          Back to Projects
        </button>
      </div>
    );
  }

  return (
    <div className="page">

      {/* ====================================
          BACK
      ==================================== */}

      <button
        className="back-button"
        onClick={() =>
          navigate("/projects")
        }
      >
        <ArrowLeft size={18} />
        Back to Projects
      </button>

      {/* ====================================
          PROJECT HEADER
      ==================================== */}

      <div className="project-details-header">
        <div>
          <div className="project-title-row">
            <h1>
              {project.name}
            </h1>

            <span
              className={`status-badge ${getProjectStatusClass(
                project.status
              )}`}
            >
              {project.status}
            </span>
          </div>

          <p>
            {project.description ||
              "No description provided."}
          </p>
        </div>
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
          TASK HEADER
      ==================================== */}

      <div className="page-header task-header">
        <div>
          <h2>
            Tasks
          </h2>

          <p>
            Manage tasks for this project.
          </p>
        </div>

        <button
          className="primary-button"
          onClick={openCreateForm}
        >
          <Plus size={18} />
          New Task
        </button>
      </div>

      {/* ====================================
          FILTERS
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
              placeholder="Search tasks..."
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

          <option value="Pending">
            Pending
          </option>

          <option value="In Progress">
            In Progress
          </option>

          <option value="Completed">
            Completed
          </option>
        </select>

        <select
          value={priority}
          onChange={(event) =>
            setPriority(event.target.value)
          }
        >
          <option value="">
            All priorities
          </option>

          <option value="Low">
            Low
          </option>

          <option value="Medium">
            Medium
          </option>

          <option value="High">
            High
          </option>
        </select>

      </div>

      {/* ====================================
          TASK LIST
      ==================================== */}

      {tasksLoading ? (
        <div className="loading">
          Loading tasks...
        </div>

      ) : tasks.length === 0 ? (

        <div className="empty-state">
          <Circle
            size={40}
            color="#9ca3af"
          />

          <h3>
            No tasks found
          </h3>

          <p>
            Create your first task for this
            project.
          </p>

          <button
            className="primary-button"
            onClick={openCreateForm}
          >
            <Plus size={18} />
            Create Task
          </button>
        </div>

      ) : (

        <div className="tasks-list">

          {tasks.map((task) => (

            <div
              className="task-card"
              key={task.id}
            >

              {/* Task left side */}

              <div className="task-main">

                <div className="task-name-row">

                  {task.status === "Completed" ? (
                    <CheckCircle
                      size={21}
                      className="completed-icon"
                    />
                  ) : (
                    <Circle size={21} />
                  )}

                  <h3>
                    {task.name}
                  </h3>

                </div>

                <p className="task-description">
                  {task.description ||
                    "No description provided."}
                </p>

                <div className="task-meta">

                  <span
                    className={`priority-badge ${getPriorityClass(
                      task.priority
                    )}`}
                  >
                    {task.priority}
                  </span>

                  <span
                    className={`task-status-badge ${getTaskStatusClass(
                      task.status
                    )}`}
                  >
                    {task.status}
                  </span>

                  {task.due_date && (
                    <span className="due-date">
                      Due:{" "}
                      {formatDate(
                        task.due_date
                      )}
                    </span>
                  )}

                </div>

              </div>

              {/* Task actions */}

              <div className="task-actions">

                {task.status !== "Completed" && (
                  <button
                    className="icon-button complete-button"
                    onClick={() =>
                      handleComplete(task)
                    }
                  >
                    <CheckCircle size={17} />
                    Complete
                  </button>
                )}

                <button
                  className="icon-button"
                  onClick={() =>
                    openEditForm(task)
                  }
                >
                  <Pencil size={17} />
                  Edit
                </button>

                <button
                  className="icon-button danger"
                  disabled={
                    deletingId === task.id
                  }
                  onClick={() =>
                    handleDelete(task)
                  }
                >
                  <Trash2 size={17} />

                  {deletingId === task.id
                    ? "Deleting..."
                    : "Delete"}
                </button>

              </div>

            </div>

          ))}

        </div>
      )}

      {/* ====================================
          TASK FORM MODAL
      ==================================== */}

      {showForm && (

        <div className="modal-overlay">

          <div className="modal">

            <div className="modal-header">

              <div>

                <h2>
                  {editingTask
                    ? "Edit Task"
                    : "Create Task"}
                </h2>

                <p>
                  Add task details below.
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
                Task Name *
              </label>

              <input
                name="name"
                type="text"
                placeholder="Enter task name"
                value={form.name}
                onChange={handleInputChange}
              />

              <label>
                Description
              </label>

              <textarea
                name="description"
                rows="4"
                placeholder="Describe the task..."
                value={form.description}
                onChange={handleInputChange}
              />

              <label>
                Priority
              </label>

              <select
                name="priority"
                value={form.priority}
                onChange={handleInputChange}
              >
                <option value="Low">
                  Low
                </option>

                <option value="Medium">
                  Medium
                </option>

                <option value="High">
                  High
                </option>
              </select>

              <label>
                Status
              </label>

              <select
                name="status"
                value={form.status}
                onChange={handleInputChange}
              >
                <option value="Pending">
                  Pending
                </option>

                <option value="In Progress">
                  In Progress
                </option>

                <option value="Completed">
                  Completed
                </option>
              </select>

              <label>
                Due Date
              </label>

              <input
                name="due_date"
                type="date"
                value={form.due_date}
                onChange={handleInputChange}
              />

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
                    : editingTask
                      ? "Update Task"
                      : "Create Task"}
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

function getProjectStatusClass(status) {
  switch (status) {
    case "Completed":
      return "completed";

    case "In Progress":
      return "in-progress";

    default:
      return "not-started";
  }
}

function getPriorityClass(priority) {
  switch (priority) {
    case "High":
      return "high";

    case "Low":
      return "low";

    default:
      return "medium";
  }
}

function getTaskStatusClass(status) {
  switch (status) {
    case "Completed":
      return "completed";

    case "In Progress":
      return "in-progress";

    default:
      return "pending";
  }
}