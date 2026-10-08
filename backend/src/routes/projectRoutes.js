const express = require("express");

const {
  createProject,
  getProjects,
  getProject,
  updateProject,
  deleteProject,
} = require("../controllers/projectController");

const {
  createTask,
  getProjectTasks,
} = require("../controllers/taskController");

const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();


// ============================================
// All project routes require authentication
// ============================================

router.use(authMiddleware);


// ============================================
// PROJECT ROUTES
// ============================================

router.post("/", createProject);

router.get("/", getProjects);

router.get("/:id", getProject);

router.put("/:id", updateProject);

router.delete("/:id", deleteProject);


// ============================================
// TASKS INSIDE PROJECT
// ============================================

router.post("/:projectId/tasks", createTask);

router.get("/:projectId/tasks", getProjectTasks);


module.exports = router;