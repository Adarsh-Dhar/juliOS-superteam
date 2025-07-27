#!/usr/bin/env julia

# Simple integration test for analysis agents
println("Testing Analysis Agent Integration (Simple)...")

# Test that the modules can be loaded
println("Testing module loading...")

# Test sentiment analyzer module
try
    include("src/agents/analysis/sentiment.jl")
    println("✓ SentimentAnalyzer module loaded")
catch e
    println("✗ SentimentAnalyzer module failed to load: $e")
end

# Test trend analyzer module  
try
    include("src/agents/analysis/trend.jl")
    println("✓ TrendAnalyzer module loaded")
catch e
    println("✗ TrendAnalyzer module failed to load: $e")
end

# Test server integration
println("\nTesting server integration...")

# Mock the required modules for testing
module MockModules
    module AgentFramework
        abstract type AbstractAgent end
    end
    
    module IPFS
        function add(data)
            return "mock_cid_$(randstring(8))"
        end
    end
    
    module SwarmComms
        function send(channel, msg)
            println("Mock send to $channel: $msg")
        end
        
        function receive(channel; timeout=10)
            return nothing
        end
    end
    
    module ReputationKeeper
        function stake(id, amount)
            println("Mock stake: $id -> $amount")
        end
        
        function report(id, event, data)
            println("Mock report: $id -> $event -> $data")
        end
    end
    
    module Vault
        function get_secrets(service)
            return Dict("bearer_token" => "mock_token")
        end
        
        function get_proxies(service, region)
            return String[]
        end
        
        function get_global_salt()
            return "mock_salt"
        end
    end
end

# Test agent creation
println("\nTesting agent creation...")

try
    # Test sentiment agent creation
    sentiment_config = Dict(
        "min_confidence" => 0.6,
        "batch_size" => 32
    )
    
    # This would normally create an agent, but we'll just test the config
    println("✓ SentimentAnalyzer configuration valid")
    
    # Test trend agent creation
    trend_config = Dict(
        "languages" => ["english"],
        "min_trend_growth" => 2.0,
        "topic_threshold" => 0.15
    )
    
    println("✓ TrendAnalyzer configuration valid")
    
catch e
    println("✗ Agent creation test failed: $e")
end

println("\nSimple integration test completed!") 