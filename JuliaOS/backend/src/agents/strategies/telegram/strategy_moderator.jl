using ..CommonTypes: StrategyConfig, AgentContext, StrategySpecification, StrategyMetadata, StrategyInput
using ...Resources: Telegram
using HTTP
using JSON


Base.@kwdef struct StrategyTelegramModeratorConfig <: StrategyConfig
end

Base.@kwdef struct ModeratorInput <: StrategyInput
    message::Telegram.Message
end

function strategy_telegram_moderator(
        cfg::StrategyTelegramModeratorConfig,
        ctx::AgentContext,
        input::ModeratorInput
    )
    chat_id = input.message.chat.id
    user_id = input.message.from.id
    text = input.message.text

    detect_index = findfirst(tool -> tool.metadata.name == "detect_swearing", ctx.tools)
    if detect_index === nothing
        push!(ctx.logs, "ERROR: detect_swearing tool not found.")
        return ctx
    end
    detect_tool = ctx.tools[detect_index]

    is_swear = false
    try
        is_swear = detect_tool.execute(
            detect_tool.config,
            text
        )
    catch e
        push!(ctx.logs, "ERROR: Profanity detection failed: $e")
        return ctx
    end

    if is_swear
        ban_index = findfirst(tool -> tool.metadata.name == "ban_user", ctx.tools)
        if ban_index === nothing
            push!(ctx.logs, "ERROR: ban_user tool not found.")
            return ctx
        end
        ban_tool = ctx.tools[ban_index]

        success = false
        try
            success = ban_tool.execute(
                ban_tool.config,
                (chat_id = chat_id, user_id = user_id)
            )
        catch e
            push!(ctx.logs, "ERROR: Failed to call banChatMember: $e")
            return ctx
        end

        if success
            push!(ctx.logs, "🔨 Banned user $user_id from chat $chat_id for profanity: $(text)")
        else
            push!(ctx.logs, "❗ Failed to ban user $user_id from chat $chat_id.")
        end

    else
        push!(ctx.logs, "✅ No profanity detected from $user_id: $(text)")
    end

    return ctx
end

const STRATEGY_TELEGRAM_MODERATOR_METADATA = StrategyMetadata(
    "telegram_moderator"
)

const STRATEGY_TELEGRAM_MODERATOR_SPECIFICATION = StrategySpecification(
    strategy_telegram_moderator,
    nothing,
    StrategyTelegramModeratorConfig,
    STRATEGY_TELEGRAM_MODERATOR_METADATA,
    ModeratorInput
)
