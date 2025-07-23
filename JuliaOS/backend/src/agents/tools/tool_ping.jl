using ...Resources: Gemini
using ..CommonTypes: ToolSpecification, ToolMetadata, ToolConfig


Base.@kwdef struct ToolPingConfig <: ToolConfig
end

function tool_ping(cfg::ToolPingConfig, task::Dict)
    return Dict("msg" => "pong", "success" => true)
end

const TOOL_PING_METADATA = ToolMetadata(
    "ping",
    "A simple ability that responds with 'pong'."
)

const TOOL_PING_SPECIFICATION = ToolSpecification(
    tool_ping,
    ToolPingConfig,
    TOOL_PING_METADATA
)
