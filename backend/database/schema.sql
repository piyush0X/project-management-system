-- ============================================
-- PROJECT MANAGEMENT SYSTEM DATABASE SCHEMA
-- ============================================

-- ============================================
-- USERS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ============================================
-- PROJECTS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS projects (
    id SERIAL PRIMARY KEY,

    user_id INTEGER NOT NULL,

    name VARCHAR(255) NOT NULL,
    description TEXT,

    status VARCHAR(50) NOT NULL DEFAULT 'Not Started'
        CHECK (status IN ('Not Started', 'In Progress', 'Completed')),

    start_date DATE,
    end_date DATE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_projects_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);


-- ============================================
-- TASKS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS tasks (
    id SERIAL PRIMARY KEY,

    project_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,

    name VARCHAR(255) NOT NULL,
    description TEXT,

    priority VARCHAR(20) NOT NULL DEFAULT 'Medium'
        CHECK (priority IN ('Low', 'Medium', 'High')),

    status VARCHAR(50) NOT NULL DEFAULT 'Pending'
        CHECK (status IN ('Pending', 'In Progress', 'Completed')),

    due_date DATE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_tasks_project
        FOREIGN KEY (project_id)
        REFERENCES projects(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_tasks_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);


-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX IF NOT EXISTS idx_projects_user_id
ON projects(user_id);

CREATE INDEX IF NOT EXISTS idx_tasks_project_id
ON tasks(project_id);

CREATE INDEX IF NOT EXISTS idx_tasks_user_id
ON tasks(user_id);

CREATE INDEX IF NOT EXISTS idx_users_email
ON users(email);


-- ============================================
-- END OF SCHEMA
-- ============================================