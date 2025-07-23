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
        ToolBlueprint("scrape_article_text", Dict()),
        ToolBlueprint("summarize_for_post", Dict()),
        ToolBlueprint("post_to_x", Dict(
        "api_key" => X_API_KEY,
        "api_key_secret" => X_API_KEY_SECRET,
        "access_token" => X_ACCESS_TOKEN,
        "access_token_secret" => X_ACCESS_TOKEN_SECRET
        )),
    ]

    strategy_config = Dict(
    "news_portal_url" => "https://techcrunch.com/category/artificial-intelligence/",
    "css_selector" => "a[href]",
    "url_pattern" => "/\\d{4}/\\d{2}/\\d{2}/"
    )

    ai_news_agent_blueprint = AgentBlueprint(
        tool_blueprints,
        StrategyBlueprint("ai_news_scraping", strategy_config),
        TriggerConfig(Agents.CommonTypes.WEBHOOK_TRIGGER, WebhookTriggerParams())
    )

    ai_news_agent = Agents.create_agent("ai_news_agent", "AI News Agent", "Scrapes news article and posts a tweet based on it", ai_news_agent_blueprint)
    @info "Created AI news agent: $ai_news_agent"

    Agents.set_agent_state(ai_news_agent, Agents.CommonTypes.RUNNING_STATE)
    @info "ai_news_agent is now RUNNING"

    payload = Dict{String, Any}()

    @info "Running AI news agent..."
    Agents.run(ai_news_agent, payload)

    @info "Agent logs after sample runs:"
    for log in ai_news_agent.context.logs
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
