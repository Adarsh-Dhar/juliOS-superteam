#!/usr/bin/env julia

# Simple Analytics API Server with integrated get_analytics function
using HTTP, JSON3, Dates, Random, Statistics

println("🚀 Starting Simple Analytics API Server")
println(repeat("=", 50))

# Helper function to count occurrences
function countmap(items)
    counts = Dict{Any, Int}()
    for item in items
        counts[item] = get(counts, item, 0) + 1
    end
    return counts
end

# Mock sentiment analysis function
function mock_sentiment_analysis(text)
    text = lowercase(text)
    positive_words = ["help", "good", "great", "awesome", "love", "like", "happy", "nice"]
    negative_words = ["warning", "glitch", "struggling", "disorder", "doubts", "fight", "bad", "terrible"]
    
    positive_count = sum([count(word, text) for word in positive_words])
    negative_count = sum([count(word, text) for word in negative_words])
    
    if positive_count > negative_count
        return :positive, 0.8 + rand() * 0.2
    elseif negative_count > positive_count
        return :negative, 0.7 + rand() * 0.3
    else
        return :neutral, 0.6 + rand() * 0.4
    end
end

# Sample Reddit data
function get_reddit_data()
    return [
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
end

# Main get_analytics function
function get_analytics(campaign_id::String="default")
    try
        println("📊 Getting analytics for campaign: $campaign_id")
        
        # Get Reddit data
        reddit_posts = get_reddit_data()
        
        # Process sentiment analysis
        sentiment_results = []
        sentiment_counts = Dict{Symbol, Int}()
        sentiment_confidences = []
        
        for post in reddit_posts
            sentiment, confidence = mock_sentiment_analysis(post["title"])
            push!(sentiment_confidences, confidence)
            
            sentiment_counts[sentiment] = get(sentiment_counts, sentiment, 0) + 1
            
            push!(sentiment_results, Dict(
                "post_id" => post["id"],
                "text" => post["title"],
                "full_text" => post["text"],
                "sentiment" => string(sentiment),
                "confidence" => confidence,
                "subreddit" => post["subreddit"],
                "positive_score" => post["score"],
                "negative_score" => 0,
                "sentiment_words" => Dict("positive" => [], "negative" => [])
            ))
        end
        
        # Create analytics response
        analytics_response = Dict(
            "campaign" => Dict(
                "id" => campaign_id,
                "name" => "Reddit Campaign",
                "hashtag" => "#reddit_analytics",
                "description" => "Reddit sentiment analysis campaign",
                "startDate" => string(now()),
                "endDate" => string(now() + Day(30)),
                "trustScore" => 0.85,
                "metadata" => Dict("platform" => "reddit")
            ),
            
            "reddit" => Dict(
                "overview" => Dict(
                    "total_posts" => length(reddit_posts),
                    "total_engagement" => sum([post["score"] + post["num_comments"] for post in reddit_posts]),
                    "average_engagement" => mean([post["score"] + post["num_comments"] for post in reddit_posts]),
                    "unique_subreddits" => length(unique([post["subreddit"] for post in reddit_posts])),
                    "unique_authors" => length(unique([post["author"] for post in reddit_posts]))
                ),
                "posts" => reddit_posts,
                "subreddit_stats" => countmap([post["subreddit"] for post in reddit_posts])
            ),
            
            "sentiment" => Dict(
                "overview" => Dict(
                    "total_analyzed" => length(sentiment_results),
                    "average_confidence" => mean(sentiment_confidences),
                    "distribution" => sentiment_counts
                ),
                "results" => sentiment_results,
                "confidence_distribution" => Dict(
                    "high" => count([c >= 0.8 for c in sentiment_confidences]),
                    "medium" => count([0.6 <= c < 0.8 for c in sentiment_confidences]),
                    "low" => count([c < 0.6 for c in sentiment_confidences])
                )
            ),
            
            "metadata" => Dict(
                "generated_at" => string(now()),
                "campaign_id" => campaign_id,
                "data_sources" => ["reddit", "sentiment"],
                "version" => "1.0.0"
            )
        )
        
        println("✅ Analytics created successfully")
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

# API Routes
function handle_analytics_get(req)
    try
        path_parts = split(HTTP.URI(req.target).path, "/")
        campaign_id = length(path_parts) > 4 ? path_parts[5] : "default"
        
        println("📊 GET Analytics request for campaign: $campaign_id")
        
        analytics = get_analytics(campaign_id)
        return HTTP.Response(200, JSON3.write(analytics))
    catch e
        println("❌ Error in handle_analytics_get: $e")
        return HTTP.Response(500, JSON3.write(Dict("error" => "Analytics error: $e")))
    end
end

function handle_sentiment_analytics(req)
    try
        path_parts = split(HTTP.URI(req.target).path, "/")
        campaign_id = length(path_parts) > 4 ? path_parts[5] : "default"
        
        println("📊 Sentiment Analytics request for campaign: $campaign_id")
        
        analytics = get_analytics(campaign_id)
        sentiment_data = Dict(
            "sentiment" => analytics["sentiment"],
            "campaign_id" => campaign_id,
            "timestamp" => string(now())
        )
        
        return HTTP.Response(200, JSON3.write(sentiment_data))
    catch e
        println("❌ Error in handle_sentiment_analytics: $e")
        return HTTP.Response(500, JSON3.write(Dict("error" => "Sentiment error: $e")))
    end
end

function handle_health(req)
    return HTTP.Response(200, JSON3.write(Dict(
        "status" => "healthy", 
        "timestamp" => string(now()),
        "endpoints" => [
            "GET /api/v1/analytics/{campaign_id}",
            "GET /api/v1/analytics/sentiment/{campaign_id}"
        ]
    )))
end

# Request handler
function handle_request(req)
    try
        path = HTTP.URI(req.target).path
        
        if path == "/api/v1/health"
            return handle_health(req)
        elseif startswith(path, "/api/v1/analytics/") && !contains(path, "/sentiment/")
            return handle_analytics_get(req)
        elseif startswith(path, "/api/v1/analytics/sentiment/")
            return handle_sentiment_analytics(req)
        else
            return HTTP.Response(404, JSON3.write(Dict("error" => "Endpoint not found")))
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
function start_server(port=8055)
    println("🌐 Starting Simple Analytics API Server on port $port")
    println("📡 Available endpoints:")
    println("  GET /api/v1/health")
    println("  GET /api/v1/analytics/{campaign_id}")
    println("  GET /api/v1/analytics/sentiment/{campaign_id}")
    println()
    
    HTTP.serve(port) do req
        if req.method == "OPTIONS"
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

println("✅ Simple Analytics API Server ready!")
println("🔗 Access your analytics at:")
println("  http://localhost:8055/api/v1/analytics/default")
println("  http://localhost:8055/api/v1/analytics/sentiment/default")
println("  http://localhost:8055/api/v1/health") 