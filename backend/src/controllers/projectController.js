const { z } = require("zod");
const pool = require("../config/db");

const projectSchema = z.object({
  name: z
    .string()
    .trim()
    .min(1, "Project name is required")
    .max(150, "Project name must not exceed 150 characters"),

  description: z
    .string()
    .trim()
    .max(5000, "Description must not exceed 5000 characters")
    .optional()
    .nullable(),

  status: z
    .enum(["Not Started", "In Progress", "Completed"])
    .default("Not Started"),

  start_date: z
    .string()
    .optional()
    .nullable(),

  end_date: z
    .string()
    .optional()
    .nullable(),
});


// ============================================
// CREATE PROJECT
// POST /api/projects
// ============================================
async function createProject(req, res) {
  try {
    const validation = projectSchema.safeParse(req.body);

    if (!validation.success) {
      return res.status(400).json({
        success: false,
        message: "Validation failed",
        errors: validation.error.issues.map(
          (issue) => issue.message
        ),
      });
    }

    const {
      name,
      description,
      status,
      start_date,
      end_date,
    } = validation.data;

    // Make sure end date is not before start date
    if (start_date && end_date && end_date < start_date) {
      return res.status(400).json({
        success: false,
        message: "End date cannot be before start date",
      });
    }

    const result = await pool.query(
      `
      INSERT INTO projects
      (
        user_id,
        name,
        description,
        status,
        start_date,
        end_date
      )
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING
        id,
        user_id,
        name,
        description,
        status,
        start_date,
        end_date,
        created_at
      `,
      [
        req.user.userId,
        name,
        description || null,
        status,
        start_date || null,
        end_date || null,
      ]
    );

    return res.status(201).json({
      success: true,
      message: "Project created successfully",
      data: {
        project: result.rows[0],
      },
    });
  } catch (error) {
    console.error("Create project error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
}


// ============================================
// GET ALL PROJECTS
// GET /api/projects
//
// Supports:
// ?search=project
// ?status=Completed
// ============================================
async function getProjects(req, res) {
  try {
    const { search, status } = req.query;

    const conditions = [
      "user_id = $1",
    ];

    const values = [
      req.user.userId,
    ];

    let parameterIndex = 2;

    // Search by project name
    if (search && search.trim() !== "") {
      conditions.push(
        `name ILIKE $${parameterIndex}`
      );

      values.push(
        `%${search.trim()}%`
      );

      parameterIndex++;
    }

    // Filter by status
    if (status) {
      const allowedStatuses = [
        "Not Started",
        "In Progress",
        "Completed",
      ];

      if (!allowedStatuses.includes(status)) {
        return res.status(400).json({
          success: false,
          message: "Invalid project status",
        });
      }

      conditions.push(
        `status = $${parameterIndex}`
      );

      values.push(status);

      parameterIndex++;
    }

    const query = `
      SELECT
        id,
        user_id,
        name,
        description,
        status,
        start_date,
        end_date,
        created_at
      FROM projects
      WHERE ${conditions.join(" AND ")}
      ORDER BY created_at DESC
    `;

    const result = await pool.query(
      query,
      values
    );

    return res.status(200).json({
      success: true,
      data: {
        projects: result.rows,
      },
    });

  } catch (error) {
    console.error(
      "Get projects error:",
      error
    );

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
}


// ============================================
// GET SINGLE PROJECT
// GET /api/projects/:id
// ============================================
async function getProject(req, res) {
  try {
    const projectId = Number(req.params.id);

    if (!Number.isInteger(projectId) || projectId <= 0) {
      return res.status(400).json({
        success: false,
        message: "Invalid project ID",
      });
    }

    const result = await pool.query(
      `
      SELECT
        id,
        user_id,
        name,
        description,
        status,
        start_date,
        end_date,
        created_at
      FROM projects
      WHERE id = $1
      AND user_id = $2
      `,
      [
        projectId,
        req.user.userId,
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Project not found",
      });
    }

    return res.status(200).json({
      success: true,
      data: {
        project: result.rows[0],
      },
    });

  } catch (error) {
    console.error(
      "Get project error:",
      error
    );

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
}


// ============================================
// UPDATE PROJECT
// PUT /api/projects/:id
// ============================================
async function updateProject(req, res) {
  try {
    const projectId = Number(req.params.id);

    if (!Number.isInteger(projectId) || projectId <= 0) {
      return res.status(400).json({
        success: false,
        message: "Invalid project ID",
      });
    }

    const validation = projectSchema.safeParse(req.body);

    if (!validation.success) {
      return res.status(400).json({
        success: false,
        message: "Validation failed",
        errors: validation.error.issues.map(
          (issue) => issue.message
        ),
      });
    }

    const {
      name,
      description,
      status,
      start_date,
      end_date,
    } = validation.data;

    // Validate dates
    if (start_date && end_date && end_date < start_date) {
      return res.status(400).json({
        success: false,
        message: "End date cannot be before start date",
      });
    }

    const result = await pool.query(
      `
      UPDATE projects
      SET
        name = $1,
        description = $2,
        status = $3,
        start_date = $4,
        end_date = $5
      WHERE id = $6
      AND user_id = $7
      RETURNING
        id,
        user_id,
        name,
        description,
        status,
        start_date,
        end_date,
        created_at
      `,
      [
        name,
        description || null,
        status,
        start_date || null,
        end_date || null,
        projectId,
        req.user.userId,
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Project not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Project updated successfully",
      data: {
        project: result.rows[0],
      },
    });

  } catch (error) {
    console.error(
      "Update project error:",
      error
    );

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
}


// ============================================
// DELETE PROJECT
// DELETE /api/projects/:id
// ============================================
async function deleteProject(req, res) {
  try {
    const projectId = Number(req.params.id);

    if (!Number.isInteger(projectId) || projectId <= 0) {
      return res.status(400).json({
        success: false,
        message: "Invalid project ID",
      });
    }

    const result = await pool.query(
      `
      DELETE FROM projects
      WHERE id = $1
      AND user_id = $2
      RETURNING id
      `,
      [
        projectId,
        req.user.userId,
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Project not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Project deleted successfully",
    });

  } catch (error) {
    console.error(
      "Delete project error:",
      error
    );

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
}


// ============================================
// EXPORT CONTROLLERS
// ============================================
module.exports = {
  createProject,
  getProjects,
  getProject,
  updateProject,
  deleteProject,
};