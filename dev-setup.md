# Development Setup Guide (Phase 4)

## Purpose

This document explains how to initialize the project repositories and set up the development environment for backend and frontend work.

---

# Repository Structure

Create 3 repositories:

1. `ecommerce-backend`
2. `ecommerce-frontend-store`
3. `ecommerce-frontend-admin`

---

# Git Strategy

Branches:

- `main` -> production
- `dev` -> integration
- `feature/*` -> development

Rules:

- No direct push to `main`
- PR required for merging
- Code review mandatory

---

# Backend Setup (NestJS)

## 1. Create Project

Install Nest CLI:

```bash
npm install -g @nestjs/cli
```

Create the project:

```bash
nest new ecommerce-backend
```

### Windows Notes for Nest CLI

If `nest` is not recognized after global install:

1. Confirm the npm global bin path exists:

```powershell
Get-ChildItem "$env:APPDATA\npm\nest*"
```

2. Add the npm global bin folder to your user `PATH`:

```powershell
[Environment]::SetEnvironmentVariable(
  "Path",
  [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\Users\<your-user>\AppData\Roaming\npm",
  "User"
)
```

3. Close the terminal completely and open a new one.

4. In PowerShell, if execution policy blocks the script shim, use:

```powershell
nest.cmd new ecommerce-backend
```

You can also run Nest without relying on the global command:

```bash
npx @nestjs/cli new ecommerce-backend
```

---

## 2. Install Core Dependencies

```bash
npm install @prisma/client prisma
npm install @nestjs/config
npm install class-validator class-transformer
npm install bcrypt jsonwebtoken
npm install ioredis
```

---

## 3. Initialize Prisma

```bash
npx prisma init
```

This creates:

- `prisma/schema.prisma`
- `prisma.config.ts`

Important:

- Use `npx prisma ...`, not `prisma ...`
- `prisma` is usually not installed globally

Example:

```bash
npx prisma db pull
npx prisma migrate dev --name init
npx prisma generate
```

### Common Prisma CLI Mistake

This is wrong:

```bash
npx prisma migrate dev --beplayground init
```

Use:

```bash
npx prisma migrate dev --name init
```

---

## 4. Environment File (`.env`)

For a normal local PostgreSQL database:

```env
DATABASE_URL="postgresql://postgres:your_password@localhost:5432/ecommerce"
JWT_SECRET=your_secret
REDIS_HOST=localhost
REDIS_PORT=6379
```

Notes:

- Do not commit `.env`
- Add `.env` to `.gitignore`
- Replace `your_password` and database name with real values

### Prisma Local Dev URL vs Normal PostgreSQL URL

Prisma may generate a `prisma+postgres://...` URL during initialization. That is different from a normal PostgreSQL connection string.

Use `prisma+postgres://...` only if you intentionally want Prisma-managed local dev database tooling.

Use this format when connecting to your own local PostgreSQL server:

```env
DATABASE_URL="postgresql://postgres:your_password@localhost:5432/ecommerce"
```

---

## 5. Prisma Configuration

If `prisma.config.ts` contains:

```ts
import "dotenv/config";

export default defineConfig({
  datasource: {
    url: process.env["DATABASE_URL"],
  },
});
```

Then Prisma reads the database URL from `.env` through `prisma.config.ts`.

In that case, this datasource block in `schema.prisma` is valid:

```prisma
datasource db {
  provider = "postgresql"
}
```

You do not need to repeat `url = env("DATABASE_URL")` inside `schema.prisma` when Prisma is already configured through `prisma.config.ts`.

---

## 6. Define Prisma Models

After `prisma init`, the schema is incomplete until models are added.

Example initial schema:

```prisma
generator client {
  provider = "prisma-client"
  output   = "../generated/prisma"
}

datasource db {
  provider = "postgresql"
}

model Tenant {
  id        String   @id @default(uuid())
  name      String
  domain    String?
  createdAt DateTime @default(now())
  users     User[]
}

model User {
  id        String   @id @default(uuid())
  email     String   @unique
  password  String
  tenantId  String
  tenant    Tenant   @relation(fields: [tenantId], references: [id])
  createdAt DateTime @default(now())
}
```

After adding models:

```bash
npx prisma migrate dev --name init
npx prisma generate
```

If the database already exists and you want Prisma to read its structure:

```bash
npx prisma db pull
```

---

## 7. PostgreSQL Setup Notes

Make sure PostgreSQL is installed and running locally on port `5432`.

Typical local credentials used in training or old sample projects may look like:

- user: `postgres`
- host: `localhost`
- port: `5432`

Do not assume an old sample password is still correct for your current machine. Always verify against your local PostgreSQL installation.

### If You Forgot the PostgreSQL Password

PostgreSQL does not expose the current password in plaintext.

If the password is forgotten, reset it:

1. Open `pg_hba.conf`
2. Temporarily change local host authentication from `scram-sha-256` to `trust`
3. Restart PostgreSQL service
4. Connect using `psql`
5. Run:

```sql
ALTER USER postgres WITH PASSWORD 'NewStrongPassword123';
```

6. Restore `pg_hba.conf` back to `scram-sha-256`
7. Restart PostgreSQL again

Do not leave `trust` enabled after the reset.

---

## 8. Start Dev Server

```bash
npm run start:dev
```

---

# Frontend Setup (React + Vite + TypeScript)

## 1. Create Apps

Storefront:

```bash
npx -y create-vite@latest ecommerce-storefront --template react-ts
cd ecommerce-storefront
npm install
```

Admin:

```bash
npx -y create-vite@latest ecommerce-admin --template react-ts
cd ecommerce-admin
npm install
```

### Windows Notes

If `npx` is not recognized due to execution policy, use `npx.cmd` instead:

```powershell
npx.cmd -y create-vite@latest ecommerce-storefront --template react-ts
```

---

## 2. Install Dependencies

In each frontend project:

```bash
npm install axios react-router-dom
npm install -D tailwindcss @tailwindcss/postcss postcss prettier vitest jsdom @testing-library/react @testing-library/jest-dom
```

---

## 3. Configure TailwindCSS

Create `postcss.config.js`:

```js
export default {
  plugins: {
    '@tailwindcss/postcss': {},
  },
};
```

Add to the top of `src/index.css`:

```css
@import "tailwindcss";
```

---

## 4. Configure Vitest

Update `vite.config.ts`:

```ts
/// <reference types="vitest" />
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './src/setupTests.ts',
  },
})
```

Create `src/setupTests.ts`:

```ts
import '@testing-library/jest-dom';
```

---

# Auth Strategy

- JWT-based authentication
- Store token in local storage
- Attach token in API requests

---

# Frontend Environment Config

Create `.env` in each frontend project:

Storefront:

```env
VITE_API_URL=http://localhost:3100
```

Admin:

```env
VITE_API_URL=http://localhost:3000
```

Access in code:

```ts
const apiUrl = import.meta.env.VITE_API_URL;
```

---

# Basic Test Setup

Backend:

- Jest (default with NestJS)

Frontend:

- Vitest + React Testing Library

---

# Shared Library (`mtse-shared/`)

A local package shared between both frontends. Linked via `npm install mtse-shared@file:../mtse-shared`.

## Modules

| Module | Purpose |
|---|---|
| `api/` | Axios client factory + typed CRUD helpers |
| `auth/` | Token storage, role/permission checks |
| `forms/` | Config-driven form field definitions |
| `tables/` | Config-driven table column builder |
| `routing/` | Route config builder + guards |
| `validation/` | Zod schema builder from field rules |
| `types/` | Shared DTOs (User, Product, Order, etc.) |
| `constants/` | Roles, statuses, error messages |

## Usage

```ts
import { createApiClient, createApiService } from 'mtse-shared/api';
import { createFormConfig } from 'mtse-shared/forms';
import { ROLES } from 'mtse-shared/constants';
```

---

# Frontend Folder Structure

```
src/
├── app/                    # App bootstrap (App, Providers, Router)
├── components/
│   ├── ui/                 # Shadcn/ui base components
│   ├── layout/             # Shell, Header, Sidebar, Footer
│   └── common/             # Shared components (Loader, ErrorBoundary)
├── config/                 # Environment config, constants
├── features/               # Feature modules (domain-driven)
│   └── [feature]/
│       ├── components/     # Feature-specific components
│       ├── hooks/          # Feature-specific hooks
│       ├── services/       # API service functions
│       ├── types/          # Feature types
│       ├── utils/          # Feature utilities
│       └── index.ts        # Public barrel export
├── hooks/                  # Global custom hooks
├── lib/                    # Third-party wrappers (api, utils)
├── services/               # Global API services
├── stores/                 # Zustand state stores
├── types/                  # Global TypeScript types
└── utils/                  # Global utility functions
```

---

# Code Generation Script

Generate files from templates:

```bash
npm run generate component Button
npm run generate feature products
npm run generate page Dashboard
npm run generate service auth
npm run generate hook Cart
```

Each command creates the file + test + barrel export in the correct directory.

---

# Additional Frontend Dependencies

```bash
npm install zustand zod clsx tailwind-merge class-variance-authority
npm install mtse-shared@file:../mtse-shared
```

---

# Optional (Recommended Later)

Docker setup in a later phase:

- PostgreSQL container
- Redis container

---

# Rules

- Do not skip Prisma setup
- Do not hardcode configs
- Follow module structure strictly
- Use DTO validation in backend
- Keep secrets only in `.env`

---

# Next Step

After setup:

- Implement Auth Module
- Implement Tenant Module
- Implement Product Module

---

# Done When

- Backend runs successfully
- Database connection works
- Prisma migrations or introspection run successfully
- Frontend connects to backend
