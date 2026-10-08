const express = require("express");

const router = express.Router();

const {
  createTask,
  getProjectTasks,
  getTask,
  updateTask,
  deleteTask,
} = require("../controllers/taskController");

const authMiddleware = require("../middleware/authMiddleware");

// Get all tasks for a project
router.get(
  "/projects/:projectId/tasks",
  authMiddleware,
  getProjectTasks
);

// Create task inside a project
router.post(
  "/projects/:projectId/tasks",
  authMiddleware,
  createTask
);

// Get single task
router.get(
  "/tasks/:id",
  authMiddleware,
  getTask
);

// Update task
router.put(
  "/tasks/:id",
  authMiddleware,
  updateTask
);

// Delete task
router.delete(
  "/tasks/:id",
  authMiddleware,
  deleteTask
);

module.exports = router;