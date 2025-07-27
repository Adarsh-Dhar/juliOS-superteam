# AgentFramework.jl
module AgentFramework

using Dates, Random, UUIDs, Logging

"""
    AbstractAgent

Abstract type for all agents in the JuliaOS system.
"""
abstract type AbstractAgent end

"""
    is_active(agent::AbstractAgent)

Check if an agent is currently active and should continue running.
"""
function is_active(agent::AbstractAgent)
    return true  # Default implementation - override in specific agents
end

"""
    run(agent::AbstractAgent)

Main execution loop for an agent.
"""
function run(agent::AbstractAgent)
    error("run() must be implemented for agent type $(typeof(agent))")
end

"""
    error_count(agent::AbstractAgent)

Get the current error count for an agent.
"""
function error_count(agent::AbstractAgent)
    return 0  # Default implementation
end

"""
    status(agent::AbstractAgent)

Get the current status of an agent.
"""
function status(agent::AbstractAgent)
    return "unknown"  # Default implementation
end

end # module AgentFramework 