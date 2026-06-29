-- PostfixMgr Database Schema + Seed Data

-- Virtual Domains
CREATE TABLE IF NOT EXISTS virtual_domains (
    domain      VARCHAR(255) PRIMARY KEY,
    is_active   BOOLEAN      NOT NULL DEFAULT true,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Virtual Mailboxes
CREATE TABLE IF NOT EXISTS virtual_mailboxes (
    email       VARCHAR(255) PRIMARY KEY,
    domain      VARCHAR(255) NOT NULL REFERENCES virtual_domains(domain) ON DELETE CASCADE,
    local_part  VARCHAR(255) NOT NULL,
    password    VARCHAR(512) NOT NULL,
    is_active   BOOLEAN      NOT NULL DEFAULT true,
    quota_mb    INT          NOT NULL DEFAULT 1024,
    used_mb     INT          NOT NULL DEFAULT 0,
    forward_to  VARCHAR(255),
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login  TIMESTAMP
);

-- Virtual Aliases
CREATE TABLE IF NOT EXISTS virtual_aliases (
    source      VARCHAR(255) NOT NULL,
    destination VARCHAR(255) NOT NULL,
    is_active   BOOLEAN      NOT NULL DEFAULT true,
    comment     VARCHAR(512),
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (source, destination)
);

-- Mail Logs
CREATE TABLE IF NOT EXISTS mail_logs (
    id          VARCHAR(36)  PRIMARY KEY,
    timestamp   TIMESTAMP    NOT NULL,
    level       VARCHAR(10)  NOT NULL,
    process     VARCHAR(100),
    message     TEXT         NOT NULL,
    queue_id    VARCHAR(50),
    from_addr   VARCHAR(255),
    to_addr     VARCHAR(255),
    status      VARCHAR(50),
    delay_secs  INT,
    host        VARCHAR(255),
    ip          VARCHAR(50)
);

-- Access Rules
CREATE TABLE IF NOT EXISTS access_rules (
    pattern     VARCHAR(255) PRIMARY KEY,
    action      VARCHAR(50)  NOT NULL,
    list_type   VARCHAR(20)  NOT NULL,
    match_type  VARCHAR(20)  NOT NULL,
    reason      VARCHAR(512),
    is_active   BOOLEAN      NOT NULL DEFAULT true,
    expires_at  TIMESTAMP,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Seed: Domains
INSERT INTO virtual_domains (domain, is_active, created_at) VALUES
  ('example.com',   true,  NOW() - INTERVAL '30 days'),
  ('company.org',   true,  NOW() - INTERVAL '15 days'),
  ('test.net',      false, NOW() - INTERVAL '5 days')
ON CONFLICT DO NOTHING;

-- Seed: Mailboxes (password: $6$... is SHA-512 hash of "password123")
INSERT INTO virtual_mailboxes (email, domain, local_part, password, is_active, quota_mb, used_mb, created_at, last_login) VALUES
  ('admin@example.com',   'example.com', 'admin',   '$6$rounds=65536$salt$hashed_pw_placeholder', true,  2048, 312,  NOW() - INTERVAL '30 days', NOW() - INTERVAL '2 hours'),
  ('alice@example.com',   'example.com', 'alice',   '$6$rounds=65536$salt$hashed_pw_placeholder', true,  1024, 87,   NOW() - INTERVAL '25 days', NOW() - INTERVAL '1 day'),
  ('bob@example.com',     'example.com', 'bob',     '$6$rounds=65536$salt$hashed_pw_placeholder', true,  1024, 450,  NOW() - INTERVAL '20 days', NOW() - INTERVAL '3 hours'),
  ('info@company.org',    'company.org', 'info',    '$6$rounds=65536$salt$hashed_pw_placeholder', true,  4096, 1200, NOW() - INTERVAL '15 days', NOW() - INTERVAL '30 minutes'),
  ('support@company.org', 'company.org', 'support', '$6$rounds=65536$salt$hashed_pw_placeholder', true,  4096, 2100, NOW() - INTERVAL '10 days', NOW() - INTERVAL '5 hours')
ON CONFLICT DO NOTHING;

-- Seed: Aliases
INSERT INTO virtual_aliases (source, destination, is_active, comment, created_at) VALUES
  ('postmaster@example.com', 'admin@example.com',   true,  'RFC required postmaster alias', NOW() - INTERVAL '30 days'),
  ('abuse@example.com',      'admin@example.com',   true,  'RFC required abuse alias',      NOW() - INTERVAL '30 days'),
  ('noreply@example.com',    '/dev/null',            true,  'Discard noreply',               NOW() - INTERVAL '20 days'),
  ('contact@company.org',    'info@company.org',     true,  'Contact form destination',      NOW() - INTERVAL '15 days'),
  ('help@company.org',       'support@company.org',  true,  'Help desk alias',               NOW() - INTERVAL '10 days')
ON CONFLICT DO NOTHING;

-- Seed: Access Rules
INSERT INTO access_rules (pattern, action, list_type, match_type, reason, is_active, created_at) VALUES
  ('192.168.0.0/16',        'PERMIT', 'whitelist', 'network', 'Internal network',          true, NOW() - INTERVAL '30 days'),
  ('trusted-relay.com',     'PERMIT', 'whitelist', 'domain',  'Trusted mail relay',        true, NOW() - INTERVAL '20 days'),
  ('45.89.12.0/24',         'REJECT', 'blacklist', 'network', 'Known spam network',        true, NOW() - INTERVAL '10 days'),
  ('spammer@hotmail.com',   'REJECT', 'blacklist', 'email',   'Persistent spammer',        true, NOW() - INTERVAL '5 days'),
  ('spam-domain.ru',        'REJECT', 'blacklist', 'domain',  'Spam domain',               true, NOW() - INTERVAL '3 days')
ON CONFLICT DO NOTHING;
