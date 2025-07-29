#!/usr/bin/env julia

# Debug script for analytics
using JSON3, Dates, Random, Statistics

println("🔍 Debugging Analytics Function")
println(repeat("=", 50))

# Include the analytics functions
include("get_analytics.jl")

println("✅ Functions loaded")

try
    println("🧪 Testing get_analytics function...")
    result = get_analytics("test")
    println("✅ get_analytics completed successfully")
    println("📊 Result keys: ", keys(result))
    
    if haskey(result, "sentiment")
        println("✅ Sentiment data found")
        println("📈 Sentiment overview: ", result["sentiment"]["overview"])
    else
        println("❌ No sentiment data found")
    end
    
    if haskey(result, "reddit")
        println("✅ Reddit data found")
        println("📊 Reddit posts: ", result["reddit"]["overview"]["total_posts"])
    else
        println("❌ No reddit data found")
    end
    
catch e
    println("❌ Error in get_analytics: $e")
    println("🔍 Error type: ", typeof(e))
    println("📝 Stack trace:")
    for (exc, bt) in Base.catch_stack()
        showerror(stdout, exc, bt)
        println()
    end
end

println("�� Debug complete") 