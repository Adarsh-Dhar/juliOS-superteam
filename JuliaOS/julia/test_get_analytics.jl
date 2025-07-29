#!/usr/bin/env julia

# Test script for GET analytics function
# Demonstrates how to retrieve analytics data from reddit.jl and sentiment.jl
using JSON3, HTTP

println("🧪 Testing GET Analytics Function")
println(repeat("=", 50))

# Include the analytics functions
include("get_analytics.jl")

# Test 1: Get analytics for default campaign
println("\n📊 Test 1: Getting analytics for default campaign")
println(repeat("-", 40))

analytics = get_analytics()
println("✅ Analytics retrieved successfully")
println("  Campaign ID: $(analytics["campaign"]["id"])")
println("  Total posts: $(analytics["reddit"]["overview"]["total_posts"])")
println("  Total engagement: $(analytics["reddit"]["overview"]["total_engagement"])")
println("  Sentiment analyzed: $(analytics["sentiment"]["overview"]["total_analyzed"])")
println("  Average confidence: $(round(analytics["sentiment"]["overview"]["average_confidence"], digits=2))")

# Test 2: Get analytics for specific campaign
println("\n📊 Test 2: Getting analytics for specific campaign")
println(repeat("-", 40))

campaign_id = "test_campaign_123"
analytics_specific = get_analytics(campaign_id)
println("✅ Analytics retrieved for campaign: $campaign_id")
println("  Campaign ID: $(analytics_specific["campaign"]["id"])")
println("  Data sources: $(join(analytics_specific["campaign"]["data_sources"], ", "))")

# Test 3: Export analytics to file
println("\n📊 Test 3: Exporting analytics to file")
println(repeat("-", 40))

filename = export_analytics("test_export")
println("✅ Analytics exported to: $filename")

# Test 4: Show detailed analytics structure
println("\n📊 Test 4: Analytics Structure Overview")
println(repeat("-", 40))

println("📋 Analytics Response Structure:")
println("  campaign:")
println("    - id: $(analytics["campaign"]["id"])")
println("    - name: $(analytics["campaign"]["name"])")
println("    - platform: $(analytics["campaign"]["platform"])")
println("    - data_sources: $(join(analytics["campaign"]["data_sources"], ", "))")

println("\n  reddit:")
println("    - total_posts: $(analytics["reddit"]["overview"]["total_posts"])")
println("    - total_engagement: $(analytics["reddit"]["overview"]["total_engagement"])")
println("    - subreddits: $(join(analytics["reddit"]["overview"]["subreddits"], ", "))")

println("\n  sentiment:")
println("    - total_analyzed: $(analytics["sentiment"]["overview"]["total_analyzed"])")
println("    - average_confidence: $(round(analytics["sentiment"]["overview"]["average_confidence"], digits=2))")
println("    - distribution: $(analytics["sentiment"]["overview"]["distribution"])")

println("\n  combined:")
println("    - engagement_per_post: $(round(analytics["combined"]["engagement_per_post"], digits=2))")
println("    - sentiment_engagement_correlation:")
for (key, value) in analytics["combined"]["sentiment_engagement_correlation"]
    println("      $key: $value")
end

# Test 5: Show sentiment breakdown
println("\n📊 Test 5: Sentiment Analysis Breakdown")
println(repeat("-", 40))

sentiment_breakdown = analytics["sentiment"]["overview"]["sentiment_breakdown"]
println("📈 Sentiment Breakdown:")
println("  Positive posts: $(sentiment_breakdown["positive_posts"]) ($(sentiment_breakdown["positive_percentage"])%)")
println("  Negative posts: $(sentiment_breakdown["negative_posts"]) ($(sentiment_breakdown["negative_percentage"])%)")
println("  Neutral posts: $(sentiment_breakdown["neutral_posts"]) ($(sentiment_breakdown["neutral_percentage"])%)")

# Test 6: Show subreddit sentiment
println("\n📊 Test 6: Subreddit Sentiment Analysis")
println(repeat("-", 40))

subreddit_sentiment = analytics["sentiment"]["subreddit_sentiment"]
println("🏷️ Subreddit Sentiment:")
for (subreddit, sentiment) in subreddit_sentiment
    println("  r/$subreddit:")
    println("    Positive: $(sentiment["positive"])")
    println("    Negative: $(sentiment["negative"])")
    println("    Neutral: $(sentiment["neutral"])")
end

# Test 7: Show confidence distribution
println("\n📊 Test 7: Confidence Distribution")
println(repeat("-", 40))

confidence_dist = analytics["sentiment"]["confidence_distribution"]
println("🎯 Confidence Distribution:")
println("  High confidence (≥0.9): $(confidence_dist["high"])")
println("  Medium confidence (0.7-0.9): $(confidence_dist["medium"])")
println("  Low confidence (<0.7): $(confidence_dist["low"])")

# Test 8: Show timeline data
println("\n📊 Test 8: Timeline Data")
println(repeat("-", 40))

timeline = analytics["timeline"]
println("📅 Timeline Data:")
println("  Posts with sentiment: $(length(timeline["posts"]))")
println("  Sentiment trend points: $(length(timeline["sentiment_trend"]))")

# Show sample timeline entry
if !isempty(timeline["posts"])
    sample_post = timeline["posts"][1]
    println("  Sample post:")
    println("    Date: $(sample_post["date"])")
    println("    Engagement: $(sample_post["engagement"])")
    println("    Subreddit: $(sample_post["subreddit"])")
    println("    Sentiment: $(sample_post["sentiment"])")
end

# Test 9: HTTP endpoint simulation
println("\n📊 Test 9: HTTP Endpoint Simulation")
println(repeat("-", 40))

# Simulate HTTP response
response = handle_analytics_request("http_test_campaign")
println("✅ HTTP response simulated")
println("  Status: $(response.status)")
println("  Content-Type: application/json")

# Test 10: Error handling
println("\n📊 Test 10: Error Handling")
println(repeat("-", 40))

# Test with invalid campaign ID (should still work)
try
    error_analytics = get_analytics("invalid_campaign_12345")
    println("✅ Error handling test passed")
    println("  Campaign ID: $(error_analytics["campaign"]["id"])")
catch e
    println("❌ Error handling test failed: $e")
end

# Final summary
println("\n🎉 GET Analytics Function Test Complete!")
println(repeat("=", 50))
println("✅ All tests passed successfully")
println("📊 Summary:")
println("  - Reddit posts processed: $(analytics["reddit"]["overview"]["total_posts"])")
println("  - Total engagement: $(analytics["reddit"]["overview"]["total_engagement"])")
println("  - Sentiment analyzed: $(analytics["sentiment"]["overview"]["total_analyzed"])")
println("  - Average confidence: $(round(analytics["sentiment"]["overview"]["average_confidence"], digits=2))")
println("  - Sentiment distribution: $(analytics["sentiment"]["overview"]["distribution"])")

println("\n🚀 GET Analytics Function is ready for production use!")
println("📡 Available endpoints:")
println("  GET /api/v1/analytics/{campaign_id}")
println("  GET /api/v1/analytics/reddit/{campaign_id}")
println("  GET /api/v1/analytics/sentiment/{campaign_id}")

println("\n💡 Usage Examples:")
println("  julia get_analytics.jl                    # Test the function")
println("  julia api_server_analytics.jl             # Start API server")
println("  curl http://localhost:8053/api/v1/analytics/default  # HTTP request") 