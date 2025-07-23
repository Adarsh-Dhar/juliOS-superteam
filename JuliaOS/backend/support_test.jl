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
        ToolBlueprint("llm_chat", Dict())
        ToolBlueprint("send_message", Dict(
            "api_token" => telegram_token
        ))
    ]

    strategy_config = Dict("name" => "support_agent", "api_token" => telegram_token)
    support_blueprint = AgentBlueprint(
        tool_blueprints,
        StrategyBlueprint("telegram_support", strategy_config),
        TriggerConfig(Agents.CommonTypes.WEBHOOK_TRIGGER, WebhookTriggerParams())
    )

    support_agent = Agents.create_agent("support_agent", "Telegram Support Agent", "Responds to user messages", support_blueprint)
    @info "Created support agent: $support_agent"

    @info "Existing agents:"
    for (name, agent) in Agents.AGENTS
        @info " - $name: $agent"
    end

    Agents.set_agent_state(support_agent, Agents.CommonTypes.RUNNING_STATE)
    @info "support_agent is now RUNNING"

    payload = Dict(
        "message" => Dict(
            "from" => Dict("id" => 340743403),
            "chat" => Dict("id" => 340743403),
            "text" => "Hello! How are you?"
        )
    )

    @info "Running support_agent with a simple payload...."
    Agents.run(support_agent, payload)

    @info "Agent logs after sample runs:"
    for log in support_agent.context.logs
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
