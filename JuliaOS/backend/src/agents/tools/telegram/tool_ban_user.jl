using DotEnv
DotEnv.load!()

using ...Resources: Gemini
using ..CommonTypes: ToolSpecification, ToolMetadata, ToolConfig
using HTTP
using JSON

Base.@kwdef struct ToolBanUserConfig <: ToolConfig
    api_token::String
end

function tool_ban_user(
    cfg::ToolBanUserConfig,
    data::NamedTuple{(:chat_id,:user_id),Tuple{Int,Int}}
)::Bool
    chat_id, user_id = data.chat_id, data.user_id
    url = "https://api.telegram.org/bot$(cfg.api_token)/banChatMember"
    body = JSON.json(Dict("chat_id" => chat_id, "user_id" => user_id))

    resp = HTTP.request(
        "POST",
        url;
        headers = ["Content-Type" => "application/json"],
        body = body
    )

    if resp.status != 200
        @warn "Failed to ban user" user_id=user_id chat_id=chat_id status=resp.status
        return false
    end

    msg_url = "https://api.telegram.org/bot$(cfg.api_token)/sendMessage"
    text = "User with ID $user_id has been banned."
    msg_body = JSON.json(Dict("chat_id" => chat_id, "text" => text))

    msg_resp = HTTP.request(
        "POST",
        msg_url;
        headers = ["Content-Type" => "application/json"],
        body = msg_body
    )

    if msg_resp.status != 200
        @warn "Failed to send ban confirmation message" chat_id=chat_id status=msg_resp.status
        return false
    end

    return true
end

const TOOL_BAN_USER_METADATA = ToolMetadata(
    "ban_user",
    "Calls Telegram’s banChatMember API to ban a user from a chat."
)

const TOOL_BAN_USER_SPECIFICATION = ToolSpecification(
    tool_ban_user,
    ToolBanUserConfig,
    TOOL_BAN_USER_METADATA
)
