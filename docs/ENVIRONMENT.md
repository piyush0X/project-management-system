# Environment Variables

## Backend

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

## Web

```env
VITE_API_URL=http://localhost:5000/api
```

Production:

```env
VITE_API_URL=https://project-management-backend-sg3k.onrender.com/api
```

Never commit real `.env` files, database passwords or JWT secrets.
