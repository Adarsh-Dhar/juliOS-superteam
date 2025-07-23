using .CommonTypes: InstantiatedTool, InstantiatedStrategy, StrategyBlueprint, ToolBlueprint, AgentState, TriggerType
using JSONSchemaGenerator

function deserialize_object(object_type::DataType, data::Dict{String, Any})
    expected_fields = fieldnames(object_type)
    provided_fields = Symbol.(keys(data))

    unexpected_fields = setdiff(provided_fields, expected_fields)
    missing_fields = setdiff(expected_fields, provided_fields)

    if !isempty(missing_fields)
        @warn "Missing fields in data: $(missing_fields)"
    end
    if !isempty(unexpected_fields)
        @warn "Unexpected fields in data: $(unexpected_fields)"
    end

    #@info "Deserializing object of type $(object_type) with data: $(data)"
    symbolic_data = Dict(Symbol(k) => v for (k, v) in data)
    return object_type(; symbolic_data...)
end

function instantiate_tool(blueprint::ToolBlueprint)::InstantiatedTool
    if !haskey(Tools.TOOL_REGISTRY, blueprint.name)
        error("Tool '$(blueprint.name)' is not registered.")
    end

    tool_spec = Tools.TOOL_REGISTRY[blueprint.name]

    tool_config = deserialize_object(tool_spec.config_type, blueprint.config_data)

    return InstantiatedTool(tool_spec.execute, tool_config, tool_spec.metadata)
end


function instantiate_strategy(blueprint::StrategyBlueprint)::InstantiatedStrategy
    if !haskey(Strategies.STRATEGY_REGISTRY, blueprint.name)
        error("Strategy '$(blueprint.name)' is not registered.")
    end

    strategy_spec = Strategies.STRATEGY_REGISTRY[blueprint.name]

    strategy_config = deserialize_object(strategy_spec.config_type, blueprint.config_data)

    return InstantiatedStrategy(strategy_spec.run, strategy_spec.initialize, strategy_config, strategy_spec.metadata, strategy_spec.input_type)
end

const AGENT_STATE_NAMES = Dict(
    CommonTypes.CREATED_STATE  => "CREATED",
    CommonTypes.RUNNING_STATE  => "RUNNING",
    CommonTypes.PAUSED_STATE   => "PAUSED",
    CommonTypes.STOPPED_STATE  => "STOPPED",
)

function agent_state_to_string(state::AgentState)::String
    return get(AGENT_STATE_NAMES, state) do
        error("Unknown AgentState: $state")
    end
end

const NAME_TO_AGENT_STATE = Dict(v => k for (k, v) in AGENT_STATE_NAMES)

function string_to_agent_state(name::String)::AgentState
    return get(NAME_TO_AGENT_STATE, name) do
        error("Invalid AgentState name: $name")
    end
end

const TRIGGER_TYPE_NAMES = Dict(
    CommonTypes.PERIODIC_TRIGGER => "PERIODIC",
    CommonTypes.WEBHOOK_TRIGGER => "WEBHOOK",
)

function trigger_type_to_string(trigger::TriggerType)::String
    return get(TRIGGER_TYPE_NAMES, trigger) do
        error("Unknown TriggerType: $trigger")
    end
end

"""
    input_schema_json(agent) -> String

Same, but as a compact JSON string.
"""
function input_type_json(agent::CommonTypes.Agent)
    isnothing(agent.strategy.input_type) ? Dict{String, Any}() : JSONSchemaGenerator.schema(agent.strategy.input_type)
end

const NAME_TO_TRIGGER_TYPE = Dict(v => k for (k, v) in TRIGGER_TYPE_NAMES)

function string_to_trigger_type(name::String)::TriggerType
    return get(NAME_TO_TRIGGER_TYPE, name) do
        error("Invalid TriggerType name: $name")
    end
end

const TRIGGER_PARAM_TYPES = Dict(
    CommonTypes.PERIODIC_TRIGGER => CommonTypes.PeriodicTriggerParams,
    CommonTypes.WEBHOOK_TRIGGER => CommonTypes.WebhookTriggerParams,
)

function trigger_type_to_params_type(trigger::TriggerType)::DataType
    return get(TRIGGER_PARAM_TYPES, trigger) do
        error("Unknown TriggerType: $trigger")
    end
end