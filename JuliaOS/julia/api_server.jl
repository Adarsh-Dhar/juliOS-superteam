#!/usr/bin/env julia

# Simple HTTP API server to serve analytics data
using HTTP, JSON3, Dates

println("🚀 Starting Analytics API Server")
println(repeat("=", 50))

# Load analytics data
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

function handle_health(req)
    return HTTP.Response(200, JSON3.write(Dict("status" => "healthy", "timestamp" => string(now()))))
end

# Request handler
function handle_request(req)
    try
        path = HTTP.URI(req.target).path
        
        if path == "/api/v1/health"
            return handle_health(req)
        elseif startswith(path, "/api/v1/analytics/campaign/")
            return handle_campaign_analytics(req)
        elseif startswith(path, "/api/v1/analytics/analysis/")
            return handle_analysis_analytics(req)
        elseif startswith(path, "/api/v1/analytics/consensus/")
            return handle_consensus_analytics(req)
        elseif startswith(path, "/api/v1/analytics/crawler/")
            return handle_crawler_analytics(req)
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
function start_server(port=8053)
    println("🌐 Starting server on port $port")
    println("📡 Available endpoints:")
    println("  GET /api/v1/health")
    println("  GET /api/v1/analytics/campaign/{id}")
    println("  GET /api/v1/analytics/analysis/{id}")
    println("  GET /api/v1/analytics/consensus/{id}")
    println("  GET /api/v1/analytics/crawler/{id}")
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

println("✅ API server ready!")
println("🔗 Access your analytics at:")
println("  http://localhost:8053/api/v1/analytics/campaign/reddit_campaign_Ih2Pd1")
println("  http://localhost:8053/api/v1/analytics/analysis/reddit_campaign_Ih2Pd1")
println("  http://localhost:8053/api/v1/analytics/consensus/reddit_campaign_Ih2Pd1")
println("  http://localhost:8053/api/v1/analytics/crawler/reddit_campaign_Ih2Pd1") 