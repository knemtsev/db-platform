CREATE SCHEMA IF NOT EXISTS db AUTHORIZATION kernel;
CREATE SCHEMA IF NOT EXISTS kernel AUTHORIZATION kernel;
CREATE SCHEMA IF NOT EXISTS oauth2 AUTHORIZATION kernel;
CREATE SCHEMA IF NOT EXISTS api AUTHORIZATION kernel;
CREATE SCHEMA IF NOT EXISTS rest AUTHORIZATION kernel;
CREATE SCHEMA IF NOT EXISTS daemon AUTHORIZATION kernel;

CREATE EXTENSION IF NOT EXISTS pgcrypto SCHEMA kernel;

GRANT USAGE ON SCHEMA kernel TO administrator;
GRANT USAGE ON SCHEMA api TO administrator;
GRANT USAGE ON SCHEMA rest TO administrator;
GRANT USAGE ON SCHEMA daemon TO daemon;
GRANT USAGE ON SCHEMA api TO apibot;
GRANT USAGE ON SCHEMA daemon TO apibot;
GRANT USAGE ON SCHEMA rest TO apibot;
