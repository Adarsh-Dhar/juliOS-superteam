# Final Test for sentiment.jl and trend.jl with Reddit Data
# This script tests your analyzers with the Reddit data

using JSON3, Dates, Random

println("🚀 Final Test - sentiment.jl and trend.jl with Reddit Data")
println(repeat("=", 60))

# Your Reddit data
reddit_data = [
    Dict(
        "id" => "1mbsu4d",
        "title" => "Dating a married woman",
        "subreddit" => "nonmonogamy",
        "score" => 1,
        "num_comments" => 1,
        "url" => "/r/nonmonogamy/comments/1mbsu4d/dating_a_married_woman/",
        "author" => "Altruistic-Smile-471",
        "created_utc" => 1753737799
    ),
    Dict(
        "id" => "1mbsu4c",
        "title" => "how do i help?",
        "subreddit" => "EatingDisorders",
        "score" => 1,
        "num_comments" => 0,
        "url" => "/r/EatingDisorders/comments/1mbsu4c/how_do_i_help/",
        "author" => "Waste-Bug-3197",
        "created_utc" => 1753737799
    ),
    Dict(
        "id" => "1mbsu4b",
        "title" => "Where do these hoses connect to?",
        "subreddit" => "Miata",
        "score" => 1,
        "num_comments" => 0,
        "url" => "/r/Miata/comments/1mbsu4b/where_do_these_hoses_connect_to/",
        "author" => "easykill2517",
        "created_utc" => 1753737799
    ),
    Dict(
        "id" => "1mbsu4a",
        "title" => "Would you rather…",
        "subreddit" => "ChuckleSandwich",
        "score" => 1,
        "num_comments" => 0,
        "url" => "/r/ChuckleSandwich/comments/1mbsu4a/would_you_rather/",
        "author" => "supersmallpee",
        "created_utc" => 1753737799
    ),
    Dict(
        "id" => "1mbsu49",
        "title" => "Warning: Crimson glitch can also permanently reduce your hand size",
        "subreddit" => "balatro",
        "score" => 1,
        "num_comments" => 0,
        "url" => "/r/balatro/comments/1mbsu49/warning_crimson_glitch_can_also_permanently/",
        "author" => "misterrandom1",
        "created_utc" => 1753737799
    )
]

println("📊 Input Reddit Data:")
println("  Total posts: $(length(reddit_data))")
for (i, post) in enumerate(reddit_data)
    title = post["title"]
    if length(title) > 40
        title = String(title[1:40]) * "..."
    end
    println("  $i. r/$(post["subreddit"]): $title")
end
println()

# Process Reddit data for analyzers
println("🔄 Processing Reddit data for analyzers...")
processed_content = []

for post in reddit_data
    processed_post = Dict(
        "id" => post["id"],
        "text" => post["title"],
        "source" => "reddit",
        "subreddit" => post["subreddit"],
        "author" => post["author"],
        "score" => post["score"],
        "num_comments" => post["num_comments"],
        "created_at" => unix2datetime(post["created_utc"]),
        "url" => "https://reddit.com$(post["url"])",
        "metadata" => Dict(
            "subreddit" => post["subreddit"],
            "score" => post["score"],
            "comments" => post["num_comments"],
            "author" => post["author"]
        )
    )
    push!(processed_content, processed_post)
end

println("✅ Processed $(length(processed_content)) posts")
println()

# Show sample processed post
println("📝 Sample Processed Post:")
println(JSON3.pretty(processed_content[1]))
println()

# Test 1: Mock Sentiment Analysis (simulating sentiment.jl)
println("🔍 Mock Sentiment Analysis (simulating sentiment.jl)")
println(repeat("-", 50))

# Mock the functions that would be in sentiment.jl
function mock_preprocess_text(text::String)
    # Basic normalization
    text = lowercase(text)
    # Remove URLs, mentions, and special characters
    text = replace(text, r"http\S+" => "")
    text = replace(text, r"@\w+" => "@user")
    text = replace(text, r"[^\w\s]" => " ")
    # Trim whitespace
    return strip(text)
end

function mock_sentiment_analysis(text::String)
    # Mock sentiment analysis
    sentiment = rand([:positive, :negative, :neutral])
    confidence = rand(Float32) * 0.5 + 0.5  # Random confidence between 0.5 and 1.0
    return (sentiment, confidence)
end

# Process each post with mock sentiment analysis
for (i, post) in enumerate(processed_content)
    # Preprocess text
    processed_text = mock_preprocess_text(post["text"])
    
    # Analyze sentiment
    sentiment, confidence = mock_sentiment_analysis(processed_text)
    
    # Get truncated text for display
    display_text = post["text"]
    if length(display_text) > 40
        display_text = String(display_text[1:40]) * "..."
    end
    
    processed_display = processed_text
    if length(processed_display) > 30
        processed_display = String(processed_display[1:30]) * "..."
    end
    
    println("Post $i: '$display_text'")
    println("  Processed: '$processed_display'")
    println("  Sentiment: $sentiment (confidence: $confidence)")
    println("  Subreddit: $(post["subreddit"])")
    println("  Score: $(post["score"])")
    println("  Comments: $(post["num_comments"])")
    println()
end

# Test 2: Mock Trend Analysis (simulating trend.jl)
println("📈 Mock Trend Analysis (simulating trend.jl)")
println(repeat("-", 50))

# Mock the functions that would be in trend.jl
function mock_extract_subreddit_stats(content::Vector{Dict})
    stats = Dict{String, Dict}()
    
    for post in content
        subreddit = post["subreddit"]
        
        if !haskey(stats, subreddit)
            stats[subreddit] = Dict(
                "count" => 0,
                "total_score" => 0,
                "total_comments" => 0,
                "authors" => Set{String}(),
                "posts" => []
            )
        end
        
        stats[subreddit]["count"] += 1
        stats[subreddit]["total_score"] += post["score"]
        stats[subreddit]["total_comments"] += post["num_comments"]
        push!(stats[subreddit]["authors"], post["author"])
        push!(stats[subreddit]["posts"], post["id"])
    end
    
    # Convert authors Set to Array for JSON serialization
    for subreddit in keys(stats)
        stats[subreddit]["authors"] = collect(stats[subreddit]["authors"])
    end
    
    return stats
end

function mock_detect_trends(content::Vector{Dict})
    # Mock trend detection
    trends = []
    
    # Group by subreddit
    subreddit_counts = Dict{String, Int}()
    for post in content
        subreddit = post["subreddit"]
        subreddit_counts[subreddit] = get(subreddit_counts, subreddit, 0) + 1
    end
    
    # Mock emerging trends
    for (subreddit, count) in subreddit_counts
        if count > 0
            velocity = rand() * 2 + 0.5
            acceleration = rand() * 0.5 - 0.25
            confidence = rand() * 0.5 + 0.5
            
            push!(trends, Dict(
                "topic" => subreddit,
                "velocity" => round(velocity, digits=2),
                "acceleration" => round(acceleration, digits=2),
                "confidence" => round(confidence, digits=2),
                "volume" => count
            ))
        end
    end
    
    return trends
end

# Process content with mock trend analysis
subreddit_stats = mock_extract_subreddit_stats(processed_content)
trends = mock_detect_trends(processed_content)

println("Subreddit Activity:")
for (subreddit, data) in sort(collect(subreddit_stats), by=x->x[2]["count"], rev=true)
    avg_score = round(data["total_score"] / data["count"], digits=1)
    avg_comments = round(data["total_comments"] / data["count"], digits=1)
    println("  r/$subreddit: $(data["count"]) posts, avg score: $avg_score, avg comments: $avg_comments")
end

println("\nEmerging Trends:")
for trend in sort(trends, by=x->x["velocity"], rev=true)
    println("  $(trend["topic"]): velocity $(trend["velocity"]), acceleration $(trend["acceleration"]), confidence $(trend["confidence"])")
end

println()

# Test 3: Integration Test
println("🔗 Integration Test")
println(repeat("-", 50))

# Simulate how your analyzers would work together
println("Simulating integrated analysis pipeline...")

# Step 1: Sentiment analysis results
sentiment_results = []
for post in processed_content
    processed_text = mock_preprocess_text(post["text"])
    sentiment, confidence = mock_sentiment_analysis(processed_text)
    
    result = Dict(
        "post_id" => post["id"],
        "text" => post["text"],
        "processed_text" => processed_text,
        "sentiment" => sentiment,
        "confidence" => confidence,
        "subreddit" => post["subreddit"],
        "score" => post["score"],
        "num_comments" => post["num_comments"]
    )
    push!(sentiment_results, result)
end

# Step 2: Trend analysis results
trend_results = mock_detect_trends(processed_content)

# Step 3: Combined analysis
println("Combined Analysis Results:")
println("  Sentiment Analysis: $(length(sentiment_results)) posts analyzed")
println("  Trend Analysis: $(length(trend_results)) trends detected")

# Count sentiment distribution
positive_count = count(r -> r["sentiment"] == :positive, sentiment_results)
negative_count = count(r -> r["sentiment"] == :negative, sentiment_results)
neutral_count = count(r -> r["sentiment"] == :neutral, sentiment_results)

println("  Sentiment Distribution:")
println("    Positive: $positive_count")
println("    Negative: $negative_count")
println("    Neutral: $neutral_count")

println("  Top Trends:")
for (i, trend) in enumerate(sort(trend_results, by=x->x["velocity"], rev=true)[1:3])
    println("    $i. $(trend["topic"]): velocity $(trend["velocity"])")
end

println()

# Export results
println("💾 Exporting test results...")

# Save processed data
JSON3.write("final_test_processed.json", processed_content)

# Save sentiment results
JSON3.write("final_test_sentiment.json", sentiment_results)

# Save trend results
JSON3.write("final_test_trends.json", trend_results)

# Save comprehensive report
report = Dict(
    "test_timestamp" => string(now()),
    "input_posts" => length(reddit_data),
    "processed_posts" => length(processed_content),
    "sentiment_results" => sentiment_results,
    "trend_results" => trend_results,
    "subreddit_stats" => subreddit_stats,
    "summary" => Dict(
        "total_posts" => length(processed_content),
        "unique_subreddits" => length(unique([post["subreddit"] for post in processed_content])),
        "unique_authors" => length(unique([post["author"] for post in processed_content])),
        "total_score" => sum(post["score"] for post in processed_content),
        "total_comments" => sum(post["num_comments"] for post in processed_content),
        "sentiment_distribution" => Dict(
            "positive" => positive_count,
            "negative" => negative_count,
            "neutral" => neutral_count
        )
    )
)

JSON3.write("final_test_report.json", report)

println("✅ Test results exported to:")
println("  - final_test_processed.json")
println("  - final_test_sentiment.json")
println("  - final_test_trends.json")
println("  - final_test_report.json")

println()
println("🎉 Final test completed successfully!")
println()
println("📋 Summary:")
println("  - Input posts: $(length(reddit_data))")
println("  - Processed posts: $(length(processed_content))")
println("  - Unique subreddits: $(length(unique([post["subreddit"] for post in processed_content])))")
println("  - Total score: $(sum(post["score"] for post in processed_content))")
println("  - Total comments: $(sum(post["num_comments"] for post in processed_content))")
println("  - Sentiment results: $(length(sentiment_results))")
println("  - Trend results: $(length(trend_results))")
println()
println("✅ Your Reddit data is ready for sentiment.jl and trend.jl analyzers!")
println()
println("📝 Next Steps:")
println("  1. Replace mock functions with your actual sentiment.jl and trend.jl code")
println("  2. Use the processed data format shown above")
println("  3. Integrate with your existing analyzer agents")
println("  4. Run the full pipeline with real Reddit data") 