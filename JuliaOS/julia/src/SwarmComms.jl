# SwarmComms.jl
module SwarmComms

using Dates

# In-memory message queue for agent communication
const MESSAGE_QUEUES = Dict{String, Vector{Dict{String, Any}}}()
const SUBSCRIBERS = Dict{String, Vector{String}}()

"""
    send(target::String, message::Dict{String, Any})

Send a message to a specific target agent or service.
"""
function send(target::String, message::Dict{String, Any})
    if !haskey(MESSAGE_QUEUES, target)
        MESSAGE_QUEUES[target] = Vector{Dict{String, Any}}()
    end
    
    # Add timestamp to message
    message_with_timestamp = merge(message, Dict("timestamp" => now()))
    
    push!(MESSAGE_QUEUES[target], message_with_timestamp)
    
    @info "Sent message to $target: $(message["type"])"
end

"""
    receive(target::String)

Receive messages for a specific target.
"""
function receive(target::String)
    if haskey(MESSAGE_QUEUES, target)
        messages = MESSAGE_QUEUES[target]
        MESSAGE_QUEUES[target] = Vector{Dict{String, Any}}()  # Clear the queue
        return messages
    else
        return Vector{Dict{String, Any}}()
    end
end

"""
    subscribe(agent_id::String, topic::String)

Subscribe an agent to a topic.
"""
function subscribe(agent_id::String, topic::String)
    if !haskey(SUBSCRIBERS, topic)
        SUBSCRIBERS[topic] = Vector{String}()
    end
    
    if !(agent_id in SUBSCRIBERS[topic])
        push!(SUBSCRIBERS[topic], agent_id)
    end
    
    @info "Agent $agent_id subscribed to topic: $topic"
end

"""
    unsubscribe(agent_id::String, topic::String)

Unsubscribe an agent from a topic.
"""
function unsubscribe(agent_id::String, topic::String)
    if haskey(SUBSCRIBERS, topic)
        filter!(id -> id != agent_id, SUBSCRIBERS[topic])
    end
    
    @info "Agent $agent_id unsubscribed from topic: $topic"
end

"""
    publish(topic::String, message::Dict{String, Any})

Publish a message to all subscribers of a topic.
"""
function publish(topic::String, message::Dict{String, Any})
    if haskey(SUBSCRIBERS, topic)
        for agent_id in SUBSCRIBERS[topic]
            send(agent_id, message)
        end
    end
    
    @info "Published message to topic $topic: $(message["type"])"
end

"""
    get_subscribers(topic::String)

Get all subscribers for a topic.
"""
function get_subscribers(topic::String)
    return get(SUBSCRIBERS, topic, Vector{String}())
end

"""
    get_queue_size(target::String)

Get the number of messages in a target's queue.
"""
function get_queue_size(target::String)
    return length(get(MESSAGE_QUEUES, target, Vector{Dict{String, Any}}()))
end

end # module SwarmComms 