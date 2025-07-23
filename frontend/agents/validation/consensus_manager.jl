# File: consensus_manager.jl
using JuliaOS.Agents

struct ConsensusManager <: Agent
    vote_threshold::Int
    vote_timeout::Float64  # seconds
end

mutable struct VoteRecord
    votes::Dict{Any, Vector{Tuple{Bool, Float64}}}  # content_id => [(vote, weight)]
    timestamps::Dict{Any, Float64}  # content_id => first vote timestamp
end

function run(manager::ConsensusManager)
    subscribe(:content_validity_vote)
    records = VoteRecord(Dict(), Dict())
    
    while true
        event = next_event()
        cid = event.content_id
        vote = event.vote
        weight = event.weight
        now_time = time()

        if !haskey(records.votes, cid)
            records.votes[cid] = Vector{Tuple{Bool, Float64}}()
            records.timestamps[cid] = now_time
        end
        push!(records.votes[cid], (vote, weight))

        # Check if threshold or timeout reached
        votes = records.votes[cid]
        elapsed = now_time - records.timestamps[cid]
        if length(votes) >= manager.vote_threshold || elapsed >= manager.vote_timeout
            # Weighted majority
            total_weight = sum(w for (_, w) in votes)
            true_weight = sum(w for (v, w) in votes if v)
            false_weight = total_weight - true_weight
            consensus = true_weight > false_weight
            confidence = total_weight > 0 ? max(true_weight, false_weight) / total_weight : 0.0
            emit_event(:consensus_result, (
                content_id=cid,
                consensus=consensus,
                confidence=confidence,
                total_votes=length(votes)
            ))
            # Clean up
            delete!(records.votes, cid)
            delete!(records.timestamps, cid)
        end
    end
end
