module Triggers

using ..CommonTypes: TriggerType, CommonTypes, WebhookTriggerParams, PeriodicTriggerParams, TriggerParams

function trigger_name_to_enum(trigger_name::String)::TriggerType
    if trigger_name == "periodic"
        return CommonTypes.PERIODIC_TRIGGER
    elseif trigger_name == "webhook"
        return CommonTypes.WEBHOOK_TRIGGER
    else
        error("Unknown trigger type: $trigger_name")
    end
end

function process_trigger_params(trigger_type::TriggerType, params::Union{Dict{String, Any}, Nothing})::TriggerParams
    if params === nothing
        params = Dict{String, Any}()
    end
    if trigger_type == CommonTypes.PERIODIC_TRIGGER
        interval = get(params, "interval")  # Default to 60 seconds if not provided
        return PeriodicTriggerParams(interval)
    elseif trigger_type == CommonTypes.WEBHOOK_TRIGGER
        return WebhookTriggerParams()
    else
        error("Unsupported trigger type: $trigger_type")
    end
end

end