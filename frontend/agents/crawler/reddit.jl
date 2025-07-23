# File: reddit_crawler.jl
using JuliaOS.Agents, HTTP, JSON

struct RedditCrawler <: Agent 
    keywords::Vector{String}
    rate_limit::Int
end

function scrape(crawler::RedditCrawler)
    # Use Reddit API (public search, no auth for basic queries)
    params = Dict("q" => join(crawler.keywords, " OR "), "limit" => 100, "sort" => "new")
    response = HTTP.get("https://www.reddit.com/search.json", query=params, headers=["User-Agent" => "JuliaCrawler/1.0"])
    posts = JSON.parse(String(response.body))["data"]["children"]
    return [post["data"] for post in posts]
end

function run(crawler::RedditCrawler)
    while true
        try
            data = scrape(crawler)
            cid = IPFS.add(data)  # Store to IPFS
            emit_event(:new_content, (source=:reddit, cid=cid))
        catch e
            log_error("Crawler failed: $e")
        end
        sleep(crawler.rate_limit)
    end
end
