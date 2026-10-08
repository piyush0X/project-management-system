const pool = require("../config/db");

// ============================================
// GET DASHBOARD
// GET /api/dashboard
// ============================================

async function getDashboard(req, res) {
  try {
    const userId = req.user.userId;

    // ----------------------------------------
    // Total projects
    // ----------------------------------------

    const totalProjectsResult = await pool.query(
      `
      SELECT COUNT(*) AS count
      FROM projects
      WHERE user_id = $1
      `,
      [userId]
    );

    // ----------------------------------------
    // Completed projects
    // ----------------------------------------

    const completedProjectsResult = await pool.query(
      `
      SELECT COUNT(*) AS count
      FROM projects
      WHERE user_id = $1
      AND status = 'Completed'
      `,
      [userId]
    );

    // ----------------------------------------
    // Projects in progress
    // ----------------------------------------

    const inProgressProjectsResult = await pool.query(
      `
      SELECT COUNT(*) AS count
      FROM projects
      WHERE user_id = $1
      AND status = 'In Progress'
      `,
      [userId]
    );

    // ----------------------------------------
    // Projects not started
    // ----------------------------------------

    const notStartedProjectsResult = await pool.query(
      `
      SELECT COUNT(*) AS count
      FROM projects
      WHERE user_id = $1
      AND status = 'Not Started'
      `,
      [userId]
    );

    // ----------------------------------------
    // Total tasks
    // ----------------------------------------

    const totalTasksResult = await pool.query(
      `
      SELECT COUNT(*) AS count
      FROM tasks
      WHERE user_id = $1
      `,
      [userId]
    );

    // ----------------------------------------
    // Completed tasks
    // ----------------------------------------

    const completedTasksResult = await pool.query(
      `
      SELECT COUNT(*) AS count
      FROM tasks
      WHERE user_id = $1
      AND status = 'Completed'
      `,
      [userId]
    );

    // ----------------------------------------
    // Pending tasks
    // ----------------------------------------

    const pendingTasksResult = await pool.query(
      `
      SELECT COUNT(*) AS count
      FROM tasks
      WHERE user_id = $1
      AND status = 'Pending'
      `,
      [userId]
    );

    // ----------------------------------------
    // Tasks in progress
    // ----------------------------------------

    const inProgressTasksResult = await pool.query(
      `
      SELECT COUNT(*) AS count
      FROM tasks
      WHERE user_id = $1
      AND status = 'In Progress'
      `,
      [userId]
    );

    // ----------------------------------------
    // RESPONSE
    // ----------------------------------------

    return res.status(200).json({
      success: true,

      data: {
        // Existing fields - KEEPING THEM
        total_projects: Number(
          totalProjectsResult.rows[0].count
        ),

        total_tasks: Number(
          totalTasksResult.rows[0].count
        ),

        completed_tasks: Number(
          completedTasksResult.rows[0].count
        ),

        pending_tasks: Number(
          pendingTasksResult.rows[0].count
        ),

        in_progress_projects: Number(
          inProgressProjectsResult.rows[0].count
        ),

        // New project statistics
        completed_projects: Number(
          completedProjectsResult.rows[0].count
        ),

        not_started_projects: Number(
          notStartedProjectsResult.rows[0].count
        ),

        // New task statistics
        in_progress_tasks: Number(
          inProgressTasksResult.rows[0].count
        ),
      },
    });

  } catch (error) {
    console.error("Dashboard error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
}

module.exports = {
  getDashboard,
};