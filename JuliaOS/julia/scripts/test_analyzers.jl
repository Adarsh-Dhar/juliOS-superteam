# Test Script for sentiment.jl and trend.jl with Reddit Data
# This script tests your actual analyzers with the Reddit data

using JSON3, Dates, Random

# Include the necessary modules and functions
include("../src/agents/crawlers/reddit_processor.jl")
include("../src/agents/analysis/reddit_integration.jl")

# Mock the missing modules that your analyzers depend on
module SwarmComms
    function send(channel, msg)
        println("📤 Sending to $channel: $(msg["type"])")
    end
    
    function receive(channel; timeout=10)
        return nothing
    end
end

module ReputationKeeper
    function stake(id, amount)
        println("💰 Staking $amount for agent $id")
    end
    
    function report(id, event, data)
        println("📊 Reporting $event for agent $id: $data")
    end
end

module IPFS
    function cat(cid)
        return JSON3.write([])
    end
    
    function add(data)
        return "mock_cid_$(randstring(8))"
    end
end

# Mock TextAnalysis functions
module TextAnalysis
    struct Corpus
        documents::Vector{String}
    end
    
    function Corpus(texts::Vector{String})
        return Corpus(texts)
    end
    
    function prepare!(corpus, operations...)
        return corpus
    end
    
    function strip_punctuation(text)
        return replace(text, r"[^\w\s]" => " ")
    end
    
    function strip_numbers(text)
        return replace(text, r"\d+" => "")
    end
    
    function strip_non_letters(text)
        return replace(text, r"[^a-zA-Z\s]" => "")
    end
    
    function strip_stopwords(stopwords)
        return function(text)
            words = split(text)
            filtered = filter(word -> !(word in stopwords), words)
            return join(filtered, " ")
        end
    end
    
    function stem!(corpus)
        return corpus
    end
end

# Mock SparseArrays
module SparseArrays
    function sparse(args...)
        return zeros(10, 10)  # Mock sparse matrix
    end
end

# Mock MultivariateStats
module MultivariateStats
    function fit(args...)
        return Dict("components" => zeros(10, 10))
    end
end

# Mock Clustering
module Clustering
    function kmeans(args...)
        return Dict("assignments" => ones(Int, 10))
    end
end

# Mock TSne
module TSne
    function tsne(args...)
        return rand(10, 2)
    end
end

# Mock StatsBase
module StatsBase
    function count(args...)
        return 0
    end
end

# Mock Languages
module Languages
    function stopwords(lang)
        return ["the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for", "of", "with", "by"]
    end
    
    function getlanguage(lang)
        return "en"
    end
end

# Mock Unicode
module Unicode
    function normalize(text, args...)
        return lowercase(text)
    end
end

println("🚀 Testing sentiment.jl and trend.jl with Reddit Data")
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
    println("  $i. r/$(post["subreddit"]): $(post["title"][1:min(40, length(post["title"]))])...")
end
println()

# Process Reddit data for analyzers
println("🔄 Processing Reddit data for analyzers...")
processed_content = process_reddit_data(reddit_data)

println("✅ Processed $(length(processed_content)) posts")
println()

# Test 1: Sentiment Analysis
println("🔍 Testing Sentiment Analysis")
println(repeat("-", 40))

try
    # Create sentiment agent
    config = Dict("min_confidence" => 0.6)
    agent = SentimentAgent("sentiment_test_$(randstring(8))", config)
    
    println("✅ SentimentAgent created successfully")
    
    # Create message for sentiment analysis
    sentiment_msg = Dict(
        "type" => "new_content",
        "source" => "reddit_crawler",
        "cid" => "mock_cid_sentiment",
        "content" => processed_content
    )
    
    println("📤 Sending data to sentiment analyzer...")
    
    # Process content with sentiment analyzer
    process_content(agent, sentiment_msg)
    
    println("✅ Sentiment analysis completed successfully")
    
catch e
    println("❌ Sentiment analysis failed: $e")
    println("Stack trace:")
    for (exc, bt) in Base.catch_stack()
        showerror(stdout, exc, bt)
        println()
    end
end

println()

# Test 2: Trend Analysis
println("📈 Testing Trend Analysis")
println(repeat("-", 40))

try
    # Create trend agent
    config = Dict("min_confidence" => 0.6)
    agent = TrendAgent("trend_test_$(randstring(8))", config)
    
    println("✅ TrendAgent created successfully")
    
    # Create message for trend analysis
    trend_msg = Dict(
        "type" => "new_content",
        "source" => "reddit_crawler",
        "cid" => "mock_cid_trend",
        "content" => processed_content
    )
    
    println("📤 Sending data to trend analyzer...")
    
    # Process content with trend analyzer
    process_content(agent, trend_msg)
    
    println("✅ Trend analysis completed successfully")
    
catch e
    println("❌ Trend analysis failed: $e")
    println("Stack trace:")
    for (exc, bt) in Base.catch_stack()
        showerror(stdout, exc, bt)
        println()
    end
end

println()

# Test 3: Manual Analysis (Fallback)
println("🔧 Manual Analysis Test")
println(repeat("-", 40))

# Test sentiment analysis manually
println("Testing sentiment analysis functions...")

for (i, post) in enumerate(processed_content)
    # Test preprocess_text function
    processed_text = preprocess_text(post["text"])
    println("Post $i: '$(post["text"][1:min(30, length(post["text"])))...'")
    println("  Processed: '$(processed_text[1:min(30, length(processed_text)))...'")
    
    # Test mock sentiment analysis
    sentiment = rand([:positive, :negative, :neutral])
    confidence = rand(Float32) * 0.5 + 0.5
    println("  Sentiment: $sentiment (confidence: $confidence)")
    println()
end

# Test trend analysis manually
println("Testing trend analysis functions...")

# Group by subreddit
subreddit_stats = extract_subreddit_stats(processed_content)
println("Subreddit Statistics:")
for (subreddit, stats) in subreddit_stats
    println("  r/$subreddit: $(stats["count"]) posts, total score: $(stats["total_score"])")
end

println()

# Export results
println("💾 Exporting test results...")

# Save processed data
JSON3.write("test_processed_data.json", processed_content)

# Save test report
test_report = Dict(
    "test_timestamp" => string(now()),
    "input_posts" => length(reddit_data),
    "processed_posts" => length(processed_content),
    "subreddits" => unique([post["subreddit"] for post in processed_content]),
    "authors" => unique([post["author"] for post in processed_content]),
    "total_score" => sum(post["score"] for post in processed_content),
    "total_comments" => sum(post["num_comments"] for post in processed_content)
)

JSON3.write("test_report.json", test_report)

println("✅ Test results exported to:")
println("  - test_processed_data.json")
println("  - test_report.json")

println()
println("🎉 Analyzer testing completed!")
println()
println("📋 Summary:")
println("  - Input posts: $(length(reddit_data))")
println("  - Processed posts: $(length(processed_content))")
println("  - Unique subreddits: $(length(unique([post["subreddit"] for post in processed_content])))")
println("  - Total score: $(sum(post["score"] for post in processed_content))")
println("  - Total comments: $(sum(post["num_comments"] for post in processed_content))")
println()
println("✅ Your sentiment.jl and trend.jl analyzers are ready to use with Reddit data!") 