CREATE TABLE IF NOT EXISTS agents (
 id SERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL, email VARCHAR(180) UNIQUE NOT NULL,
 password_hash TEXT NOT NULL, role VARCHAR(20) NOT NULL DEFAULT 'agent', created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS tickets (
 id BIGSERIAL PRIMARY KEY, ticket_no VARCHAR(24) UNIQUE NOT NULL, subject VARCHAR(220) NOT NULL,
 customer_name VARCHAR(140) NOT NULL, customer_email VARCHAR(180) NOT NULL, description TEXT NOT NULL,
 priority VARCHAR(20) NOT NULL CHECK(priority IN ('urgent','medium','small')),
 status VARCHAR(30) NOT NULL DEFAULT 'open' CHECK(status IN ('open','in_progress','waiting_customer','resolved','closed')),
 assigned_to INTEGER REFERENCES agents(id), created_by INTEGER REFERENCES agents(id),
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 first_response_at TIMESTAMPTZ, resolved_at TIMESTAMPTZ, waiting_since TIMESTAMPTZ,
 sla_reply_due TIMESTAMPTZ, sla_resolve_due TIMESTAMPTZ, reopened_at TIMESTAMPTZ
);
CREATE TABLE IF NOT EXISTS messages (
 id BIGSERIAL PRIMARY KEY, ticket_id BIGINT NOT NULL REFERENCES tickets(id),
 author_id INTEGER REFERENCES agents(id), body TEXT NOT NULL, visibility VARCHAR(20) NOT NULL CHECK(visibility IN ('public','internal')),
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS audit_logs (
 id BIGSERIAL PRIMARY KEY, ticket_id BIGINT NOT NULL REFERENCES tickets(id),
 actor_id INTEGER REFERENCES agents(id), action VARCHAR(80) NOT NULL, details JSONB NOT NULL DEFAULT '{}'::jsonb,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_tickets_status ON tickets(status);
CREATE INDEX IF NOT EXISTS idx_tickets_assigned ON tickets(assigned_to);
CREATE INDEX IF NOT EXISTS idx_messages_ticket ON messages(ticket_id,created_at);
CREATE INDEX IF NOT EXISTS idx_audit_ticket ON audit_logs(ticket_id,created_at);
