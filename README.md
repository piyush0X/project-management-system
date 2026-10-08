# Project Management System

A full-stack project management application with a React web application, Flutter Android application, Node.js/Express REST API, and PostgreSQL database.

The web and mobile applications use the same backend and database, allowing users to access the same account, projects, and tasks across platforms.

---

## Features

### Authentication

- User registration
- User login
- User logout
- JWT-based authentication
- Password hashing using bcrypt
- Protected API routes
- JWT token expiry
- Secure token storage in the mobile application

### Project Management

- Create projects
- View projects
- Edit projects
- Delete projects
- Project status:
  - Not Started
  - In Progress
  - Completed
- Project start and end dates
- Project search
- Project status filtering

### Task Management

- Create tasks for projects
- View tasks
- Edit tasks
- Delete tasks
- Task status:
  - Pending
  - In Progress
  - Completed
- Task priority:
  - Low
  - Medium
  - High
- Task due dates
- Task search
- Task status filtering
- Task priority filtering

### Dashboard

- Total projects
- Completed projects
- Projects in progress
- Projects not started
- Total tasks
- Completed tasks
- Pending tasks
- Tasks in progress

### Mobile Features

- Flutter Android application
- Same backend and database as web
- Login and registration
- Dashboard
- Project management
- Task management
- Search and filtering
- Pull-to-refresh
- Secure token storage
- Token expiry handling
- Offline/network error handling
- Dark/light theme
- Logout

---

# Technology Stack

## Frontend Web

- React
- Vite
- React Router
- Axios
- CSS

## Mobile

- Flutter
- Dart
- HTTP
- Flutter Secure Storage

## Backend

- Node.js
- Express.js
- JWT
- bcryptjs
- Zod
- express-rate-limit
- CORS

## Database

- PostgreSQL

## Deployment

- Vercel — Web frontend
- Render — Backend
- Render PostgreSQL — Database

---

# Project Structure

```text
project-management-system/
│
├── backend/
│   ├── database/
│   │   └── schema.sql
│   │
│   ├── src/
│   │   ├── config/
│   │   ├── controllers/
│   │   ├── middleware/
│   │   ├── routes/
│   │   ├── services/
│   │   └── db/
│   │
│   ├── init-db.js
│   ├── server.js
│   ├── package.json
│   └── .env
│
├── web/
│   ├── src/
│   │   ├── components/
│   │   ├── context/
│   │   ├── pages/
│   │   ├── services/
│   │   ├── App.jsx
│   │   ├── main.jsx
│   │   └── styles.css
│   │
│   ├── public/
│   ├── package.json
│   └── vercel.json
│
├── mobile/
│   ├── lib/
│   │   ├── config/
│   │   ├── models/
│   │   ├── services/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── utils/
│   │
│   ├── android/
│   ├── pubspec.yaml
│   └── ...
│
└── README.md