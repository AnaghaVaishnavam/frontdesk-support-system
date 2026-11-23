# Frontdesk — Support Operations

A full-stack support ticket management application built for the Arvo Systems hiring assessment.

## Stack
- React + Vite frontend
- Node.js + Express REST API
- PostgreSQL database
- JWT authentication and bcrypt password hashing

## Features
- Agent sign-in and ticket dashboard
- Create, search, filter and inspect support tickets
- Atomic ticket claiming to prevent two agents taking the same unassigned ticket
- Priority-based SLA targets using Monday–Friday, 09:30–18:30 working hours
- Configurable public holidays through `HOLIDAYS` (comma-separated `YYYY-MM-DD`)
- Waiting-on-customer state pauses SLA clocks; paused business minutes are added back when the ticket leaves that state
- Public customer replies and separate internal notes
- Internal notes are returned only to authenticated agent endpoints; there is no customer-facing API
- Append-only activity history (application has no edit/delete endpoint for audit records)
- Reopen resolved tickets within seven calendar days

## SLA assumptions
The assessment describes approximate targets. This implementation interprets them as:
- Urgent: first reply within 2 working hours; resolution within the same working day (9 working hours).
- Medium: first reply within half a working day (4.5 working hours); resolution within 3 working days (27 working hours).
- Small: first reply within 1 working day (9 working hours); resolution within 1 working week (45 working hours).

Changing priority recalculates both deadlines from the time of the change. This is an explicit implementation assumption because the brief asks what happens when a ticket becomes urgent but does not prescribe the answer. Public holidays are supplied in the `HOLIDAYS` environment variable. Reopening window is seven calendar days. Auto-close after one working week without customer response is not run as a background job in this MVP; agents can set a ticket to Closed manually. This is documented as unfinished rather than silently implied.

## Run locally

Requirements: Node.js 18+ and PostgreSQL 14+.

1. Create a PostgreSQL database named `frontdesk`.
2. Copy `.env.example` to `.env` and set `DATABASE_URL` and a strong `JWT_SECRET`.
3. Install dependencies:
   ```bash
   npm install
   ```
4. Start the app (the server initializes the schema and demo data automatically on first startup):
   ```bash
   npm run dev
   ```
6. Open `http://localhost:5173`.

### Demo login
- Email: `alex@frontdesk.demo`
- Password: `Frontdesk@123`

Change demo credentials and secret before any production use.

## API overview
- `GET /api/health`
- `POST /api/auth/login`
- `GET /api/me`
- `GET /api/tickets`
- `POST /api/tickets`
- `GET /api/tickets/:id`
- `POST /api/tickets/:id/take`
- `PATCH /api/tickets/:id`
- `POST /api/tickets/:id/messages`
- `GET /api/agents`
- `GET /api/metrics`

All ticket, agent, message and activity endpoints require a bearer token.

## Deploy on Render
1. Push this repository to GitHub.
2. Create a PostgreSQL database on Render and copy its internal connection string.
3. Create a Web Service from the repository.
4. Build command: `npm install && npm run build`
5. Start command: `npm start`
6. Add `DATABASE_URL`, `JWT_SECRET`, `NODE_ENV=production` and optionally `HOLIDAYS`.
7. The server creates the tables and demo data automatically on first startup. Open the service URL and test the demo login. Keep the service and database active for the evaluation week.

## Known limitations / honest scope note
This is a time-boxed assessment MVP. The one-working-week no-customer-response auto-close scheduler, outbound email delivery, customer portal, role-based admin management, and comprehensive automated test suite are not implemented. SLA priority changes recalculate targets from the change time; this policy is stated here because the brief leaves it open. Audit rows are append-only through the application API, but production database permissions/backups should additionally restrict direct database mutation. Configure local public holidays using `HOLIDAYS`.
