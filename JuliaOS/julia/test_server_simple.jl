#!/usr/bin/env julia

# Simple test script to verify Julia server functionality
using HTTP, JSON3

println("🧪 Testing Julia Analytics Server...")

# Test the server endpoints
base_url = "http://localhost:8053/api/v1"

# Test health endpoint
println("\n📡 Testing health endpoint...")
try
    response = HTTP.get("$base_url/health")
    println("✅ Health check passed: $(response.status)")
    println("📊 Response: $(String(response.body))")
catch e
    println("❌ Health check failed: $e")
end

# Test analytics endpoint
println("\n📡 Testing analytics endpoint...")
try
    response = HTTP.get("$base_url/analytics/default")
    println("✅ Analytics check passed: $(response.status)")
    data = JSON3.read(String(response.body))
    println("📊 Campaign ID: $(get(data, "campaign", Dict())["id"])")
    println("📊 Total posts: $(get(get(data, "reddit", Dict()), "overview", Dict())["total_posts"])")
catch e
    println("❌ Analytics check failed: $e")
end

# Test reddit endpoint
println("\n📡 Testing reddit endpoint...")
try
    response = HTTP.get("$base_url/analytics/reddit/default")
    println("✅ Reddit check passed: $(response.status)")
    data = JSON3.read(String(response.body))
    println("📊 Reddit data received")
catch e
    println("❌ Reddit check failed: $e")
end

# Test sentiment endpoint
println("\n📡 Testing sentiment endpoint...")
try
    response = HTTP.get("$base_url/analytics/sentiment/default")
    println("✅ Sentiment check passed: $(response.status)")
    data = JSON3.read(String(response.body))
    println("📊 Sentiment data received")
catch e
    println("❌ Sentiment check failed: $e")
end

println("\n🎉 Test completed!") 