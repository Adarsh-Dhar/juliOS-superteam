module JuliaOSV1Server

using HTTP
using JSON3

include("server/src/JuliaOSServer.jl")
include("utils.jl")
include("openapi_server_extensions.jl")
include("validation.jl")

using .JuliaOSServer
using ..JuliaDB
using ..Agents: Agents, Triggers
using ...Resources: Errors

const server = Ref{Any}(nothing)

function ping(::HTTP.Request)
    @info "Triggered endpoint: GET /ping"
    return HTTP.Response(200, "")
end

function create_agent(req::HTTP.Request, create_agent_request::CreateAgentRequest;)::HTTP.Response
    @info "Triggered endpoint: POST /agents"
    @validate_model create_agent_request

    id = create_agent_request.id
    name = create_agent_request.name
    description = create_agent_request.description
    received_blueprint = create_agent_request.blueprint

    tools = Vector{Agents.ToolBlueprint}()
    for tool in received_blueprint.tools
        push!(tools, Agents.ToolBlueprint(tool.name, tool.config))
    end

    trigger_type = Triggers.trigger_name_to_enum(received_blueprint.trigger.type)
    trigger_params = Triggers.process_trigger_params(trigger_type, received_blueprint.trigger.params)

    internal_blueprint = Agents.AgentBlueprint(
        tools,
        Agents.StrategyBlueprint(received_blueprint.strategy.name, received_blueprint.strategy.config),
        Agents.CommonTypes.TriggerConfig(trigger_type, trigger_params)
    )

    agent = Agents.create_agent(id, name, description, internal_blueprint)
    JuliaDB.insert_agent(agent)
    @info "Created agent: $(agent.id) with state: $(agent.state)"
    Agents.initialize(agent)
    agent_summary = summarize(agent)
    return HTTP.Response(201, agent_summary)
end

function delete_agent(req::HTTP.Request, agent_id::String;)::HTTP.Response
    @info "Triggered endpoint: DELETE /agents/$(agent_id)"
    Agents.delete_agent(agent_id)
    JuliaDB.delete_agent(agent_id)
    @info "Deleted agent $(agent_id)"
    return HTTP.Response(204)
end

function update_agent(req::HTTP.Request, agent_id::String, agent_update::AgentUpdate;)::HTTP.Response
    @info "Triggered endpoint: PUT /agents/$(agent_id)"
    @validate_model agent_update

    agent = get(Agents.AGENTS, agent_id) do
        @warn "Attempted update of non-existent agent: $(agent_id)"
        return nothing
    end
    if agent == nothing
        return HTTP.Response(404, "Agent not found")
    end
    new_state = Agents.string_to_agent_state(agent_update.state)
    Agents.set_agent_state(agent, new_state)
    JuliaDB.update_agent_state(agent.id, new_state)
    agent_summary = summarize(agent)
    return HTTP.Response(200, agent_summary)
end

function get_agent(req::HTTP.Request, agent_id::String;)::HTTP.Response
    @info "Triggered endpoint: GET /agents/$(agent_id)"
    agent = get(Agents.AGENTS, agent_id) do
        @warn "Attempt to get non-existent agent: $(agent_id)"
        return nothing
    end
    if agent == nothing
        return HTTP.Response(404, "Agent not found")
    end

    agent_summary = summarize(agent)
    return HTTP.Response(200, agent_summary)
end

function list_agents(req::HTTP.Request;)::Vector{AgentSummary}
    @info "Triggered endpoint: GET /agents"
    agents = Vector{AgentSummary}()
    for (id, agent) in Agents.AGENTS
        push!(agents, summarize(agent))
    end
    return agents
end

function process_agent_webhook(req::HTTP.Request, agent_id::String; request_body::Dict{String,Any}=Dict{String,Any}(),)::HTTP.Response
    @info "Triggered endpoint: POST /agents/$(agent_id)/webhook"
    agent = get(Agents.AGENTS, agent_id) do
        @warn "Attempted webhook trigger of non-existent agent: $(agent_id)"
        return nothing
    end
    if agent == nothing
        return HTTP.Response(404, "Agent not found")
    end
    if agent.trigger.type == Agents.CommonTypes.WEBHOOK_TRIGGER
        try
            if isempty(request_body)
                Agents.run(agent)
            else
                Agents.run(agent, request_body)
            end
            return HTTP.Response(200)
        catch e
            if isa(e, Errors.InvalidPayload)
                return HTTP.Response(400,
                    JSON3.write((error = "invalid_payload", detail = e.msg)))
            else
                @error "Unhandled exception in webhook" exception = (e, catch_backtrace())
                return HTTP.Response(500, JSON3.write((error = "internal_error")))
            end
        end
    end
end

function get_agent_logs(req::HTTP.Request, agent_id::String;)::Union{HTTP.Response, Dict{String, Any}}
    @info "Triggered endpoint: GET /agents/$(agent_id)/logs"
    agent = get(Agents.AGENTS, agent_id) do
        @warn "Attempt to get logs of non-existent agent: $(agent_id)"
        return nothing
    end
    if agent == nothing
        return HTTP.Response(404, "Agent not found")
    end
    # TODO: implement pagination
    return Dict{String, Any}("logs" => agent.context.logs)
end

function get_agent_output(req::HTTP.Request, agent_id::String;)::Dict{String, Any}
    @info "Triggered endpoint: GET /agents/$(agent_id)/output"
    @info "NYI, not actually getting agent $(agent_id) output..."
    return Dict{String, Any}()
end

function list_strategies(req::HTTP.Request;)::Vector{StrategySummary}
    @info "Triggered endpoint: GET /strategies"
    strategies = Vector{StrategySummary}()
    for (name, spec) in Agents.Strategies.STRATEGY_REGISTRY
        push!(strategies, StrategySummary(name))
    end
    return strategies
end

function list_tools(req::HTTP.Request;)::Vector{ToolSummary}
    @info "Triggered endpoint: GET /tools"
    tools = Vector{ToolSummary}()
    for (name, tool) in Agents.Tools.TOOL_REGISTRY
        push!(tools, ToolSummary(name, ToolSummaryMetadata(tool.metadata.description)))
    end
    return tools
end

function run_server(host::AbstractString="0.0.0.0", port::Integer=8052)
    try
        router = HTTP.Router()
        router = JuliaOSServer.register(router, @__MODULE__; path_prefix="/api/v1")
        HTTP.register!(router, "GET", "/ping", ping)
        server[] = HTTP.serve!(router, host, port)
        wait(server[])
    catch ex
        @error("Server error", exception=(ex, catch_backtrace()))
    end
end

end # module JuliaOSV1Server