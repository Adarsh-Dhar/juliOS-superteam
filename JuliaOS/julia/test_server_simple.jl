#!/usr/bin/env julia

# Simple server test
using HTTP, JSON3, Dates

println("🧪 Testing Simple Server")
println(repeat("=", 40))

# Simple test function
function test_get_analytics(campaign_id::String="default")
    return Dict(
        "test" => "success",
        "campaign_id" => campaign_id,
        "timestamp" => string(now())
    )
end

# Simple handler
function handle_simple_analytics(req)
    try
        path_parts = split(HTTP.URI(req.target).path, "/")
        campaign_id = length(path_parts) > 4 ? path_parts[5] : "default"
        
        println("📊 Simple analytics request for campaign: $campaign_id")
        
        result = test_get_analytics(campaign_id)
        return HTTP.Response(200, JSON3.write(result))
    catch e
        println("❌ Error in simple handler: $e")
        return HTTP.Response(500, JSON3.write(Dict("error" => "Simple handler error: $e")))
    end
end

# Simple server
function start_simple_server(port=8054)
    println("🌐 Starting Simple Test Server on port $port")
    
    HTTP.serve(port) do req
        if req.method == "OPTIONS"
            return HTTP.Response(200, "", ["Access-Control-Allow-Origin" => "*"])
        else
            response = handle_simple_analytics(req)
            response.headers = [
                "Access-Control-Allow-Origin" => "*",
                "Content-Type" => "application/json"
            ]
            return response
        end
    end
end

# Start server
if abspath(PROGRAM_FILE) == @__FILE__
    start_simple_server()
end

println("✅ Simple test server ready!") 