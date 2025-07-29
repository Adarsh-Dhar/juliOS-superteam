#!/usr/bin/env julia

# Fixed Analytics API Server
using HTTP, JSON3, Dates, Random, Statistics

println("🚀 Starting Fixed Analytics API Server")
println(repeat("=", 50))

# Include the analytics functions
include("get_analytics.jl")

println("✅ Analytics functions loaded")

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
    println("🌐 Starting Fixed Analytics API Server on port $port")
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

println("✅ Fixed Analytics API Server ready!") 