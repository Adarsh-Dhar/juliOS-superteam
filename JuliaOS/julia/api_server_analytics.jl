#!/usr/bin/env julia

# Updated HTTP API server with GET analytics function
# Serves analytics data from reddit.jl and sentiment.jl
using HTTP, JSON3, Dates

println("🚀 Starting Analytics API Server with GET Function")
println(repeat("=", 60))

# Include the analytics functions
include("get_analytics.jl")

# Ensure the function is available in main scope
if !isdefined(Main, :get_analytics)
    # If the function is not available, define it here
    println("⚠️ get_analytics function not found, defining inline...")
    
    # Helper function to count occurrences
    function countmap(items)
        counts = Dict{Any, Int}()
        for item in items
            counts[item] = get(counts, item, 0) + 1
        end
        return counts
    end

    # Sample Reddit data (in production, this would come from reddit.jl)
    function get_reddit_data()
        reddit_data = [
            Dict(
                "id" => "1mbsu4d",
                "title" => "Dating a married woman",
                "subreddit" => "nonmonogamy",
                "score" => 15,
                "num_comments" => 8,
                "url" => "/r/nonmonogamy/comments/1mbsu4d/dating_a_married_woman/",
                "author" => "Altruistic-Smile-471",
                "created_utc" => 1753737799,
                "text" => "I've been dating a married woman for the past few months. She says she's in an open marriage but I'm starting to have doubts. What should I do?"
            ),
            Dict(
                "id" => "1mbsu4c",
                "title" => "how do i help?",
                "subreddit" => "EatingDisorders",
                "score" => 23,
                "num_comments" => 12,
                "url" => "/r/EatingDisorders/comments/1mbsu4c/how_do_i_help/",
                "author" => "Waste-Bug-3197",
                "created_utc" => 1753737799,
                "text" => "My friend is struggling with an eating disorder. I want to help but I don't know how. Any advice?"
            ),
            Dict(
                "id" => "1mbsu4b",
                "title" => "Where do these hoses connect to?",
                "subreddit" => "Miata",
                "score" => 45,
                "num_comments" => 18,
                "url" => "/r/Miata/comments/1mbsu4b/where_do_these_hoses_connect_to/",
                "author" => "easykill2517",
                "created_utc" => 1753737799,
                "text" => "I'm working on my Miata and found these loose hoses. Can anyone help me identify where they should connect?"
            ),
            Dict(
                "id" => "1mbsu4a",
                "title" => "Would you rather…",
                "subreddit" => "ChuckleSandwich",
                "score" => 67,
                "num_comments" => 34,
                "url" => "/r/ChuckleSandwich/comments/1mbsu4a/would_you_rather/",
                "author" => "supersmallpee",
                "created_utc" => 1753737799,
                "text" => "Would you rather fight 100 duck-sized horses or 1 horse-sized duck?"
            ),
            Dict(
                "id" => "1mbsu49",
                "title" => "Warning: Crimson glitch can also permanently reduce your hand size",
                "subreddit" => "balatro",
                "score" => 89,
                "num_comments" => 56,
                "url" => "/r/balatro/comments/1mbsu49/warning_crimson_glitch_can_also_permanently/",
                "author" => "misterrandom1",
                "created_utc" => 1753737799,
                "text" => "Just discovered a bug in Balatro where the Crimson card can permanently reduce your hand size. Be careful!"
            )
        ]
        
        return reddit_data
    end

    # Process Reddit data (from reddit.jl)
    function process_reddit_analytics(posts)
        reddit_analytics = Dict(
            "total_posts" => length(posts),
            "platforms" => ["reddit"],
            "subreddits" => unique([post["subreddit"] for post in posts]),
            "total_engagement" => sum([post["score"] + post["num_comments"] for post in posts]),
            "average_engagement" => mean([post["score"] + post["num_comments"] for post in posts]),
            "posts" => posts,
            "stats" => Dict(
                "total_score" => sum([post["score"] for post in posts]),
                "total_comments" => sum([post["num_comments"] for post in posts]),
                "unique_authors" => length(unique([post["author"] for post in posts])),
                "subreddit_distribution" => countmap([post["subreddit"] for post in posts]),
                "engagement_rate" => sum([post["score"] + post["num_comments"] for post in posts]) / length(posts),
                "average_score" => mean([post["score"] for post in posts]),
                "average_comments" => mean([post["num_comments"] for post in posts])
            ),
            "recent_activity" => posts[1:min(5, length(posts))],
            "top_posts" => sort(posts, by=p->p["score"] + p["num_comments"], rev=true)[1:min(3, length(posts))],
            "subreddit_engagement" => Dict(
                subreddit => sum([post["score"] + post["num_comments"] for post in posts if post["subreddit"] == subreddit])
                for subreddit in unique([post["subreddit"] for post in posts])
            )
        )
        
        return reddit_analytics
    end

    # Process sentiment data (from sentiment.jl)
    function process_sentiment_analytics(posts)
        # Mock sentiment analysis (in production, use real sentiment.jl)
        sentiment_results = []
        sentiment_distribution = Dict(:positive => 0, :negative => 0, :neutral => 0)
        
        for post in posts
            # Mock sentiment analysis based on content
            text = lowercase(post["title"] * " " * get(post, "text", ""))
            
            # Simple sentiment logic
            positive_words = ["help", "good", "great", "love", "amazing", "wonderful", "awesome"]
            negative_words = ["struggling", "warning", "doubts", "fight", "bug", "glitch", "disorder"]
            
            positive_count = sum([count(word, text) for word in positive_words])
            negative_count = sum([count(word, text) for word in negative_words])
            
            if positive_count > negative_count
                sentiment = :positive
            elseif negative_count > positive_count
                sentiment = :negative
            else
                sentiment = :neutral
            end
            
            confidence = rand() * 0.3 + 0.7  # 0.7 to 1.0
            
            sentiment_distribution[sentiment] += 1
            
            result = Dict(
                "post_id" => post["id"],
                "text" => post["title"],
                "full_text" => get(post, "text", ""),
                "sentiment" => sentiment,
                "confidence" => confidence,
                "subreddit" => post["subreddit"],
                "positive_score" => positive_count,
                "negative_score" => negative_count,
                "sentiment_words" => Dict(
                    "positive" => [word for word in positive_words if contains(text, word)],
                    "negative" => [word for word in negative_words if contains(text, word)]
                )
            )
            push!(sentiment_results, result)
        end
        
        return Dict(
            "results" => sentiment_results,
            "distribution" => sentiment_distribution,
            "total_analyzed" => length(posts),
            "average_confidence" => mean([r["confidence"] for r in sentiment_results]),
            "sentiment_breakdown" => Dict(
                "positive_posts" => sentiment_distribution[:positive],
                "negative_posts" => sentiment_distribution[:negative],
                "neutral_posts" => sentiment_distribution[:neutral],
                "positive_percentage" => round(sentiment_distribution[:positive] / length(posts) * 100, digits=1),
                "negative_percentage" => round(sentiment_distribution[:negative] / length(posts) * 100, digits=1),
                "neutral_percentage" => round(sentiment_distribution[:neutral] / length(posts) * 100, digits=1)
            ),
            "subreddit_sentiment" => Dict(
                subreddit => Dict(
                    "positive" => sum([r["sentiment"] == :positive ? 1 : 0 for r in sentiment_results if r["subreddit"] == subreddit]),
                    "negative" => sum([r["sentiment"] == :negative ? 1 : 0 for r in sentiment_results if r["subreddit"] == subreddit]),
                    "neutral" => sum([r["sentiment"] == :neutral ? 1 : 0 for r in sentiment_results if r["subreddit"] == subreddit])
                )
                for subreddit in unique([r["subreddit"] for r in sentiment_results])
            ),
            "confidence_distribution" => Dict(
                "high" => sum([r["confidence"] >= 0.9 ? 1 : 0 for r in sentiment_results]),
                "medium" => sum([r["confidence"] >= 0.7 && r["confidence"] < 0.9 ? 1 : 0 for r in sentiment_results]),
                "low" => sum([r["confidence"] < 0.7 ? 1 : 0 for r in sentiment_results])
            )
        )
    end

    # Main GET function for analytics - Define it in global scope
    global get_analytics
    function get_analytics(campaign_id::String="default")
        println("🔍 Getting analytics for campaign: $campaign_id")
        
        try
            # Step 1: Get Reddit data
            println("📊 Step 1: Retrieving Reddit data...")
            reddit_posts = get_reddit_data()
            reddit_analytics = process_reddit_analytics(reddit_posts)
            
            println("✅ Reddit data processed")
            println("  Total posts: $(reddit_analytics["total_posts"])")
            println("  Total engagement: $(reddit_analytics["total_engagement"])")
            println("  Subreddits: $(join(reddit_analytics["subreddits"], ", "))")
            
            # Step 2: Get Sentiment data
            println("\n📊 Step 2: Processing sentiment analysis...")
            sentiment_analytics = process_sentiment_analytics(reddit_posts)
            
            println("✅ Sentiment analysis processed")
            println("  Analyzed posts: $(sentiment_analytics["total_analyzed"])")
            println("  Distribution: $(sentiment_analytics["distribution"])")
            println("  Avg confidence: $(round(sentiment_analytics["average_confidence"], digits=2))")
            
            # Step 3: Create unified analytics response
            println("\n📊 Step 3: Creating unified analytics...")
            
            analytics_response = Dict(
                "campaign" => Dict(
                    "id" => campaign_id,
                    "name" => "Reddit & Sentiment Analytics",
                    "platform" => "reddit",
                    "start_date" => string(now()),
                    "status" => "active",
                    "data_sources" => ["reddit.jl", "sentiment.jl"]
                ),
                
                # Reddit Analytics (from reddit.jl)
                "reddit" => Dict(
                    "overview" => Dict(
                        "total_posts" => reddit_analytics["total_posts"],
                        "total_engagement" => reddit_analytics["total_engagement"],
                        "average_engagement" => reddit_analytics["average_engagement"],
                        "platforms" => reddit_analytics["platforms"],
                        "subreddits" => reddit_analytics["subreddits"]
                    ),
                    "stats" => reddit_analytics["stats"],
                    "recent_activity" => reddit_analytics["recent_activity"],
                    "top_posts" => reddit_analytics["top_posts"],
                    "subreddit_engagement" => reddit_analytics["subreddit_engagement"]
                ),
                
                # Sentiment Analytics (from sentiment.jl)
                "sentiment" => Dict(
                    "overview" => Dict(
                        "total_analyzed" => sentiment_analytics["total_analyzed"],
                        "average_confidence" => sentiment_analytics["average_confidence"],
                        "distribution" => sentiment_analytics["distribution"],
                        "sentiment_breakdown" => sentiment_analytics["sentiment_breakdown"]
                    ),
                    "results" => sentiment_analytics["results"],
                    "subreddit_sentiment" => sentiment_analytics["subreddit_sentiment"],
                    "confidence_distribution" => sentiment_analytics["confidence_distribution"]
                ),
                
                # Combined Analytics
                "combined" => Dict(
                    "total_posts" => reddit_analytics["total_posts"],
                    "total_engagement" => reddit_analytics["total_engagement"],
                    "sentiment_analyzed" => sentiment_analytics["total_analyzed"],
                    "average_sentiment_confidence" => sentiment_analytics["average_confidence"],
                    "engagement_per_post" => reddit_analytics["total_engagement"] / reddit_analytics["total_posts"],
                    "sentiment_engagement_correlation" => Dict(
                        "positive_engagement" => begin
                            total = 0
                            for post in reddit_posts
                                result_idx = findfirst(r -> r["post_id"] == post["id"], sentiment_analytics["results"])
                                if result_idx !== nothing && sentiment_analytics["results"][result_idx]["sentiment"] == :positive
                                    total += post["score"] + post["num_comments"]
                                end
                            end
                            total
                        end,
                        "negative_engagement" => begin
                            total = 0
                            for post in reddit_posts
                                result_idx = findfirst(r -> r["post_id"] == post["id"], sentiment_analytics["results"])
                                if result_idx !== nothing && sentiment_analytics["results"][result_idx]["sentiment"] == :negative
                                    total += post["score"] + post["num_comments"]
                                end
                            end
                            total
                        end,
                        "neutral_engagement" => begin
                            total = 0
                            for post in reddit_posts
                                result_idx = findfirst(r -> r["post_id"] == post["id"], sentiment_analytics["results"])
                                if result_idx !== nothing && sentiment_analytics["results"][result_idx]["sentiment"] == :neutral
                                    total += post["score"] + post["num_comments"]
                                end
                            end
                            total
                        end
                    )
                ),
                
                # Timeline Data
                "timeline" => Dict(
                    "posts" => [Dict(
                        "date" => string(unix2datetime(post["created_utc"])),
                        "engagement" => post["score"] + post["num_comments"],
                        "platform" => "reddit",
                        "subreddit" => post["subreddit"],
                        "sentiment" => begin
                            result_idx = findfirst(r -> r["post_id"] == post["id"], sentiment_analytics["results"])
                            result_idx !== nothing ? sentiment_analytics["results"][result_idx]["sentiment"] : :neutral
                        end
                    ) for post in reddit_posts],
                    "sentiment_trend" => [Dict(
                        "date" => string(now()),
                        "positive" => sentiment_analytics["distribution"][:positive],
                        "negative" => sentiment_analytics["distribution"][:negative],
                        "neutral" => sentiment_analytics["distribution"][:neutral]
                    )]
                ),
                
                # Metadata
                "metadata" => Dict(
                    "generated_at" => string(now()),
                    "campaign_id" => campaign_id,
                    "data_sources" => ["reddit.jl", "sentiment.jl"],
                    "version" => "1.0.0"
                )
            )
            
            println("✅ Unified analytics created")
            println("  Campaign ID: $(analytics_response["campaign"]["id"])")
            println("  Total posts: $(analytics_response["reddit"]["overview"]["total_posts"])")
            println("  Sentiment analyzed: $(analytics_response["sentiment"]["overview"]["total_analyzed"])")
            println("  Average confidence: $(round(analytics_response["sentiment"]["overview"]["average_confidence"], digits=2))")
            
            return analytics_response
            
        catch e
            println("❌ Error getting analytics: $e")
            return Dict(
                "error" => "Failed to get analytics",
                "message" => string(e),
                "campaign_id" => campaign_id
            )
        end
    end
end

# Load existing analytics data
function load_analytics_data()
    try
        campaign_data = JSON3.read("api_campaign_analytics.json")
        analysis_data = JSON3.read("api_analysis_analytics.json")
        consensus_data = JSON3.read("api_consensus_analytics.json")
        crawler_data = JSON3.read("api_crawler_analytics.json")
        
        return Dict(
            "campaign" => campaign_data,
            "analysis" => analysis_data,
            "consensus" => consensus_data,
            "crawler" => crawler_data
        )
    catch e
        println("❌ Error loading analytics data: $e")
        return Dict()
    end
end

# Initialize data
analytics_data = load_analytics_data()
println("✅ Analytics data loaded")

# API Routes
function handle_analytics_get(req)
    try
        # Extract campaign ID from URL
        path_parts = split(HTTP.URI(req.target).path, "/")
        campaign_id = length(path_parts) > 4 ? path_parts[5] : "default"
        
        println("📊 GET Analytics request for campaign: $campaign_id")
        
        # Check if get_analytics function is available
        if !isdefined(Main, :get_analytics)
            println("❌ get_analytics function not found!")
            return HTTP.Response(500, JSON3.write(Dict("error" => "get_analytics function not available")))
        end
        
        # Use the new GET analytics function
        println("🔍 Calling get_analytics...")
        analytics = get_analytics(campaign_id)
        println("✅ get_analytics completed successfully")
        
        return HTTP.Response(200, JSON3.write(analytics))
    catch e
        println("❌ Error in handle_analytics_get: $e")
        println("🔍 Error type: ", typeof(e))
        return HTTP.Response(500, JSON3.write(Dict("error" => "Analytics error: $e")))
    end
end

function handle_campaign_analytics(req)
    campaign_id = HTTP.queryparams(HTTP.URI(req.target))["id"]
    return HTTP.Response(200, JSON3.write(analytics_data["campaign"]))
end

function handle_analysis_analytics(req)
    campaign_id = HTTP.queryparams(HTTP.URI(req.target))["id"]
    return HTTP.Response(200, JSON3.write(analytics_data["analysis"]))
end

function handle_consensus_analytics(req)
    campaign_id = HTTP.queryparams(HTTP.URI(req.target))["id"]
    return HTTP.Response(200, JSON3.write(analytics_data["consensus"]))
end

function handle_crawler_analytics(req)
    campaign_id = HTTP.queryparams(HTTP.URI(req.target))["id"]
    return HTTP.Response(200, JSON3.write(analytics_data["crawler"]))
end

function handle_reddit_analytics(req)
    # Extract campaign ID from URL
    path_parts = split(HTTP.URI(req.target).path, "/")
    campaign_id = length(path_parts) > 4 ? path_parts[5] : "default"
    
    println("📊 Reddit Analytics request for campaign: $campaign_id")
    
    # Get analytics and return only reddit data
    analytics = get_analytics(campaign_id)
    reddit_data = Dict(
        "reddit" => analytics["reddit"],
        "campaign_id" => campaign_id,
        "timestamp" => string(now())
    )
    
    return HTTP.Response(200, JSON3.write(reddit_data))
end

function handle_sentiment_analytics(req)
    # Extract campaign ID from URL
    path_parts = split(HTTP.URI(req.target).path, "/")
    campaign_id = length(path_parts) > 4 ? path_parts[5] : "default"
    
    println("📊 Sentiment Analytics request for campaign: $campaign_id")
    
    # Get analytics and return only sentiment data
    analytics = get_analytics(campaign_id)
    sentiment_data = Dict(
        "sentiment" => analytics["sentiment"],
        "campaign_id" => campaign_id,
        "timestamp" => string(now())
    )
    
    return HTTP.Response(200, JSON3.write(sentiment_data))
end

function handle_health(req)
    return HTTP.Response(200, JSON3.write(Dict(
        "status" => "healthy", 
        "timestamp" => string(now()),
        "endpoints" => [
            "GET /api/v1/analytics/{campaign_id}",
            "GET /api/v1/analytics/reddit/{campaign_id}",
            "GET /api/v1/analytics/sentiment/{campaign_id}",
            "GET /api/v1/analytics/campaign/{campaign_id}",
            "GET /api/v1/analytics/analysis/{campaign_id}",
            "GET /api/v1/analytics/consensus/{campaign_id}",
            "GET /api/v1/analytics/crawler/{campaign_id}"
        ]
    )))
end

# Request handler
function handle_request(req)
    try
        path = HTTP.URI(req.target).path
        
        if path == "/api/v1/health"
            return handle_health(req)
        elseif startswith(path, "/api/v1/analytics/") && !contains(path, "/reddit/") && !contains(path, "/sentiment/") && !contains(path, "/campaign/") && !contains(path, "/analysis/") && !contains(path, "/consensus/") && !contains(path, "/crawler/")
            # Main analytics endpoint
            return handle_analytics_get(req)
        elseif startswith(path, "/api/v1/analytics/reddit/")
            return handle_reddit_analytics(req)
        elseif startswith(path, "/api/v1/analytics/sentiment/")
            return handle_sentiment_analytics(req)
        elseif startswith(path, "/api/v1/analytics/campaign/")
            return handle_campaign_analytics(req)
        elseif startswith(path, "/api/v1/analytics/analysis/")
            return handle_analysis_analytics(req)
        elseif startswith(path, "/api/v1/analytics/consensus/")
            return handle_consensus_analytics(req)
        elseif startswith(path, "/api/v1/analytics/crawler/")
            return handle_crawler_analytics(req)
        else
            return HTTP.Response(404, JSON3.write(Dict(
                "error" => "Endpoint not found",
                "available_endpoints" => [
                    "/api/v1/health",
                    "/api/v1/analytics/{campaign_id}",
                    "/api/v1/analytics/reddit/{campaign_id}",
                    "/api/v1/analytics/sentiment/{campaign_id}",
                    "/api/v1/analytics/campaign/{campaign_id}",
                    "/api/v1/analytics/analysis/{campaign_id}",
                    "/api/v1/analytics/consensus/{campaign_id}",
                    "/api/v1/analytics/crawler/{campaign_id}"
                ]
            )))
        end
    catch e
        println("❌ Error handling request: $e")
        return HTTP.Response(500, JSON3.write(Dict("error" => "Internal server error")))
    end
end

# CORS headers
function add_cors_headers(response)
    response.headers = [
        "Access-Control-Allow-Origin" => "*",
        "Access-Control-Allow-Methods" => "GET, POST, PUT, DELETE, OPTIONS",
        "Access-Control-Allow-Headers" => "Content-Type, Authorization",
        "Content-Type" => "application/json"
    ]
    return response
end

# Main server function
function start_server(port=8053)
    println("🌐 Starting Analytics API Server on port $port")
    println("📡 Available endpoints:")
    println("  GET /api/v1/health")
    println("  GET /api/v1/analytics/{campaign_id}           # Main analytics (reddit + sentiment)")
    println("  GET /api/v1/analytics/reddit/{campaign_id}    # Reddit data only")
    println("  GET /api/v1/analytics/sentiment/{campaign_id} # Sentiment data only")
    println("  GET /api/v1/analytics/campaign/{campaign_id}  # Campaign overview")
    println("  GET /api/v1/analytics/analysis/{campaign_id}  # Analysis data")
    println("  GET /api/v1/analytics/consensus/{campaign_id} # Consensus data")
    println("  GET /api/v1/analytics/crawler/{campaign_id}   # Crawler data")
    println()
    
    HTTP.serve(port) do req
        if req.method == "OPTIONS"
            # Handle CORS preflight
            return add_cors_headers(HTTP.Response(200, ""))
        else
            response = handle_request(req)
            return add_cors_headers(response)
        end
    end
end

# Start the server
if abspath(PROGRAM_FILE) == @__FILE__
    start_server()
end

println("✅ Analytics API Server ready!")
println("🔗 Access your analytics at:")
println("  http://localhost:8053/api/v1/analytics/default")
println("  http://localhost:8053/api/v1/analytics/reddit/default")
println("  http://localhost:8053/api/v1/analytics/sentiment/default")
println("  http://localhost:8053/api/v1/health") 