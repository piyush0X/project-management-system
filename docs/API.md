# API Documentation

Base URL:

```text
https://project-management-backend-sg3k.onrender.com/api
```

Local:

```text
http://localhost:5000/api
```

Protected endpoints use:

```http
Authorization: Bearer <JWT_TOKEN>
```

## Health

`GET /health`

## Authentication

- `POST /auth/register` — create account
- `POST /auth/login` — authenticate and receive JWT
- `POST /auth/logout` — logout authenticated user
- `GET /auth/me` — current authenticated user

## Projects

- `GET /projects` — list current user's projects
- `POST /projects` — create project
- `GET /projects/:id` — get one project
- `PUT /projects/:id` — update project
- `DELETE /projects/:id` — delete project

Example project body:

```json
{
  "name": "Website Project",
  "description": "Build the project management website",
  "status": "Not Started",
  "start_date": "2026-10-08",
  "end_date": "2026-10-20"
}
```

## Tasks

- `GET /projects/:projectId/tasks` — list project tasks
- `POST /projects/:projectId/tasks` — create task
- `GET /tasks/:id` — get task
- `PUT /tasks/:id` — update task
- `DELETE /tasks/:id` — delete task

Task list supports the client filters/search parameters `search`, `status`, and `priority`.

Example task body:

```json
{
  "name": "Create API",
  "description": "Implement project API",
  "priority": "High",
  "status": "Pending",
  "due_date": "2026-10-12"
}
```

## Dashboard

`GET /dashboard` — authenticated user's project/task statistics.

## Common status codes

| Code | Meaning |
|---|---|
| 200 | Successful request |
| 201 | Resource created |
| 400 | Bad request / validation |
| 401 | Missing, invalid or expired authentication |
| 404 | Resource not found |
| 409 | Conflict, such as duplicate email |
| 500 | Internal server error |

## Security

- bcryptjs password hashing
- JWT authentication
- ownership checks
- backend validation
- parameterized PostgreSQL queries
