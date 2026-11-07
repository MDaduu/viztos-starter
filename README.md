# VIZTOS – Cloudflare starter

Starter scaffold for the VIZTOS visa appointment platform.

## Architecture
- `frontend/`: React + TypeScript + Vite (Cloudflare Pages)
- `worker/`: Cloudflare Worker API
- `database/migrations/`: D1 SQL migrations
- R2 bucket binding: private customer document storage (binding configured; upload endpoints are a later phase)

## Requirements
- Node.js 20+
- npm
- Cloudflare account and Wrangler authentication (`npx wrangler login`)

## 1. Install dependencies

From the repository root:

```bash
npm install
npm install --prefix frontend
npm install --prefix worker
```

## 2. Create Cloudflare resources

```bash
npx wrangler d1 create viztos-db
npx wrangler r2 bucket create viztos-documents
```

Copy the `database_id` returned by D1 creation into `worker/wrangler.toml`, replacing `REPLACE_WITH_D1_DATABASE_ID`.

## 3. Apply the initial D1 migration

Local database:

```bash
npm run db:local
```

Remote database (only after reviewing the migration and confirming the target account):

```bash
npm run db:remote
```

## 4. Run locally

Terminal 1 (Worker API):

```bash
npm run dev:worker
```

Terminal 2 (React frontend):

```bash
npm run dev:frontend
```

Open `http://localhost:5173`. The API health endpoint is `http://127.0.0.1:8787/api/health`.

## 5. Deploy

Deploy the Worker:

```bash
npm run deploy:worker
```

Build and deploy the Pages frontend:

```bash
npm run deploy:pages
```

Create the Pages project named `viztos` first if Wrangler asks for it. Configure `VITE_API_BASE_URL` as a Pages build environment variable to point to the deployed Worker API URL.

## Important setup notes
- The D1 database ID must be real; the placeholder intentionally prevents accidental deployment against an unknown database.
- R2 bucket must exist with the exact name `viztos-documents`.
- Configure the frontend API URL for local and production environments.
- Google OAuth, session management, email provider, WhatsApp API, uploads, and booking endpoints are intentionally not implemented in this infrastructure phase.
- Before production, restrict CORS to the exact production origin and implement authenticated sessions, CSRF protections where applicable, authorization checks, upload validation, and atomic booking capacity enforcement.
- The initial migration seeds four services and base roles/settings. Do not use the seeded `owner` role as proof of an administrator identity; the first owner must be provisioned securely in a later setup step.
