CREATE TYPE agent_state as ENUM (
    'CREATED',
    'RUNNING',
    'PAUSED',
    'STOPPED'
);

CREATE TYPE trigger_type as ENUM (
    'WEBHOOK',
    'PERIODIC'
);

CREATE TABLE agents (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    strategy TEXT NOT NULL,
    strategy_config JSONB,
    trigger_type trigger_type NOT NULL,
    trigger_params JSONB,
    state agent_state NOT NULL DEFAULT 'CREATED'
);

CREATE TABLE agent_tools (
    agent_id TEXT NOT NULL REFERENCES agents(id) ON DELETE CASCADE,
    tool_index INT NOT NULL,
    tool_name TEXT NOT NULL,
    tool_config JSONB,
    PRIMARY KEY (agent_id, tool_index)
);