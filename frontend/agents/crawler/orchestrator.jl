# File: orchestrator.jl
using JuliaOS.Agents
include("twitter.jl")
include("reddit.jl")

struct CrawlerOrchestrator
    agents::Vector{Agent}
end

function start_all(orchestrator::CrawlerOrchestrator)
    for agent in orchestrator.agents
        @async run(agent)
    end
end

function add_agent!(orchestrator::CrawlerOrchestrator, agent::Agent)
    push!(orchestrator.agents, agent)
end
