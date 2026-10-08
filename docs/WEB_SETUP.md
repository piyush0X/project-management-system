# Web Setup

```powershell
cd C:\Users\piyus\Desktop\project-management-system\web
npm install
```

Create `.env`:

```env
VITE_API_URL=http://localhost:5000/api
```

Run:

```powershell
npm run dev
```

Build:

```powershell
npm run build
npm run preview
```

Production API:

```env
VITE_API_URL=https://project-management-backend-sg3k.onrender.com/api
```

`web/vercel.json` provides SPA route rewriting for React Router.
