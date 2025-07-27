# ReputationKeeper.jl
module ReputationKeeper

using Dates

# In-memory reputation tracking
const AGENT_REPUTATIONS = Dict{String, Float64}()
const AGENT_STAKES = Dict{String, Float64}()
const AGENT_REPORTS = Dict{String, Vector{Dict{String, Any}}}()

"""
    stake(agent_id::String, amount::Float64)

Stake reputation for an agent.
"""
function stake(agent_id::String, amount::Float64)
    current_stake = get(AGENT_STAKES, agent_id, 0.0)
    AGENT_STAKES[agent_id] = current_stake + amount
    @info "Agent $agent_id staked $amount reputation"
end

"""
    unstake(agent_id::String, amount::Float64)

Unstake reputation for an agent.
"""
function unstake(agent_id::String, amount::Float64)
    current_stake = get(AGENT_STAKES, agent_id, 0.0)
    if current_stake >= amount
        AGENT_STAKES[agent_id] = current_stake - amount
        @info "Agent $agent_id unstaked $amount reputation"
        return true
    else
        @warn "Agent $agent_id cannot unstake $amount (only has $current_stake)"
        return false
    end
end

"""
    report(agent_id::String, event_type::String, data::Dict{String, Any})

Report an event for an agent.
"""
function report(agent_id::String, event_type::String, data::Dict{String, Any})
    if !haskey(AGENT_REPORTS, agent_id)
        AGENT_REPORTS[agent_id] = Vector{Dict{String, Any}}()
    end
    
    report_entry = Dict{String, Any}(
        "timestamp" => now(),
        "event_type" => event_type,
        "data" => data
    )
    
    push!(AGENT_REPORTS[agent_id], report_entry)
    
    # Update reputation based on event type
    reputation_change = calculate_reputation_change(event_type, data)
    current_reputation = get(AGENT_REPUTATIONS, agent_id, 0.0)
    AGENT_REPUTATIONS[agent_id] = current_reputation + reputation_change
    
    @info "Agent $agent_id reported $event_type, reputation change: $reputation_change"
end

"""
    get_reputation(agent_id::String)

Get the current reputation of an agent.
"""
function get_reputation(agent_id::String)
    return get(AGENT_REPUTATIONS, agent_id, 0.0)
end

"""
    get_stake(agent_id::String)

Get the current stake of an agent.
"""
function get_stake(agent_id::String)
    return get(AGENT_STAKES, agent_id, 0.0)
end

"""
    get_reports(agent_id::String)

Get all reports for an agent.
"""
function get_reports(agent_id::String)
    return get(AGENT_REPORTS, agent_id, Vector{Dict{String, Any}}())
end

"""
    calculate_reputation_change(event_type::String, data::Dict{String, Any})

Calculate reputation change based on event type and data.
"""
function calculate_reputation_change(event_type::String, data::Dict{String, Any})
    if event_type == "scrape_success"
        post_count = get(data, "post_count", 0)
        return min(post_count * 0.1, 10.0)  # Max 10 reputation per successful scrape
    elseif event_type == "error"
        error_type = get(data, "type", "unknown")
        if error_type == "rate_limit"
            return -1.0
        elseif error_type == "ban"
            return -5.0
        elseif error_type == "authentication"
            return -2.0
        else
            return -0.5
        end
    else
        return 0.0
    end
end

end # module ReputationKeeper 