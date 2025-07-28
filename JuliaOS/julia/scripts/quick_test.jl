# Quick Test Script for Reddit Data Processing
# Run this to test the Reddit data processing pipeline

using JSON3, Dates, Random

println("🚀 Quick Test - Reddit Data Processing")
println("=" * 50)

# Your Reddit data (from curl command)
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

println("📊 Input Data:")
println("  Total posts: $(length(reddit_data))")
for (i, post) in enumerate(reddit_data)
    println("  $i. r/$(post["subreddit"]): $(post["title"][1:min(40, length(post["title"]))])...")
end
println()

# Process the data for analyzers
println("🔄 Processing data for analyzers...")
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

# Mock sentiment analysis
println("🔍 Mock Sentiment Analysis:")
println("-" * 30)
for (i, post) in enumerate(processed_content)
    sentiment = rand(["positive", "negative", "neutral"])
    confidence = round(rand() * 0.5 + 0.5, digits=2)
    
    println("Post $i: $(post["text"][1:min(40, length(post["text"]))])...")
    println("  Sentiment: $sentiment (confidence: $confidence)")
    println("  Subreddit: $(post["subreddit"])")
    println("  Score: $(post["score"])")
    println()
end

# Mock trend analysis
println("📈 Mock Trend Analysis:")
println("-" * 30)

# Group by subreddit
subreddit_counts = Dict{String, Int}()
subreddit_scores = Dict{String, Int}()

for post in processed_content
    subreddit = post["subreddit"]
    subreddit_counts[subreddit] = get(subreddit_counts, subreddit, 0) + 1
    subreddit_scores[subreddit] = get(subreddit_scores, subreddit, 0) + post["score"]
end

println("Subreddit Activity:")
for (subreddit, count) in sort(collect(subreddit_counts), by=x->x[2], rev=true)
    avg_score = round(subreddit_scores[subreddit] / count, digits=1)
    println("  r/$subreddit: $count posts (avg score: $avg_score)")
end

println("\nEmerging Trends:")
trends = ["gaming", "relationships", "technical_support", "health", "entertainment"]
for trend in trends
    velocity = round(rand() * 2 + 0.5, digits=2)
    acceleration = round(rand() * 0.5 - 0.25, digits=2)
    println("  $trend: velocity $velocity, acceleration $acceleration")
end

println()

# Export data
println("💾 Exporting data...")
JSON3.write("quick_test_processed.json", processed_content)
println("✅ Data exported to 'quick_test_processed.json'")

# Generate summary
println("\n📊 Summary:")
println("  Total posts processed: $(length(processed_content))")
println("  Unique subreddits: $(length(Set(post["subreddit"] for post in processed_content)))")
println("  Unique authors: $(length(Set(post["author"] for post in processed_content)))")
println("  Total score: $(sum(post["score"] for post in processed_content))")
println("  Total comments: $(sum(post["num_comments"] for post in processed_content))")

println("\n🎉 Quick test completed successfully!")
println("You can now use this processed data with your sentiment.jl and trend.jl analyzers.") 