# Expenso (Rails API) + React Frontend

This repo contains:

- Backend: Rails **JSON API** in `Expenso/`
- Frontend: React (Vite) + Tailwind in `expenso-frontend/`

## First run (macOS)

### 1) Backend (Rails API)

```zsh
cd "/Users/maks/Documents/Cloud dev/Expense & Receipt Management SaaS/Expenso"
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

Backend runs on `http://localhost:3000`.

Seed users:

- Employee: `employee@example.com` / `password`
- Manager: `manager@example.com` / `password`

### 2) Frontend (React)

```zsh
cd "/Users/maks/Documents/Cloud dev/Expense & Receipt Management SaaS/expenso-frontend"
npm install
npm run dev
```

Frontend runs on `http://localhost:5173`.

If your backend URL differs, create `.env` from `.env.example` and set `VITE_API_BASE_URL`.

## Auth (token-based)

Frontend uses Bearer token:

- `POST /api/v1/auth/login` → `{ token, user }`
- `GET /api/v1/auth/me`
- `DELETE /api/v1/auth/logout`

All other API calls require:

`Authorization: Bearer <token>`
