using LibPQ, JSON3, SQLStrings
using ..Agents: trigger_type_to_string, agent_state_to_string, Agent, AgentState

function insert_agent(
    agent::Agent,
)
    conn = get_connection()

    LibPQ.execute(conn, "BEGIN")
    try
        _insert_agent_proper(agent, conn)
        _insert_agent_tools(agent, conn)

        LibPQ.execute(conn, "COMMIT")
    catch e
        LibPQ.execute(conn, "ROLLBACK")
        rethrow(e)
    end
end


function delete_agent(
    agent_id::String,
)
    conn = get_connection()
    query = SQLStrings.sql`
        DELETE FROM agents WHERE id = $agent_id
    `
    LibPQ.execute(conn, query)
end

function update_agent_state(
    agent_id::String,
    new_state::AgentState,
)
    conn = get_connection()
    new_state_str = agent_state_to_string(new_state)
    query = SQLStrings.sql`
        UPDATE agents SET state = $new_state_str WHERE id = $agent_id
    `
    LibPQ.execute(conn, query)
end


function _insert_agent_proper(
    agent::Agent,
    conn::LibPQ.Connection,
)
    agent_id = agent.id
    agent_name = agent.name
    agent_description = agent.description
    strategy_name = agent.strategy.metadata.name
    strategy_config = JSON3.write(struct_to_dict(agent.strategy.config))
    trigger_type = trigger_type_to_string(agent.trigger.type)
    trigger_params = JSON3.write(struct_to_dict(agent.trigger.params))
    agent_state = agent_state_to_string(agent.state)

    query = SQLStrings.sql`
        INSERT INTO agents (
            id,
            name,
            description,
            strategy,
            strategy_config,
            trigger_type,
            trigger_params,
            state
        ) VALUES (
            $agent_id,
            $agent_name,
            $agent_description,
            $strategy_name,
            $strategy_config,
            $trigger_type,
            $trigger_params,
            $agent_state
        )
    `

    LibPQ.execute(conn, query)
end

function _insert_agent_tools(
    agent::Agent,
    conn::LibPQ.Connection,
)
    agent_id = agent.id

    for (index, tool) in enumerate(agent.context.tools)
        tool_name = tool.metadata.name
        tool_config = JSON3.write(struct_to_dict(tool.config))

        query = SQLStrings.sql`
            INSERT INTO agent_tools (agent_id, tool_index, tool_name, tool_config)
            VALUES ($agent_id, $index, $tool_name, $tool_config)
        `

        LibPQ.execute(conn, query)
    end
end