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

# Include new modules for crawler support
include("agents/AgentFramework.jl")
using .AgentFramework

include("Vault.jl")
using .Vault

include("IPFS.jl")
using .IPFS

include("ReputationKeeper.jl")
using .ReputationKeeper

include("SwarmComms.jl")
using .SwarmComms

# Include crawler modules
include("agents/crawlers/reddit.jl")
using .Reddit: RedditCrawler

include("agents/crawlers/twitter.jl")
using .Twitter: TwitterCrawler


# Include analysis modules
include("agents/analysis/sentiment.jl")

include("agents/analysis/trend.jl")

include("agents/consensusVerifier.jl")
using .ConsensusVerifier

include("agents/ConsensusSwarm.jl")
using .ConsensusSwarm

@info "AgentType fields: $(fieldnames(AgentType))"
@info "Analysis modules loaded successfully"

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

# Global registry for custom agent types
const CUSTOM_AGENT_REGISTRY = Dict{String, Type}()

# Global registry for created custom agents
const CUSTOM_AGENTS = Dict{String, Any}()

"""
    register_custom_agent_type(name::String, agent_type::Type)

Register a custom agent type that can be created through the API.
"""
function register_custom_agent_type(name::String, agent_type::Type)
    CUSTOM_AGENT_REGISTRY[name] = agent_type
end

# Register the crawler agents
register_custom_agent_type("REDDITCRAWLER", RedditCrawler)
register_custom_agent_type("TWITTERCRAWLER", TwitterCrawler)

# Register the analysis agents
register_custom_agent_type("SENTIMENTANALYZER", SentimentAgent)
register_custom_agent_type("TRENDANALYZER", TrendAgent)

# Register the consensus coordinator
register_custom_agent_type("CONSENSUSCOORDINATOR", ConsensusSwarm.ConsensusCoordinator)

@info "Registered custom agents: $(keys(CUSTOM_AGENT_REGISTRY))"
@info "Crawler agents registered: $(filter(k -> endswith(k, "CRAWLER"), keys(CUSTOM_AGENT_REGISTRY)))"
@info "Analysis agents registered: $(filter(k -> endswith(k, "ANALYZER"), keys(CUSTOM_AGENT_REGISTRY)))"
@info "Consensus agents registered: $(filter(k -> startswith(k, "CONSENSUS"), keys(CUSTOM_AGENT_REGISTRY)))"

function create_agent(req::HTTP.Request)
    @info "Triggered endpoint: POST /agents"
    body = String(req.body)
    data = JSON.parse(body)

    agent_name = data["name"]
    agent_type_str = uppercase(data["type"])
    
    @info "Requested agent type: $agent_type_str"
    @info "Available custom agents: $(keys(CUSTOM_AGENT_REGISTRY))"
    @info "Custom agent registry has key $agent_type_str: $(haskey(CUSTOM_AGENT_REGISTRY, agent_type_str))"
    
    # Check if this is a custom agent type
    if haskey(CUSTOM_AGENT_REGISTRY, agent_type_str)
        @info "Found custom agent type: $agent_type_str"
        return create_custom_agent(data, agent_type_str)
    elseif haskey(AGENT_TYPE_MAP, agent_type_str)
        @info "Agent type $agent_type_str found in standard types"
        agent_type = AGENT_TYPE_MAP[agent_type_str]
    else
        @error "Unknown agent type: $agent_type_str"
        return HTTP.Response(400, JSON.json(Dict("error" => "Unknown agent type: $agent_type_str")))
    end

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

function create_custom_agent(data::Dict, agent_type_str::String)
    agent_name = data["name"]
    agent_type_class = CUSTOM_AGENT_REGISTRY[agent_type_str]
    
    @info "Creating custom agent: $agent_name of type $agent_type_str"
    @info "Agent class: $agent_type_class"
    
    # Extract configuration for the custom agent
    config = get(data, "parameters", Dict{String,Any}())
    
    @info "Agent config: $config"
    
    # Create the custom agent
    if agent_type_class == RedditCrawler
        agent = RedditCrawler(agent_name, config)
        
        @info "Created Reddit crawler agent: $(agent.id)"
        
        return HTTP.Response(201, JSON.json(Dict(
            "id" => agent.id,
            "name" => agent_name,  # Use the agent_name variable instead
            "type" => agent_type_str,
            "status" => "CREATED",
            "created" => string(now()),
            "updated" => string(now())
        )))
    elseif agent_type_class == TwitterCrawler
        agent = TwitterCrawler(agent_name, config)
        
        @info "Created Twitter crawler agent: $(agent.id)"
        
        return HTTP.Response(201, JSON.json(Dict(
            "id" => agent.id,
            "name" => agent_name,  # Use the agent_name variable
            "type" => agent_type_str,
            "status" => "CREATED",
            "created" => string(now()),
            "updated" => string(now())
        )))
    elseif agent_type_class == SentimentAgent
        @info "Creating SentimentAgent..."
        try
            agent = SentimentAgent(agent_name, config)
            @info "Successfully created SentimentAgent with id: $(agent.id)"
            
            # Store the custom agent
            CUSTOM_AGENTS[agent.id] = agent
            @info "Stored agent in CUSTOM_AGENTS registry"
            
            @info "Created Sentiment analyzer agent: $(agent.id)"
            
            return HTTP.Response(201, JSON.json(Dict(
                "id" => agent.id,
                "name" => agent_name,
                "type" => agent_type_str,
                "status" => "CREATED",
                "created" => string(now()),
                "updated" => string(now())
            )))
        catch e
            @error "Error creating SentimentAgent: $e"
            @error "Stacktrace: $(stacktrace())"
            return HTTP.Response(500, JSON.json(Dict("error" => "Failed to create SentimentAgent: $e")))
        end
    elseif agent_type_class == TrendAgent
        @info "Creating TrendAgent..."
        try
            agent = TrendAgent(agent_name, config)
            @info "Successfully created TrendAgent with id: $(agent.id)"
            
            # Store the custom agent
            CUSTOM_AGENTS[agent.id] = agent
            @info "Stored agent in CUSTOM_AGENTS registry"
            
            @info "Created Trend analyzer agent: $(agent.id)"
            
            return HTTP.Response(201, JSON.json(Dict(
                "id" => agent.id,
                "name" => agent_name,
                "type" => agent_type_str,
                "status" => "CREATED",
                "created" => string(now()),
                "updated" => string(now())
            )))
        catch e
            @error "Error creating TrendAgent: $e"
            @error "Stacktrace: $(stacktrace())"
            return HTTP.Response(500, JSON.json(Dict("error" => "Failed to create TrendAgent: $e")))
        end
    elseif agent_type_class == ConsensusSwarm.ConsensusCoordinator
        # Consensus Swarm Coordinator creation
        config["id"] = get(config, "id", agent_name)
        config["consensus_agent_count"] = get(config, "consensus_agent_count", 5)
        coordinator = ConsensusSwarm.setup_campaign(config)
        CUSTOM_AGENTS[coordinator.coordinator_id] = coordinator
        return HTTP.Response(201, JSON.json(Dict(
            "id" => coordinator.coordinator_id,
            "name" => agent_name,
            "type" => agent_type_str,
            "status" => "CREATED",
            "created" => string(now()),
            "updated" => string(now())
        )))
    else
        @error "Unsupported custom agent type: $agent_type_str"
        return HTTP.Response(400, JSON.json(Dict("error" => "Unsupported custom agent type: $agent_type_str")))
    end
end

function list_agents(req::HTTP.Request)
    @info "Triggered endpoint: GET /agents"
    agent_objs = Agents.listAgents()
    
    # Map standard agents to API model
    api_agents = [Dict(
        "id" => ag.id,
        "name" => ag.name,
        "type" => string(ag.type),
        "status" => string(ag.status),
        "state" => string(ag.status) in ["CREATED","RUNNING","PAUSED","STOPPED"] ? string(ag.status) : "STOPPED"
    ) for ag in agent_objs]
    
    # Add custom agents to the list
    for (id, agent) in CUSTOM_AGENTS
        try
            push!(api_agents, Dict(
                "id" => get(agent, :id, id),
                "name" => get(agent, :name, "Custom Agent"),
                "type" => "CUSTOM",
                "status" => "CREATED",
                "state" => "CREATED"
            ))
        catch e
            @warn "Error processing custom agent $id: $e"
        end
    end
    
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

function run_server(port=8053)
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

# === Consensus Swarm Integration ===
# To create a consensus swarm campaign, use:
#
# curl -X POST http://localhost:8053/api/v1/agents \
#   -H "Content-Type: application/json" \
#   -d '{
#     "name": "consensus_campaign_001",
#     "type": "CONSENSUSCOORDINATOR",
#     "parameters": {
#       "id": "consensus_campaign_001",
#       "consensus_agent_count": 7
#     }
#   }'
#

JuliaOSV1Server.run_server()