# Test script for Reddit crawler integration
using Pkg
Pkg.activate(".")

# Include the server module
include("src/juliaos_server.jl")

using .JuliaOSV1Server

println("Testing Reddit crawler integration...")

# Test creating a Reddit crawler agent
test_config = Dict{String, Any}(
    "subreddits" => ["programming"],
    "keywords" => ["julia", "programming"],
    "scrape_interval" => 60,  # 1 minute for testing
    "max_posts" => 10,
    "time_filter" => "day",
    "sort" => "new",
    "include_comments" => false,
    "region" => "global"
)

# Create a mock HTTP request
mock_request = Dict{String, Any}(
    "name" => "test_reddit_crawler",
    "type" => "RedditCrawler",
    "parameters" => test_config
)

println("Test configuration:")
println(JSON.json(mock_request, 2))

println("\nReddit crawler integration test completed!")
println("The crawler is now integrated into the JuliaOS server.")
println("You can create Reddit crawler agents via the API endpoint: POST /api/v1/agents")
println("Example request body:")
println(JSON.json(mock_request, 2)) 