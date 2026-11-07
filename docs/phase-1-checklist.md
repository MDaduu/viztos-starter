# Phase 1 checklist

- [ ] Install Node.js 20+ and npm
- [ ] Create / sign in to Cloudflare account
- [ ] Run `npx wrangler login`
- [ ] Create D1 database `viztos-db`
- [ ] Copy the real D1 database ID into `worker/wrangler.toml`
- [ ] Create R2 bucket `viztos-documents`
- [ ] Install root, frontend, and worker dependencies
- [ ] Apply local D1 migration
- [ ] Run Worker and frontend locally
- [ ] Verify `/api/health`
- [ ] Verify four seeded services in local D1
- [ ] Create Pages project and configure production API URL
- [ ] Deploy Worker and Pages after environment review
