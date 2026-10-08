const pool = require("../config/db");

// CREATE TASK
const createTask = async (req, res) => {
  try {
    const {
      name,
      description,
      priority,
      status,
      due_date,
    } = req.body;

    // Project ID comes from the URL
    const project_id = req.params.projectId;

    if (!project_id || !name) {
      return res.status(400).json({
        message: "projectId and name are required",
      });
    }

    // Check that the project belongs to the logged-in user
    const projectCheck = await pool.query(
      `SELECT id
       FROM projects
       WHERE id = $1 AND user_id = $2`,
      [project_id, req.user.userId]
    );

    if (projectCheck.rows.length === 0) {
      return res.status(404).json({
        message: "Project not found",
      });
    }

    const result = await pool.query(
      `INSERT INTO tasks
       (project_id, user_id, name, description, priority, status, due_date)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [
        project_id,
        req.user.userId,
        name,
        description || null,
        priority || "Medium",
        status || "Pending",
        due_date || null,
      ]
    );

    res.status(201).json({
      message: "Task created successfully",
      data: {
        task: result.rows[0],
      },
    });
  } catch (error) {
    console.error("Create task error:", error);

    res.status(500).json({
      message: "Failed to create task",
      error: error.message,
    });
  }
};


// GET TASKS FOR A PROJECT
const getProjectTasks = async (req, res) => {
  try {
    const { projectId } = req.params;

    const projectCheck = await pool.query(
      `SELECT id
       FROM projects
       WHERE id = $1 AND user_id = $2`,
      [projectId, req.user.userId]
    );

    if (projectCheck.rows.length === 0) {
      return res.status(404).json({
        message: "Project not found",
      });
    }

    const result = await pool.query(
      `SELECT *
       FROM tasks
       WHERE project_id = $1
       AND user_id = $2
       ORDER BY id DESC`,
      [projectId, req.user.userId]
    );

    res.json({
      message: "Tasks fetched successfully",
      data: result.rows,
    });
  } catch (error) {
    console.error("Get project tasks error:", error);

    res.status(500).json({
      message: "Failed to get project tasks",
      error: error.message,
    });
  }
};


// GET ALL TASKS
const getTasks = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT t.*
       FROM tasks t
       JOIN projects p ON t.project_id = p.id
       WHERE p.user_id = $1
       ORDER BY t.id DESC`,
      [req.user.userId]
    );

    res.json({
      message: "Tasks fetched successfully",
      data: result.rows,
    });
  } catch (error) {
    console.error("Get tasks error:", error);

    res.status(500).json({
      message: "Failed to get tasks",
      error: error.message,
    });
  }
};


// GET SINGLE TASK
const getTask = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `SELECT t.*
       FROM tasks t
       JOIN projects p ON t.project_id = p.id
       WHERE t.id = $1 AND p.user_id = $2`,
      [id, req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        message: "Task not found",
      });
    }

    res.json({
      message: "Task fetched successfully",
      data: {
        task: result.rows[0],
      },
    });
  } catch (error) {
    console.error("Get task error:", error);

    res.status(500).json({
      message: "Failed to get task",
      error: error.message,
    });
  }
};


// UPDATE TASK
const updateTask = async (req, res) => {
  try {
    const { id } = req.params;

    const {
      name,
      description,
      priority,
      status,
      due_date,
    } = req.body;

    const result = await pool.query(
      `UPDATE tasks t
       SET
         name = COALESCE($1, t.name),
         description = COALESCE($2, t.description),
         priority = COALESCE($3, t.priority),
         status = COALESCE($4, t.status),
         due_date = COALESCE($5, t.due_date)
       FROM projects p
       WHERE t.project_id = p.id
       AND t.id = $6
       AND p.user_id = $7
       RETURNING t.*`,
      [
        name,
        description,
        priority,
        status,
        due_date,
        id,
        req.user.userId,
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        message: "Task not found",
      });
    }

    res.json({
      message: "Task updated successfully",
      data: {
        task: result.rows[0],
      },
    });
  } catch (error) {
    console.error("Update task error:", error);

    res.status(500).json({
      message: "Failed to update task",
      error: error.message,
    });
  }
};


// DELETE TASK
const deleteTask = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `DELETE FROM tasks t
       USING projects p
       WHERE t.project_id = p.id
       AND t.id = $1
       AND p.user_id = $2
       RETURNING t.*`,
      [id, req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        message: "Task not found",
      });
    }

    res.json({
      message: "Task deleted successfully",
      data: {
        task: result.rows[0],
      },
    });
  } catch (error) {
    console.error("Delete task error:", error);

    res.status(500).json({
      message: "Failed to delete task",
      error: error.message,
    });
  }
};


module.exports = {
  createTask,
  getProjectTasks,
  getTasks,
  getTask,
  updateTask,
  deleteTask,
};