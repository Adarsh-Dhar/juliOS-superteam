using DotEnv
DotEnv.load!()

using ...Resources: Gemini
using ..CommonTypes: ToolSpecification, ToolMetadata, ToolConfig
using HTTP
using JSON

Base.@kwdef struct ToolSendMessageConfig <: ToolConfig
    api_token::String
end

function tool_send_message(
    cfg::ToolSendMessageConfig,
    data::NamedTuple{(:chat_id, :text), Tuple{Int, String}}
)::Bool
    url = "https://api.telegram.org/bot$(cfg.api_token)/sendMessage"
    body = JSON.json(Dict("chat_id" => data.chat_id, "text" => data.text))

    resp = HTTP.request(
        "POST", url;
        headers = ["Content-Type" => "application/json"],
        body = body
    )

    if resp.status != 200
        @warn "Failed to send message" chat_id=data.chat_id status=resp.status
        return false
    end
    return true
end

const TOOL_SEND_MESSAGE_METADATA = ToolMetadata(
    "send_message",
    "Sends a text message to a Telegram chat."
)
const TOOL_SEND_MESSAGE_SPECIFICATION = ToolSpecification(
    tool_send_message,
    ToolSendMessageConfig,
    TOOL_SEND_MESSAGE_METADATA
)
