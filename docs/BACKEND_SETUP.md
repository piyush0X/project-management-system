# Backend Setup

## Requirements

Node.js, npm, PostgreSQL and Git.

## Setup

```powershell
cd C:\Users\piyus\Desktop\project-management-system\backend
npm install
```

Create `.env`:

```env
PORT=5000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=project_management
DB_USER=postgres
DB_PASSWORD=YOUR_POSTGRES_PASSWORD
JWT_SECRET=YOUR_LONG_RANDOM_SECRET
JWT_EXPIRES_IN=1d
CLIENT_URL=http://localhost:5173
```

Create a PostgreSQL database named `project_management`. On startup the backend initializes the tables from `database/schema.sql`.

Run:

```powershell
npm run dev
```

Test:

```text
http://localhost:5000/health
```
