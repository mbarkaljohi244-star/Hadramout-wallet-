# Hadramout Wallet

An Express API for registering Hadramout Wallet users with unique wallet IDs, secure credentials, and initial multi-currency balances.

## Run & Operate

- `pnpm --filter @workspace/api-server run dev` — run the API server (port 5000)
- `pnpm run typecheck` — full typecheck across all packages
- `pnpm run build` — typecheck + build all packages
- `pnpm --filter @workspace/api-spec run codegen` — regenerate API hooks and Zod schemas from the OpenAPI spec
- `pnpm --filter @workspace/db run push` — push DB schema changes (dev only)
- `cd mobile/hadramout_wallet && flutter pub get` — install Flutter dependencies
- `cd mobile/hadramout_wallet && flutter analyze` — analyze the Flutter client
- `cd mobile/hadramout_wallet && flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api` — run the Android emulator client
- Required env: `DATABASE_URL` — Postgres connection string

## Stack

- pnpm workspaces, Node.js 24, TypeScript 5.9
- API: Express 5
- DB: PostgreSQL + Drizzle ORM
- Validation: Zod (`zod/v4`), `drizzle-zod`
- API codegen: Orval (from OpenAPI spec)
- Build: esbuild (CJS bundle)
- Mobile: Flutter with Arabic RTL Material localization

## Where things live

- `artifacts/api-server/src/routes/users.ts` — wallet user registration endpoint and wallet ID generation.
- `artifacts/api-server/src/lib/auth.ts` — password/PIN hashing and signed wallet JWT handling.
- `artifacts/api-server/src/routes/transfers.ts` — transaction-safe wallet-to-wallet transfers.
- `artifacts/api-server/src/routes/health.ts` — health check endpoint.
- `lib/api-spec/openapi.yaml` — source of truth for the API contract.
- `lib/api-zod/src/generated/` and `lib/api-client-react/src/generated/` — generated API schemas and client helpers.
- `lib/db/src/schema/users.ts` — PostgreSQL wallet user and balance schema.
- `mobile/hadramout_wallet/` — Flutter mobile client with Arabic auth, transfer, and KYC flows.

## Architecture decisions

- Wallet IDs use Node's cryptographic random number generator and a PostgreSQL unique constraint to avoid collisions permanently.
- Registration starts YER, SAR, USD, and USDT at numeric zero.
- Transfers lock both wallet rows in sorted wallet-ID order to prevent races and deadlocks, then commit both balance changes in one database transaction.
- Passwords and PINs use salted scrypt hashes; wallet JWTs are signed with the existing session secret and expire after seven days.

## Product

- Register a wallet user through `POST /api/users/register`.
- Log in with a wallet password through `POST /api/auth/login`.
- Return a generated wallet ID in `HW-XXXXXX` format and initial balances for all supported currencies.
- Transfer funds through `POST /api/transfer` with a matching wallet JWT or valid six-digit PIN, plus validation for supported currencies, positive amounts, wallet existence, and sufficient funds.

## User preferences

No additional preferences recorded.

## Gotchas

- The development database schema is applied with `pnpm --filter @workspace/db run push`.
- Run API contract codegen after changing `lib/api-spec/openapi.yaml`.
- Clerk is available for managed sessions; local wallet JWTs are supported for this API-only flow.
- The Flutter client uses `API_BASE_URL` to reach the local Node API; Android emulators use `10.0.2.2` to reach the host machine.

## Pointers

- See the `pnpm-workspace` skill for workspace structure, TypeScript setup, and package details
