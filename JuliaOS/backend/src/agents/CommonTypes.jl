module CommonTypes

using StructTypes

# Tools:

abstract type ToolConfig end

struct ToolMetadata
    name::String
    description::String
end

struct ToolSpecification
    execute::Function
    config_type::DataType
    metadata::ToolMetadata
end

struct InstantiatedTool
    execute::Function
    config::ToolConfig
    metadata::ToolMetadata
end

# Agent internals:

@enum AgentState CREATED_STATE RUNNING_STATE PAUSED_STATE STOPPED_STATE

struct AgentContext
    tools::Vector{InstantiatedTool}
    logs::Vector{String}
end

# Triggers:

@enum TriggerType PERIODIC_TRIGGER WEBHOOK_TRIGGER

abstract type TriggerParams end

struct TriggerConfig
    type::TriggerType
    params::TriggerParams
end

struct PeriodicTriggerParams <: TriggerParams
    interval::Int  # Interval in seconds
end

struct WebhookTriggerParams <: TriggerParams
end

# Strategies:

abstract type StrategyConfig end

struct StrategyMetadata
    name::String
end

abstract type StrategyInput end
StructTypes.StructType(::Type{T}) where {T<:StrategyInput} = StructTypes.Struct()

struct StrategySpecification
    run::Function
    initialize::Union{Nothing, Function}
    config_type::DataType
    metadata::StrategyMetadata
    input_type::Union{DataType,Nothing}
end

struct InstantiatedStrategy
    run::Function
    initialize::Union{Nothing, Function}
    config::StrategyConfig
    metadata::StrategyMetadata
    input_type::Union{DataType,Nothing}
end

# Blueprints:

struct ToolBlueprint
    name::String
    config_data::Dict{String, Any}
end

struct StrategyBlueprint
    name::String
    config_data::Dict{String, Any}
end

struct AgentBlueprint
    tools::Vector{ToolBlueprint}
    strategy::StrategyBlueprint
    trigger::TriggerConfig
end

# Agent proper:

mutable struct Agent
    id::String
    name::String
    description::String
    context::AgentContext
    strategy::InstantiatedStrategy
    trigger::TriggerConfig
    state::AgentState
end

end