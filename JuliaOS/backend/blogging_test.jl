using DotEnv
DotEnv.load!()

using Pkg
Pkg.activate(".")

using JuliaOSBackend.Agents
using JuliaOSBackend.Agents.CommonTypes: AgentBlueprint, ToolBlueprint, StrategyBlueprint, TriggerConfig, WebhookTriggerParams

X_API_KEY = ENV["X_API_KEY"]
X_API_KEY_SECRET = ENV["X_API_KEY_SECRET"]
X_ACCESS_TOKEN = ENV["X_ACCESS_TOKEN"]
X_ACCESS_TOKEN_SECRET = ENV["X_ACCESS_TOKEN_SECRET"]

function main()
    @info "Supported tools:"
    for (name, spec) in Agents.Tools.TOOL_REGISTRY
        @info " - $name: $spec"
    end
    @info "Supported strategies:"
    for (name, spec) in Agents.Strategies.STRATEGY_REGISTRY
        @info " - $name: $spec"
    end

    tool_blueprints = [
        ToolBlueprint("write_blog", Dict()),
        ToolBlueprint("post_to_x", Dict(
        "api_key" => X_API_KEY,
        "api_key_secret" => X_API_KEY_SECRET,
        "access_token" => X_ACCESS_TOKEN,
        "access_token_secret" => X_ACCESS_TOKEN_SECRET
    )),
    ]
    strategy_config = Dict()

    blog_writer_blueprint = AgentBlueprint(
        tool_blueprints,
        StrategyBlueprint("blogger", strategy_config),
        TriggerConfig(Agents.CommonTypes.WEBHOOK_TRIGGER, WebhookTriggerParams())
    )
    
    blogger_agent = Agents.create_agent("blogger_agent", "Blogger agent", "Writes a tweet based on provided settings and posts it on X", blog_writer_blueprint)
    @info "Created blogger agent: $blogger_agent"

    @info "Existing agents:"
    for (name, agent) in Agents.AGENTS
        @info " - $name: $agent"
    end

    Agents.set_agent_state(blogger_agent, Agents.CommonTypes.RUNNING_STATE)
    @info "blogger_agent is now RUNNING"

    task = Dict{String, Any}(
        "title" => "My favourite Julia features",
        "tone" => "informal",
        "max_characters_amount" => 280,
        "output_format" => "plain"
    )

    @info "Running Blogger agent with task: $task"
    Agents.run(blogger_agent, task)

    @info "Agent logs after sample runs:"
    for log in blogger_agent.context.logs
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