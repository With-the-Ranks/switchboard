# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```sh
# Development
yarn dev              # Run server once (NODE_ENV=development)
yarn dev:watch        # Run server with file-watching restart

# Testing
yarn test             # Lint + unit tests (full CI suite)
yarn test:unit        # Jest only (NODE_ENV=test, requires switchboard_test DB)
yarn test:lint        # tslint + prettier check only

# Run a single test file
NODE_ENV=test yarn tsnode node_modules/.bin/jest --testPathPattern src/jobs/send-message.spec.ts --forceExit

# Linting / formatting
yarn fix              # Auto-fix tslint + prettier

# Database
yarn bootstrap-db     # Migrate graphile_worker schema + run all db-migrate migrations
yarn migrate          # Run pending db-migrate migrations
yarn remigrate        # Reset + re-run all migrations

# Build
yarn build            # TypeScript compile to dist/
yarn codegen:pg       # Regenerate src/lib/db-types.ts from live DB schema
```

**Important for tests**: Set `TZ=UTC` in `.env` (already in `.env.example`). Tests run against a real `switchboard_test` PostgreSQL database — the global setup teardowns and remigrates it every run. `nock` disables all external HTTP; provider calls must be intercepted via nocks in `src/__tests__/nocks/`.

## Architecture

Switchboard is a multi-tenant SMS routing service that abstracts over Telnyx, Twilio, and Bandwidth. It runs as an Express HTTP server and/or a Graphile Worker background job processor, controlled by the `MODE` env var (`SERVER` | `WORKER` | `DUAL`).

### Data model

The core hierarchy lives in the `sms` PostgreSQL schema:

- **`billing.clients`** — tenants, authenticated via encrypted `access_token` in the `token` HTTP header
- **`sms.profiles`** — a client's sending configuration: which `SendingAccount` to use, traffic channel (`grey-route` | `toll-free` | `10dlc`), reply/status webhooks, purchasing strategy, throughput limits
- **`sms.sending_locations`** — geographic areas (by area code or state) within a profile, each backed by a pool of phone numbers
- **`sms.sending_accounts`** — credentials for a telco provider; a single account can serve multiple profiles

### Telco provider abstraction

`src/lib/services/service.ts` defines the `SwitchboardClient` abstract base class with the full `TelcoMethods` interface. Concrete implementations live in `src/lib/services/` (telnyx, twilio, bandwidth). `getTelcoClient()` in `src/lib/services/index.ts` instantiates the right one based on `sendingAccount.service`. In dev, `DRY_RUN_MODE=true` (the default) routes everything to `BandwidthDryRunService`.

### Message send flow

1. Client calls PostGraphile (`/sms/graphql`) to insert an outbound message into `sms.outbound_messages`
2. A DB trigger enqueues a `process-grey-route-message` / `process-10dlc-message` / `process-toll-free-message` Graphile Worker job
3. The job selects a `from_number` via Redis-backed logic (checks existing mappings, available numbers, or requests a new number purchase)
4. A `send-message` job is enqueued with the resolved `from_number` → calls the telco provider
5. The telco posts delivery reports back to `/hooks/status`; inbound replies arrive at `/hooks/reply`

### Redis

Redis stores phone-number-to-contact assignment state and rate-limit counters. Two custom Lua scripts (`lua/`) implement atomic reads of available numbers and rate-limit updates. In tests, `ioredis-mock` is used automatically. The `src/lib/redis/` module re-exports the three main operations: `getExistingAvailableNumber`, `chooseSendingLocationForContact`, `getExistingPendingRequest`.

### HTTP API surface

| Path | Purpose |
|---|---|
| `/sms/graphql` | PostGraphile — primary client API (SMS sending, profile/location management) |
| `/lookup/graphql` | PostGraphile — phone number lookup/LRN queries |
| `/lookup/json` | REST — single-use phone number lookup |
| `/routing/get-number-for-contact` | REST — resolve from-number for a contact without sending |
| `/hooks/reply` | Webhook receiver — inbound messages from telcos |
| `/hooks/status` | Webhook receiver — delivery reports from telcos |
| `/hooks/bandwidth` | Webhook receiver — Bandwidth-specific events |
| `/admin` | Admin operations (token-gated by `ADMIN_ACCESS_TOKEN`) |

Authentication is via a `token` HTTP header. Client tokens are encrypted with `APPLICATION_SECRET` (using `cryptr`). The PostGraphile endpoints translate the token into a PostgreSQL `role` + `client.id` setting for row-level security.

### Background jobs

All background work runs through [graphile-worker](https://worker.graphile.org/). `src/worker.ts` registers all task handlers and cron schedules. Job implementations live in `src/jobs/`. Each job file exports an `IDENTIFIER` constant and a handler function. The `wrapSwitchboardTask` / `failedJobParker` helpers in `src/lib/worker.ts` add error handling and parking of permanently-failed jobs.

### Database migrations

Migrations use [db-migrate](https://db-migrate.readthedocs.io/) with SQL files, stored in `migrations/`. `database.json` maps `NODE_ENV` to the connection string env var. The graphile-worker internal tables are migrated separately via `yarn migrate:worker`.

### Generated types

`src/lib/db-types.ts` is auto-generated from the live PostgreSQL schema via `yarn codegen:pg`. Do not edit it manually.

## Conventions

- Commits must follow Conventional Commits (enforced by commitlint + husky). Use `yarn commit` for the interactive prompt.
- TypeScript strict mode is not enabled; tslint with `tslint-config-airbnb` is the linter.
- Zod schemas are used for validating job payloads and external API responses; schema names are `PascalCase` with a `Schema` suffix with `// tslint:disable-next-line: variable-name` suppression above each.
