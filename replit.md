# Hadramout Wallet

An Express API for registering Hadramout Wallet users with unique wallet IDs and initial multi-currency balances.

## Run & Operate

- `pnpm --filter @workspace/api-server run dev` — run the API server (port 5000)
- `pnpm run typecheck` — full typecheck across all packages
- `pnpm run build` — typecheck + build all packages
- `pnpm --filter @workspace/api-spec run codegen` — regenerate API hooks and Zod schemas from the OpenAPI spec
- `pnpm --filter @workspace/db run push` — push DB schema changes (dev only)
- Required env: `DATABASE_URL` — Postgres connection string

## Stack

- pnpm workspaces, Node.js 24, TypeScript 5.9
- API: Express 5
- DB: PostgreSQL + Drizzle ORM
- Validation: Zod (`zod/v4`), `drizzle-zod`
- API codegen: Orval (from OpenAPI spec)
- Build: esbuild (CJS bundle)

## Where things live

- `artifacts/api-server/src/routes/users.ts` — wallet user registration endpoint and wallet ID generation.
- `artifacts/api-server/src/routes/health.ts` — health check endpoint.
- `lib/api-spec/openapi.yaml` — source of truth for the API contract.
- `lib/api-zod/src/generated/` and `lib/api-client-react/src/generated/` — generated API schemas and client helpers.

## Architecture decisions

- Wallet IDs use Node's cryptographic random number generator and an in-process set to avoid collisions during the server lifetime.
- Registration starts YER, SAR, USD, and USDT at numeric zero.
- Registration data is held in process memory because this project does not currently have a configured database connection.

## Product

- Register a wallet user through `POST /api/users/register`.
- Return a generated wallet ID in `HW-XXXXXX` format and initial balances for all supported currencies.

## User preferences

No additional preferences recorded.

## Gotchas

- In-memory registrations and issued IDs reset when the API process restarts.
- Run API contract codegen after changing `lib/api-spec/openapi.yaml`.

## Pointers

- See the `pnpm-workspace` skill for workspace structure, TypeScript setup, and package details
