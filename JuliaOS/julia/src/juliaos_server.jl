module JuliaOSV1Server

using HTTP
using JSON
using UUIDs
using Dates
using DataStructures: OrderedDict, PriorityQueue

include("agents/Config.jl")
using .Config

include("agents/AgentCore.jl")
using .AgentCore: Agent, AgentType, AgentStatus, AgentConfig, SkillState, TaskResult, OrderedDictAgentMemory, PriorityAgentQueue

include("agents/AgentMetrics.jl")
using .AgentMetrics

include("agents/Persistence.jl")
using .Persistence

include("agents/LLMIntegration.jl")
using .LLMIntegration

include("agents/Agents.jl")
using .Agents

@info "AgentType fields: $(fieldnames(AgentType))"

include("api/server/src/JuliaOSServer.jl")

using .JuliaOSServer

const server = Ref{Any}(nothing)

const AGENT_TYPE_MAP = Dict(
    "TRADING" => AgentCore.TRADING,
    "MONITOR" => AgentCore.MONITOR,
    "ARBITRAGE" => AgentCore.ARBITRAGE,
    "DATA_COLLECTION" => AgentCore.DATA_COLLECTION,
    "NOTIFICATION" => AgentCore.NOTIFICATION,
    "CUSTOM" => AgentCore.CUSTOM,
    "DEV" => AgentCore.DEV,
    "CRAWLER" => AgentCore.CRAWLER,
    "REPORTER" => AgentCore.REPORTER,
    "ANALYTICS" => AgentCore.ANALYTICS,
    "VALIDATION" => AgentCore.VALIDATION
)

const AGENT_STATUS_MAP = Dict(
    "CREATED" => AgentCore.CREATED,
    "INITIALIZING" => AgentCore.INITIALIZING,
    "RUNNING" => AgentCore.RUNNING,
    "ACTIVE" => AgentCore.RUNNING,  # Accept 'ACTIVE' as synonym for 'RUNNING'
    "PAUSED" => AgentCore.PAUSED,
    "STOPPED" => AgentCore.STOPPED,
    "ERROR" => AgentCore.ERROR
)

function create_agent(req::HTTP.Request)
    @info "Triggered endpoint: POST /agents"
    body = String(req.body)
    data = JSON.parse(body)

    agent_name = data["name"]
    agent_type = AGENT_TYPE_MAP[uppercase(data["type"])]

    agent_config = AgentConfig(
        agent_name,
        agent_type;
        abilities = get(data, "abilities", String[]),
        chains = get(data, "chains", String[]),
        parameters = get(data, "parameters", Dict{String,Any}()),
        llm_config = get(data, "llm_config", Dict{String,Any}()),
        memory_config = get(data, "memory_config", Dict{String,Any}()),
        queue_config = get(data, "queue_config", Dict{String,Any}()),
        max_task_history = get(data, "max_task_history", Config.get_config("agent.max_task_history", 100))
    )

    agent = Agents.createAgent(agent_config)

    @info "Created agent $(agent.id)"

    return HTTP.Response(201, JSON.json(Dict(
        "id" => agent.id,
        "name" => agent.name,
        "type" => string(agent.type),
        "status" => string(agent.status),
        "created" => string(agent.created),
        "updated" => string(agent.updated)
    )))
end

function list_agents(req::HTTP.Request)
    @info "Triggered endpoint: GET /agents"
    agent_objs = Agents.listAgents()
    # Map to API model: id, name, type, status, state (state = status as string, only CREATED, RUNNING, PAUSED, STOPPED allowed)
    api_agents = [Dict(
        "id" => ag.id,
        "name" => ag.name,
        "type" => string(ag.type),
        "status" => string(ag.status),
        "state" => string(ag.status) in ["CREATED","RUNNING","PAUSED","STOPPED"] ? string(ag.status) : "STOPPED"
    ) for ag in agent_objs]
    return HTTP.Response(200, JSON.json(api_agents))
end

function ping(::HTTP.Request)
    @info "Triggered endpoint: GET /ping"
    return HTTP.Response(200, "")
end

function update_agent(req::HTTP.Request, agent_id::String, update::AgentUpdate)
    @info "Triggered endpoint: PUT /agents/$(agent_id)"
    ag = Agents.getAgent(agent_id)
    if ag === nothing
        return HTTP.Response(404, JSON.json(Dict("error" => "Agent not found")))
    end
    new_state = update.state
    valid_states = ["RUNNING", "PAUSED", "STOPPED"]
    if new_state === nothing || !(new_state in valid_states)
        return HTTP.Response(400, JSON.json(Dict("error" => "Invalid or missing state. Must be one of: RUNNING, PAUSED, STOPPED.")))
    end
    success = false
    if new_state == "RUNNING"
        if ag.status == Agents.PAUSED
            success = Agents.resumeAgent(agent_id)
        elseif ag.status != Agents.RUNNING
            success = Agents.startAgent(agent_id)
        else
            success = true
        end
    elseif new_state == "PAUSED"
        success = Agents.pauseAgent(agent_id)
    elseif new_state == "STOPPED"
        success = Agents.stopAgent(agent_id)
    end
    if !success
        return HTTP.Response(500, JSON.json(Dict("error" => "Failed to update agent state")))
    end
    # Return the intended state, not the actual (possibly lagging) state
    api_agent = Dict(
        "id" => ag.id,
        "name" => ag.name,
        "state" => new_state
    )
    return HTTP.Response(200, JSON.json(api_agent))
end

function delete_agent(req::HTTP.Request, agent_id::String)
    @info "Triggered endpoint: DELETE /agents/$(agent_id)"
    success = Agents.deleteAgent(agent_id)
    if success
        return HTTP.Response(204, "")
    else
        return HTTP.Response(404, JSON.json(Dict("error" => "Agent not found")))
    end
end

function process_agent_webhook(req::HTTP.Request, agent_id::String, payload::Dict{String, Any})
    @info "Triggered endpoint: POST /agents/$(agent_id)/webhook"
    @info "NYI, not actually processing webhook for agent $(agent_id)..."
    return nothing
end

function get_agent_output(req::HTTP.Request, agent_id::String)
    @info "Triggered endpoint: GET /agents/$(agent_id)/output"
    @info "NYI, not actually getting agent $(agent_id) output..."
    return Dict{String, Any}()
end

function run_server(port=8052)
    try
        router = HTTP.Router()
        router = JuliaOSServer.register(router, @__MODULE__; path_prefix="/api/v1")
        HTTP.register!(router, "POST", "/api/v1/agents", create_agent)
        HTTP.register!(router, "GET", "/ping", ping)
        server[] = HTTP.serve!(router, port)
        wait(server[])
    catch ex
        @error("Server error", exception=(ex, catch_backtrace()))
    end
end

end # module JuliaOSV1Server

JuliaOSV1Server.run_server()