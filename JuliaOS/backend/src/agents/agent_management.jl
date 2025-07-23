using .CommonTypes: Agent, AgentBlueprint, AgentContext, AgentState, InstantiatedTool, InstantiatedStrategy, CommonTypes
using ...Resources: Errors

const AGENTS = Dict{String, Agent}()

function register_agent(agent::Agent)
    agent_id = agent.id
    if haskey(AGENTS, agent_id)
        error("Agent with ID '$agent_id' already exists.")
    end

    AGENTS[agent_id] = agent
end

function create_agent(
    id::String,
    name::String,
    description::String,
    blueprint::AgentBlueprint,
)::Agent
    # Check if the agent with the given ID already exists
    if haskey(AGENTS, id)
        error("Agent with ID '$id' already exists.")
    end

    # Instantiate tools from the blueprint
    tools = Vector{InstantiatedTool}()
    for tool_blueprint in blueprint.tools
        tool = instantiate_tool(tool_blueprint)
        push!(tools, tool)
    end

    # Create the agent context
    context = AgentContext(
        tools,
        Vector{String}()
    )

    # Create the instantiated strategy
    strategy = instantiate_strategy(blueprint.strategy)

    # Create the agent
    agent = Agent(
        id,
        name,
        description,
        context,
        strategy,
        blueprint.trigger,
        CommonTypes.CREATED_STATE
    )

    register_agent(agent)

    return agent
end

function delete_agent(
    id::String,
)::Nothing
    # Check if the agent with the given ID exists
    if !haskey(AGENTS, id)
        error("Agent with ID '$id' does not exist.")
    end

    # TODO: we currently have no mechanism of checking if the agent strategy is currently executing.

    # Remove the agent from the registry
    delete!(AGENTS, id)

    return nothing
end

function set_agent_state(
    agent::Agent,
    new_state::AgentState,
)
    # All transitions are allowed, except transitions to CREATED and transitions from STOPPED:
    if (agent.state == CommonTypes.STOPPED_STATE)
        error("Agent with ID '$(agent.id)' is already STOPPED.")
    elseif (new_state == CommonTypes.CREATED_STATE)
        error("Agents cannot be explicitly set to CREATED state.")
    end

    agent.state = new_state

    return nothing
end

function run(
    agent::Agent,
    input::Any=nothing,
)
    if agent.state != CommonTypes.RUNNING_STATE
        error("Agent with ID '$(agent.id)' is not in RUNNING state.")
    end

    @info "Executing strategy of agent $(agent.id)"
    strat = agent.strategy
    if strat.input_type === nothing
        return strat.run(strat.config, agent.context, input)
    end

    if !isa(input, AbstractDict)
        throw(Errors.InvalidPayload("Expected JSON object matching $(strat.input_type)"))
    end

    input_obj = try
        deserialize_object(strat.input_type, Dict{String,Any}(input))
    catch e
        if isa(e, UndefKeywordError)
            throw(Errors.InvalidPayload(
                "Missing field '$(e.var)' for $(strat.input_type)"))
        elseif isa(e, ArgumentError)
            throw(Errors.InvalidPayload(
                "Bad value in payload: $(e.msg)"))
        else
            throw(Errors.InvalidPayload(
                "Cannot convert payload to $(strat.input_type): $(e)"))
        end
    end

    return strat.run(strat.config, agent.context, input_obj)
end

function initialize(
    agent::Agent,
)
    if agent.state != CommonTypes.CREATED_STATE
        error("Agent with ID '$(agent.id)' is not in CREATED state.")
    end

    @info "Initializing strategy of agent $(agent.id)"
    if agent.strategy.initialize !== nothing
        return agent.strategy.initialize(agent.strategy.config, agent.context)
    else
        return nothing
    end
end