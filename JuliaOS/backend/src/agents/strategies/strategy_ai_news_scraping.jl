using ..CommonTypes: StrategyConfig, AgentContext, StrategySpecification, StrategyMetadata, StrategyInput
using Gumbo, Cascadia, HTTP


"""
    StrategyAINewsAgentConfig

Configuration for the AI news scraping strategy. 
    
# Fields
- `news_portal_url::String`: The URL of the news portal to scrape articles from.
- `css_selector::String`: A CSS selector to find article links (e.g. `"a[href]"`).
- `url_pattern::Union{Nothing, String}`: A regex pattern to match valid article URLs (e.g. date-based `/2025/01/01/`).
"""
Base.@kwdef struct StrategyAINewsAgentConfig <: StrategyConfig
    news_portal_url::String = "https://techcrunch.com/category/artificial-intelligence/"
    css_selector::String = "a[href]"
    url_pattern::Union{Nothing, String} = "/\\d{4}/\\d{2}/\\d{2}/"
end

Base.@kwdef struct AINewsAgentInput <: StrategyInput
end

function extract_latest_article_url(html::String, css_selector::String, url_pattern::Union{Nothing, String})::Union{String, Nothing}
    parsed = parsehtml(html)
    nodes = eachmatch(Selector(css_selector), parsed.root)

    for node in nodes
        href = Gumbo.getattr(node, "href")
        if href === nothing || !startswith(href, "http")
            continue
        end

        if isnothing(url_pattern) || occursin(Regex(url_pattern), href)
            return href
        end
    end

    return nothing
end

function strategy_ai_news_scraping(cfg::StrategyAINewsAgentConfig, ctx::AgentContext, input::Nothing)::AgentContext
    scrape_index = findfirst(t -> t.metadata.name == "scrape_article_text", ctx.tools)
    summarize_index = findfirst(t -> t.metadata.name == "summarize_for_post", ctx.tools)
    post_to_x_index = findfirst(t -> t.metadata.name == "post_to_x", ctx.tools)

    if scrape_index === nothing || summarize_index === nothing || post_to_x_index === nothing
        push!(ctx.logs, "Missing required tool(s)")
        return ctx
    end
    scrape_tool = ctx.tools[scrape_index]
    summarize_tool = ctx.tools[summarize_index]
    post_tool = ctx.tools[post_to_x_index]

    portal_html = ""
    try
        response = HTTP.get(cfg.news_portal_url)
        portal_html = String(response.body)
    catch e
        push!(ctx.logs, "Failed to fetch portal HTML: $(cfg.news_portal_url) — $(sprint(showerror, e))")
        return ctx
    end

    article_url = extract_latest_article_url(portal_html, cfg.css_selector, cfg.url_pattern)
    if article_url === nothing
        push!(ctx.logs, "No matching article URL found on portal")
        return ctx
    end

    article_result = scrape_tool.execute(scrape_tool.config, Dict("url" => article_url))
    if !get(article_result, "success", false)
        push!(ctx.logs, "Failed to scrape article: $article_url")
        return ctx
    end

    article_text = article_result["text"]

    summarize_result = summarize_tool.execute(summarize_tool.config, Dict(
        "text" => article_text,
        "url" => article_url
    ))

    if !get(summarize_result, "success", false)
        push!(ctx.logs, "Failed to summarize article: $article_url")
        return ctx
    end

    tweet = String(summarize_result["post_text"])
    @info "Generated tweet: $tweet"

    push!(ctx.logs, "Posting to X...")
    try
        result = post_tool.execute(post_tool.config, Dict("blog_text" => tweet))
        if result["success"]
            push!(ctx.logs, "Posted to X successfully.")
        else
            push!(ctx.logs, "ERROR: Failed to post to X: $(result["error"])")
        end
    catch e
        push!(ctx.logs, "ERROR: Exception during X post: $e")
    end

    return ctx
end

const STRATEGY_AI_NEWS_SCRAPING_METADATA = StrategyMetadata(
    "ai_news_scraping"
)

const STRATEGY_AI_NEWS_SCRAPING_SPECIFICATION = StrategySpecification(
    strategy_ai_news_scraping,
    nothing,
    StrategyAINewsAgentConfig,
    STRATEGY_AI_NEWS_SCRAPING_METADATA,
    nothing
)

