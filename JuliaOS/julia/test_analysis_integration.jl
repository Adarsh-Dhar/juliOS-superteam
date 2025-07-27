#!/usr/bin/env julia

# Test script for analysis agent integration
println("Testing Analysis Agent Integration...")

# Include the server module
include("src/juliaos_server.jl")

println("✓ Server module loaded successfully")

# Test agent creation
println("\nTesting agent creation...")

# Test data for sentiment analyzer
sentiment_data = Dict(
    "name" => "test-sentiment-analyzer",
    "type" => "SENTIMENTANALYZER",
    "parameters" => Dict(
        "min_confidence" => 0.6,
        "batch_size" => 32
    )
)

# Test data for trend analyzer
trend_data = Dict(
    "name" => "test-trend-analyzer", 
    "type" => "TRENDANALYZER",
    "parameters" => Dict(
        "languages" => ["english"],
        "min_trend_growth" => 2.0,
        "topic_threshold" => 0.15
    )
)

println("✓ Test data prepared")

# Test that the agents are registered
println("\nChecking agent registration...")
println("Registered custom agents: ", keys(JuliaOSV1Server.CUSTOM_AGENT_REGISTRY))

if haskey(JuliaOSV1Server.CUSTOM_AGENT_REGISTRY, "SENTIMENTANALYZER")
    println("✓ SentimentAnalyzer registered")
else
    println("✗ SentimentAnalyzer not registered")
end

if haskey(JuliaOSV1Server.CUSTOM_AGENT_REGISTRY, "TRENDANALYZER")
    println("✓ TrendAnalyzer registered")
else
    println("✗ TrendAnalyzer not registered")
end

println("\nIntegration test completed!") 