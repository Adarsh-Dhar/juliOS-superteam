using ..CommonTypes: StrategyConfig, AgentContext, StrategyMetadata, StrategyInput
using ...Resources: Telegram
using HTTP
using JSON


Base.@kwdef struct StrategySupportConfig <: StrategyConfig
    name::String
    api_token::String
end

Base.@kwdef struct SupportInput <: StrategyInput
    message::Telegram.Message
end

function strategy_support_initialization(
    cfg::StrategySupportConfig,
    ctx::AgentContext
)
    host_url = ENV["HOST_URL"]
    if isempty(host_url)
        push!(ctx.logs, "ERROR: HOST_URL is not set in environment.")
        return ctx
    end
    api_token = cfg.api_token

    webhook_url = "https://api.telegram.org/bot$(api_token)/setWebhook"
    callback_url = string(host_url, "/api/v1/agents/$(cfg.name)/webhook")
    body = JSON.json(Dict("url" => callback_url))

    try
        resp = HTTP.request(
            "POST",
            webhook_url;
            headers = ["Content-Type" => "application/json"],
            body = body
        )
        if resp.status == 200
            push!(ctx.logs, "INFO: Webhook set to $callback_url successfully.")
        else
            push!(ctx.logs, "ERROR: Failed to set webhook. Status=$(resp.status) Response=$(String(resp.body))")
        end
    catch e
        push!(ctx.logs, "ERROR: Exception when setting webhook: $e")
    end
end


function strategy_support(
        cfg::StrategySupportConfig,
        ctx::AgentContext,
        input::SupportInput
    )
    chat_id = input.message.chat.id
    user_id = input.message.from.id
    text = input.message.text

    llm_chat_index = findfirst(tool -> tool.metadata.name == "llm_chat", ctx.tools)
    if llm_chat_index === nothing
        push!(ctx.logs, "ERROR: llm_chat tool not found.")
        return
    end
    llm_chat_tool = ctx.tools[llm_chat_index]

    resp = try
        llm_chat_tool.execute(llm_chat_tool.config, Dict("prompt" => text))
    catch e
        push!(ctx.logs, "ERROR: LLM chat execution error: $e")
        return
    end

    if !get(resp, "success", false)
        push!(ctx.logs, "ERROR: LLM chat failed: $(get(resp, "error", "unknown"))")
        return
    end
    reply = resp["output"]
    @show reply

    send_idx = findfirst(tool -> tool.metadata.name == "send_message", ctx.tools)
    if isnothing(send_idx)
        push!(ctx.logs, "ERROR: send_message tool not found.")
        return
    end
    send_tool = ctx.tools[send_idx]

    ok = try
        send_tool.execute(send_tool.config, (chat_id=chat_id, text=reply))
    catch e
        push!(ctx.logs, "ERROR: send_message execution error: $e")
        false
    end

    if !ok
        push!(ctx.logs, "WARN: Failed to deliver reply to chat $chat_id.")
    end
end

const STRATEGY_TELEGRAM_SUPPORT_METADATA = StrategyMetadata(
    "support"
)

const STRATEGY_TELEGRAM_SUPPORT_SPECIFICATION = StrategySpecification(
    strategy_support,
    strategy_support_initialization,
    StrategySupportConfig,
    STRATEGY_TELEGRAM_SUPPORT_METADATA,
    SupportInput
)
