using Pkg
Pkg.activate(".")

using DotEnv
DotEnv.load!()

using HTTP
using JSON
using JuliaOSBackend.Agents
using JuliaOSBackend.Agents.CommonTypes: AgentBlueprint, ToolBlueprint, StrategyBlueprint, TriggerConfig, WebhookTriggerParams

function main()
    @info "Supported tools:"
    for (name, spec) in Agents.Tools.TOOL_REGISTRY
        @info " - $name: $spec"
    end
    @info "Supported strategies:"
    for (name, spec) in Agents.Strategies.STRATEGY_REGISTRY
        @info " - $name: $spec"
    end

    gemini_api_key = ENV["GEMINI_API_KEY"]
    gemini_model   = "models/gemini-1.5-pro"
    telegram_token = "<TELEGRAM_BOT_TOKEN>"

    tool_blueprints = [
        ToolBlueprint("detect_swearing", Dict(
            "api_key"         => gemini_api_key,
            "model_name"      => gemini_model,
            "temperature"     => 0.0,
            "max_output_tokens" => 64
        )),
        ToolBlueprint("ban_user", Dict(
            "api_token" => telegram_token
        ))
    ]

    strategy_config = Dict()
    moderator_blueprint = AgentBlueprint(
        tool_blueprints,
        StrategyBlueprint("telegram_moderator", strategy_config),
        TriggerConfig(Agents.CommonTypes.WEBHOOK_TRIGGER, WebhookTriggerParams())
    )

    moderator_agent = Agents.create_agent("telegram_moderator_agent", "Telegram Moderator Agent", "Checks for profanity and bans users", moderator_blueprint)
    @info "Created moderator agent: $moderator_agent"

    @info "Existing agents:"
    for (name, agent) in Agents.AGENTS
        @info " - $name: $agent"
    end

    Agents.set_agent_state(moderator_agent, Agents.CommonTypes.RUNNING_STATE)
    @info "telegram_moderator_agent is now RUNNING"

    sample_payload_bad = Dict(
        "message" => Dict(
            "from"       => Dict("id" => 1),
            "chat"       => Dict("id" => 1),
            "text"       => "This is an foo_badword message!"
        )
    )

    sample_payload_clean = Dict(
        "message" => Dict(
            "from"       => Dict("id" => 2),
            "chat"       => Dict("id" => 1),
            "text"       => "Hello everyone, how are you?"
        )
    )

    @info "Running moderator_agent on a “bad” payload (contains a swear word)..."
    Agents.run(moderator_agent, sample_payload_bad)

    @info "Running moderator_agent on a “clean” payload..."
    Agents.run(moderator_agent, sample_payload_clean)

    @info "Agent logs after sample runs:"
    for log in moderator_agent.context.logs
        @info " - $log"
    end

    @info "Existing agents at the end:"
    for (name, agent) in Agents.AGENTS
        @info " - $name: $agent"
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
