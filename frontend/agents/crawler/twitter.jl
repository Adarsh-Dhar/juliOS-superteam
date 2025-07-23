# File: twitter_crawler.jl
using JuliaOS.Agents, HTTP, JSON

struct TwitterCrawler <: Agent 
    keywords::Vector{String}
    rate_limit::Int
end

function scrape(crawler::TwitterCrawler)
    # Use Twitter API v2 with OAuth2
    headers = ["Authorization" => "Bearer $(ENV["TWITTER_BEARER_TOKEN"])"]
    params = Dict("query" => join(crawler.keywords, " OR "), "max_results" => 100)
    
    response = HTTP.get("https://api.twitter.com/2/tweets/search/recent", headers, query=params)
    return JSON.parse(String(response.body))["data"]
end

function run(crawler::TwitterCrawler)
    while true
        try
            data = scrape(crawler)
            cid = IPFS.add(data)  # Store to IPFS
            emit_event(:new_content, (source=:twitter, cid=cid))
        catch e
            log_error("Crawler failed: $e")
        end
        sleep(crawler.rate_limit)
    end
end