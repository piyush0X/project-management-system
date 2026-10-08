# Deployment

## Backend

Platform: Render

```text
https://project-management-backend-sg3k.onrender.com
```

Health:

```text
https://project-management-backend-sg3k.onrender.com/health
```

## Database

Render PostgreSQL database: `project-management-db`.

## Web

Platform: Vercel

```text
https://project-management-system-nine-alpha.vercel.app
```

Vercel API variable:

```env
VITE_API_URL=https://project-management-backend-sg3k.onrender.com/api
```

## Mobile

Production Flutter builds must use the deployed Render API, not `127.0.0.1`.

## Deployment order

1. PostgreSQL
2. Render environment variables
3. Backend
4. `/health` verification
5. Vercel API variable
6. React deployment
7. Flutter production API
8. Release APK
