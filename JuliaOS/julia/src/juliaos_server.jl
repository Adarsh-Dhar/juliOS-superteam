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

@info "AgentType fields: $(fieldnames(AgentType))"

include("api/server/src/JuliaOSServer.jl")

using .JuliaOSServer

const server = Ref{Any}(nothing)
const agents = Vector{AgentCore.Agent}()

const AGENT_TYPE_MAP = Dict(
    "TRADING" => AgentCore.TRADING,
    "MONITOR" => AgentCore.MONITOR,
    "ARBITRAGE" => AgentCore.ARBITRAGE,
    "DATA_COLLECTION" => AgentCore.DATA_COLLECTION,
    "NOTIFICATION" => AgentCore.NOTIFICATION,
    "CUSTOM" => AgentCore.CUSTOM,
    "DEV" => AgentCore.DEV,
    "CRAWLER" => AgentCore.CRAWLER
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

    agent_id = haskey(data, "id") ? data["id"] : string(uuid4())
    agent_name = data["name"]
    agent_type = AGENT_TYPE_MAP[uppercase(data["type"])]
    agent_status = haskey(data, "status") ? AGENT_STATUS_MAP[uppercase(data["status"])] : AgentCore.CREATED  # Map string to AgentStatus, default CREATED

    now = Dates.now()
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
    agent_memory = OrderedDictAgentMemory(OrderedDict{String, Any}(), 1000)  # Replace with your default memory type
    agent_task_history = Vector{Dict{String,Any}}()
    agent_skills = Dict{String,SkillState}()
    agent_queue = PriorityAgentQueue(PriorityQueue{Any, Float64}())  # Replace with your default queue type
    agent_task_results = Dict{String, TaskResult}()
    agent_llm_integration = nothing
    agent_swarm_connection = nothing
    agent_lock = ReentrantLock()
    agent_condition = Condition()
    agent_last_error = nothing
    agent_last_error_timestamp = nothing
    agent_last_activity = now

    agent = AgentCore.Agent(
        agent_id,
        agent_name,
        agent_type,
        agent_status,
        now,
        now,
        agent_config,
        agent_memory,
        agent_task_history,
        agent_skills,
        agent_queue,
        agent_task_results,
        agent_llm_integration,
        agent_swarm_connection,
        agent_lock,
        agent_condition,
        agent_last_error,
        agent_last_error_timestamp,
        agent_last_activity
    )

    push!(agents, agent)
    @info "Created agent $(agent.id)"

    # Return a summary as JSON
    return HTTP.Response(201, JSON.json(Dict(
        "id" => agent.id,
        "name" => agent.name,
        "type" => string(agent.type),
        "status" => string(agent.status),
        "created" => string(agent.created),
        "updated" => string(agent.updated)
        # ... add more fields as needed ...
    )))
end

function list_agents(req::HTTP.Request)
    @info "Triggered endpoint: GET /agents"
    @info "NYI, not actually listing agents..."
    return agents
end

function ping(::HTTP.Request)
    @info "Triggered endpoint: GET /ping"
    return HTTP.Response(200, "")
end

function update_agent(req::HTTP.Request, agent_id::String, update::AgentUpdate)
    @info "Triggered endpoint: PUT /agents/$(agent_id)"
    @info "NYI, not actually updating agent $(agent_id)..."
    return nothing
end

function delete_agent(req::HTTP.Request, agent_id::String)
    @info "Triggered endpoint: DELETE /agents/$(agent_id)"
    @info "NYI, not actually deleting agent $(agent_id)..."
    return nothing
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