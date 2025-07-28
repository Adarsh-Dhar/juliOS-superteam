#!/usr/bin/env julia

# Test script to check if sentiment.jl is working with Reddit data
using JSON3, Dates, Random

println("🔍 Testing Sentiment Analyzer with Reddit Data")
println(repeat("=", 60))

# Your Reddit data from the response
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
    println("  $i. r/$(post["subreddit"]): $(post["title"])")
end
println()

# Step 1: Test sentiment.jl module loading
println("🔧 Step 1: Testing sentiment.jl module loading")
println(repeat("-", 40))

try
    # Mock the required modules that sentiment.jl depends on
    # Create mock modules at top level
    module MockTextAnalysis
        function Corpus(texts)
            return Dict("documents" => texts)
        end
    end
    
    module MockSwarmComms
        function send(channel, msg)
            println("📤 Mock send to $channel: $(msg["type"])")
        end
        
        function receive(channel; timeout=10)
            return nothing
        end
    end
    
    module MockReputationKeeper
        function stake(id, amount)
            println("💰 Mock stake: $id -> $amount")
        end
        
        function report(id, event, data)
            println("📊 Mock report: $id -> $event -> $data")
        end
    end
    
    module MockIPFS
        function cat(cid)
            return JSON3.write([])
        end
        
        function add(data)
            return "mock_cid_$(randstring(8))"
        end
    end
    
    # Include the sentiment analyzer
    include("src/agents/analysis/sentiment.jl")
    println("✅ sentiment.jl module loaded successfully")
    
catch e
    println("❌ sentiment.jl module failed to load: $e")
    println("Stack trace:")
    for (exc, bt) in Base.catch_stack()
        showerror(stdout, exc, bt)
        println()
    end
    exit(1)
end

# Step 2: Test SentimentAgent creation
println("\n🔧 Step 2: Testing SentimentAgent creation")
println(repeat("-", 40))

try
    config = Dict("min_confidence" => 0.6)
    agent = SentimentAgent("test_sentiment_$(randstring(8))", config)
    println("✅ SentimentAgent created successfully")
    println("  Agent ID: $(agent.id)")
    println("  Config: $config")
    println("  Cache size: $(length(agent.sentiment_cache))")
    
catch e
    println("❌ SentimentAgent creation failed: $e")
    exit(1)
end

# Step 3: Test data processing for sentiment analysis
println("\n🔧 Step 3: Testing data processing for sentiment analysis")
println(repeat("-", 40))

# Process Reddit data to match sentiment analyzer expectations
processed_content = []

for post in reddit_data
    processed_post = Dict(
        "id" => post["id"],
        "text" => post["title"],  # Use title as main text for sentiment analysis
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

println("✅ Processed $(length(processed_content)) posts for sentiment analysis")
println()

# Show sample processed post
println("📝 Sample Processed Post:")
println(JSON3.pretty(processed_content[1]))
println()

# Step 4: Test sentiment analysis functions
println("\n🔧 Step 4: Testing sentiment analysis functions")
println(repeat("-", 40))

try
    # Test preprocess_text function
    println("Testing preprocess_text function...")
    test_text = "Hello, world! This is a test @user https://example.com"
    processed_text = preprocess_text(test_text)
    println("  Original: '$test_text'")
    println("  Processed: '$processed_text'")
    println("✅ preprocess_text function working")
    
    # Test mock sentiment analysis
    println("\nTesting mock sentiment analysis...")
    for (i, post) in enumerate(processed_content)
        processed_text = preprocess_text(post["text"])
        sentiment, confidence = mock_sentiment_analysis(processed_text)
        println("  Post $i: '$(post["text"])'")
        println("    Processed: '$(processed_text)'")
        println("    Sentiment: $sentiment (confidence: $confidence)")
        println()
    end
    println("✅ Mock sentiment analysis working")
    
catch e
    println("❌ Sentiment analysis functions failed: $e")
    exit(1)
end

# Step 5: Test batch processing
println("\n🔧 Step 5: Testing batch processing")
println(repeat("-", 40))

try
    # Create a new agent for batch testing
    config = Dict("min_confidence" => 0.6)
    agent = SentimentAgent("batch_test_$(randstring(8))", config)
    
    # Test process_batch function
    batch_results = process_batch(agent, processed_content)
    
    println("✅ Batch processing completed")
    println("  Input posts: $(length(processed_content))")
    println("  Output results: $(length(batch_results))")
    
    # Show results
    println("\n📊 Batch Processing Results:")
    for (i, (post, result)) in enumerate(zip(processed_content, batch_results))
        sentiment, confidence = result
        println("  $i. $(post["text"]) -> $sentiment ($(round(confidence, digits=2)))")
    end
    
catch e
    println("❌ Batch processing failed: $e")
    exit(1)
end

# Step 6: Test full sentiment analysis pipeline
println("\n🔧 Step 6: Testing full sentiment analysis pipeline")
println(repeat("-", 40))

try
    # Create message for sentiment analysis
    msg = Dict(
        "type" => "new_content",
        "source" => "reddit_crawler",
        "cid" => "mock_cid_$(randstring(8))",
        "content" => processed_content
    )
    
    # Create agent
    config = Dict("min_confidence" => 0.6)
    agent = SentimentAgent("pipeline_test_$(randstring(8))", config)
    
    println("📤 Sending data to sentiment analyzer...")
    
    # Process content (this would normally be called by the agent's run loop)
    process_content(agent, msg)
    
    println("✅ Full sentiment analysis pipeline completed successfully")
    
catch e
    println("❌ Full pipeline failed: $e")
    println("Stack trace:")
    for (exc, bt) in Base.catch_stack()
        showerror(stdout, exc, bt)
        println()
    end
    exit(1)
end

# Step 7: Generate comprehensive report
println("\n🔧 Step 7: Generating comprehensive report")
println(repeat("-", 40))

# Analyze sentiment distribution
sentiment_counts = Dict{Symbol, Int}()
sentiment_confidences = Dict{Symbol, Vector{Float32}}()

for post in processed_content
    processed_text = preprocess_text(post["text"])
    sentiment, confidence = mock_sentiment_analysis(processed_text)
    
    sentiment_counts[sentiment] = get(sentiment_counts, sentiment, 0) + 1
    
    if !haskey(sentiment_confidences, sentiment)
        sentiment_confidences[sentiment] = Float32[]
    end
    push!(sentiment_confidences[sentiment], confidence)
end

println("📊 Sentiment Analysis Report:")
println("  Total posts analyzed: $(length(processed_content))")
println("  Subreddits covered: $(length(unique([post["subreddit"] for post in processed_content])))")

println("\n  Sentiment Distribution:")
for (sentiment, count) in sort(collect(sentiment_counts), by=x->x[2], rev=true)
    percentage = round(count / length(processed_content) * 100, digits=1)
    avg_confidence = round(mean(sentiment_confidences[sentiment]), digits=2)
    println("    $sentiment: $count posts ($percentage%) - avg confidence: $avg_confidence")
end

println("\n  Subreddit Analysis:")
subreddit_stats = Dict{String, Dict}()
for post in processed_content
    subreddit = post["subreddit"]
    if !haskey(subreddit_stats, subreddit)
        subreddit_stats[subreddit] = Dict("count" => 0, "total_score" => 0, "sentiments" => Symbol[])
    end
    
    subreddit_stats[subreddit]["count"] += 1
    subreddit_stats[subreddit]["total_score"] += post["score"]
    
    processed_text = preprocess_text(post["text"])
    sentiment, _ = mock_sentiment_analysis(processed_text)
    push!(subreddit_stats[subreddit]["sentiments"], sentiment)
end

for (subreddit, stats) in sort(collect(subreddit_stats), by=x->x[2]["count"], rev=true)
    avg_score = round(stats["total_score"] / stats["count"], digits=1)
    dominant_sentiment = mode(stats["sentiments"])
    println("    r/$subreddit: $(stats["count"]) posts, avg score: $avg_score, dominant sentiment: $dominant_sentiment")
end

# Helper function for mode
function mode(values)
    counts = Dict{Symbol, Int}()
    for v in values
        counts[v] = get(counts, v, 0) + 1
    end
    return argmax(counts)
end

# Step 8: Export results
println("\n🔧 Step 8: Exporting results")
println(repeat("-", 40))

# Create comprehensive results
results = Dict(
    "test_timestamp" => string(now()),
    "input_posts" => length(reddit_data),
    "processed_posts" => length(processed_content),
    "sentiment_distribution" => sentiment_counts,
    "subreddit_analysis" => subreddit_stats,
    "processed_content" => processed_content
)

# Save results
JSON3.write("sentiment_test_results.json", results)
println("✅ Results saved to 'sentiment_test_results.json'")

# Final summary
println("\n🎉 Sentiment Analyzer Test Summary")
println(repeat("=", 60))
println("✅ sentiment.jl module loaded successfully")
println("✅ SentimentAgent creation working")
println("✅ Data processing for sentiment analysis working")
println("✅ Text preprocessing functions working")
println("✅ Mock sentiment analysis working")
println("✅ Batch processing working")
println("✅ Full pipeline integration working")
println("✅ Results exported successfully")

println("\n📋 Key Findings:")
println("  - Processed $(length(processed_content)) Reddit posts")
println("  - Covered $(length(unique([post["subreddit"] for post in processed_content]))) subreddits")
println("  - Sentiment analysis pipeline fully functional")
println("  - Ready for integration with real Reddit crawler data")

println("\n🚀 The sentiment analyzer is working correctly with your Reddit data!") 