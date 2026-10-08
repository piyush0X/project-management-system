# Database Schema

The Project Management System uses **PostgreSQL** as its relational database.

The database contains three main tables:

- `users`
- `projects`
- `tasks`

## 1. Users Table

The `users` table stores registered user accounts.

| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | SERIAL | Primary Key | Unique user ID |
| `full_name` | VARCHAR(100) | NOT NULL | User's full name |
| `email` | VARCHAR(255) | UNIQUE, NOT NULL | User's login email |
| `password_hash` | TEXT | NOT NULL | Bcrypt-hashed password |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Account creation time |

### Important constraints

- `id` is the primary key.
- `email` must be unique.
- The password is stored as a hash, not plain text.

---

## 2. Projects Table

The `projects` table stores projects created by users.

| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | SERIAL | Primary Key | Unique project ID |
| `user_id` | INTEGER | Foreign Key, NOT NULL | User who owns the project |
| `name` | VARCHAR(255) | NOT NULL | Project name |
| `description` | TEXT | Optional | Project description |
| `status` | VARCHAR(50) | NOT NULL, CHECK | Project status |
| `start_date` | DATE | Optional | Project start date |
| `end_date` | DATE | Optional | Project end date |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Project creation time |

### Allowed project statuses

```text
Not Started
In Progress
Completed
```

### Relationship

```text
users.id
    |
    | 1
    |
    | N
    v
projects.user_id
```

One user can own many projects.

---

## 3. Tasks Table

The `tasks` table stores tasks associated with projects.

| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | SERIAL | Primary Key | Unique task ID |
| `project_id` | INTEGER | Foreign Key, NOT NULL | Project containing the task |
| `user_id` | INTEGER | Foreign Key, NOT NULL | User who owns the task |
| `name` | VARCHAR(255) | NOT NULL | Task name |
| `description` | TEXT | Optional | Task description |
| `priority` | VARCHAR(20) | NOT NULL, CHECK | Task priority |
| `status` | VARCHAR(50) | NOT NULL, CHECK | Task status |
| `due_date` | DATE | Optional | Task deadline |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Task creation time |

### Allowed task priorities

```text
Low
Medium
High
```

### Allowed task statuses

```text
Pending
In Progress
Completed
```

---

## 4. Database Relationships

### User → Projects

```text
USERS (1) ────────────< PROJECTS (N)
```

A user can create multiple projects.

Each project belongs to one user through:

```text
projects.user_id → users.id
```

### Project → Tasks

```text
PROJECTS (1) ─────────< TASKS (N)
```

A project can contain multiple tasks.

Each task belongs to one project through:

```text
tasks.project_id → projects.id
```

### User → Tasks

```text
USERS (1) ────────────< TASKS (N)
```

Each task also stores its owning user through:

```text
tasks.user_id → users.id
```

This supports user ownership checks at the backend level.

---

## 5. Foreign Keys

The database uses these foreign-key relationships:

```sql
projects.user_id
    REFERENCES users(id)
    ON DELETE CASCADE
```

```sql
tasks.project_id
    REFERENCES projects(id)
    ON DELETE CASCADE
```

```sql
tasks.user_id
    REFERENCES users(id)
    ON DELETE CASCADE
```

### Cascade behavior

If a user is deleted:

```text
USER
  ↓
PROJECTS
  ↓
TASKS
```

The user's projects and tasks are removed according to the configured foreign-key cascade behavior.

If a project is deleted:

```text
PROJECT
  ↓
TASKS
```

The tasks belonging to that project are also deleted.

---

## 6. Indexes

The database creates indexes for frequently used relationship and lookup columns:

```text
idx_projects_user_id
idx_tasks_project_id
idx_tasks_user_id
idx_users_email
```

These indexes help improve query performance for user/project/task lookups and email-based authentication.

---

## 7. Normalized Structure

The database separates different types of information into related tables:

```text
users
  ↓
projects
  ↓
tasks
```

This avoids storing all user, project and task information in one large table and keeps relationships clear.

---

## 8. Authoritative SQL Schema

The actual SQL schema used by the application is located at:

```text
backend/database/schema.sql
```

The application initializes this schema during backend startup through:

```text
backend/init-db.js
```

This documentation describes the implemented database structure; `backend/database/schema.sql` remains the authoritative database definition.
