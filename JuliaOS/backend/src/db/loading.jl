using LibPQ, JSON3, SQLStrings
using ..Agents: string_to_agent_state, string_to_trigger_type, trigger_type_to_params_type, create_agent, set_agent_state
using ..Agents.CommonTypes: TriggerParams, TriggerConfig, AgentBlueprint, ToolBlueprint, StrategyBlueprint, CREATED_STATE

function load_state()
    conn = get_connection()
    _load_agents(conn)
end

function _load_agents(conn::LibPQ.Connection)
    query = SQLStrings.sql`
        SELECT id, name, description, strategy, strategy_config, trigger_type, trigger_params, state
        FROM agents
    `
    result = LibPQ.execute(conn, query)

    for row in result
        agent_id = row.id
        agent_name = row.name
        agent_description = row.description
        strategy_name = row.strategy
        strategy_config = JSON3.read(row.strategy_config, Dict{String, Any})
        trigger_type = string_to_trigger_type(row.trigger_type)
        trigger_params_type = trigger_type_to_params_type(trigger_type)
        trigger_params = trigger_params_type(; JSON3.read(row.trigger_params)...)
        agent_state = string_to_agent_state(row.state)

        tools = _load_agent_tools(conn, agent_id)

        agent_blueprint = AgentBlueprint(
            tools,
            StrategyBlueprint(strategy_name, strategy_config),
            TriggerConfig(trigger_type, trigger_params)
        )

        agent = create_agent(
            agent_id,
            agent_name,
            agent_description,
            agent_blueprint
        )
        if agent_state != CREATED_STATE
            set_agent_state(agent, agent_state)
        end
    end
end

function _load_agent_tools(conn::LibPQ.Connection, agent_id::String)
    query = SQLStrings.sql`
        SELECT tool_index, tool_name, tool_config
        FROM agent_tools
        WHERE agent_id = $agent_id
    `
    result = LibPQ.execute(conn, query)

    tools_dict = Dict{Int, ToolBlueprint}()
    for row in result
        index = row.tool_index
        name = row.tool_name
        config = JSON3.read(row.tool_config, Dict{String, Any})
        tools_dict[index] = ToolBlueprint(name, config)
    end

    tools = to_vector_if_sequential(tools_dict)

    return tools
end