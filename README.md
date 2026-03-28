# MTSE — Multi-Tenant Store Engine

A full-stack, multi-tenant e-commerce platform.

## Repository Structure

| Directory | Description | Tech Stack |
|---|---|---|
| `mtse-backend/` | Backend API | NestJS, Prisma, PostgreSQL |
| `mtse-frontend-store/` | Customer storefront | React, Vite, TypeScript |
| `mtse-frontend-admin/` | Admin panel | React, Vite, TypeScript |
| `mtse-shared/` | Shared frontend library | TypeScript, Axios, Zod |

## Quick Start

### Backend

```bash
cd mtse-backend/beplayground
npm install
npm run start:dev
```

### Frontend Store

```bash
cd mtse-frontend-store
npm install
npm run dev
```

### Frontend Admin

```bash
cd mtse-frontend-admin
npm install
npm run dev
```

## Documentation

See [dev-setup.md](./dev-setup.md) for the full development setup guide.

## Architecture

- **Backend**: NestJS with Prisma ORM, JWT authentication, multi-tenant support
- **Frontend**: React 19 + Vite + TypeScript with enterprise folder structure
- **Shared Library**: Config-driven modules for API, forms, tables, auth, routing, validation
- **Styling**: TailwindCSS 4 with Shadcn/ui component support
- **State**: Zustand
- **Testing**: Vitest + React Testing Library (frontend), Jest (backend)
