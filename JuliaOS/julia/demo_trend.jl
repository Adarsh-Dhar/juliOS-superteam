#!/usr/bin/env julia

# Demo: Trend Analysis with Reddit Data
using JSON3, Dates, Random, Statistics

println("🎯 Demo: Trend Analysis with Reddit Data")
println(repeat("=", 60))

# Helper function to count occurrences
function countmap(items)
    counts = Dict{Any, Int}()
    for item in items
        counts[item] = get(counts, item, 0) + 1
    end
    return counts
end

# Sample Reddit data with timestamps
function get_reddit_data_with_timestamps()
    base_time = now()
    reddit_data = [
        Dict(
            "id" => "1mbsu4d",
            "title" => "Dating a married woman",
            "subreddit" => "nonmonogamy",
            "score" => 15,
            "num_comments" => 8,
            "text" => "I've been dating a married woman for the past few months. She says she's in an open marriage but I'm starting to have doubts. What should I do?",
            "created_at" => base_time - Minute(30),
            "source" => "reddit"
        ),
        Dict(
            "id" => "1mbsu4c",
            "title" => "how do i help?",
            "subreddit" => "EatingDisorders",
            "score" => 23,
            "num_comments" => 12,
            "text" => "My friend is struggling with an eating disorder. I want to help but I don't know how. Any advice?",
            "created_at" => base_time - Minute(25),
            "source" => "reddit"
        ),
        Dict(
            "id" => "1mbsu4b",
            "title" => "Where do these hoses connect to?",
            "subreddit" => "Miata",
            "score" => 45,
            "num_comments" => 18,
            "text" => "I'm working on my Miata and found these loose hoses. Can anyone help me identify where they should connect?",
            "created_at" => base_time - Minute(20),
            "source" => "reddit"
        ),
        Dict(
            "id" => "1mbsu4a",
            "title" => "Would you rather…",
            "subreddit" => "ChuckleSandwich",
            "score" => 67,
            "num_comments" => 34,
            "text" => "Would you rather fight 100 duck-sized horses or 1 horse-sized duck?",
            "created_at" => base_time - Minute(15),
            "source" => "reddit"
        ),
        Dict(
            "id" => "1mbsu49",
            "title" => "Warning: Crimson glitch can also permanently reduce your hand size",
            "subreddit" => "balatro",
            "score" => 89,
            "num_comments" => 56,
            "text" => "Just discovered a bug in Balatro where the Crimson card can permanently reduce your hand size. Be careful!",
            "created_at" => base_time - Minute(10),
            "source" => "reddit"
        ),
        Dict(
            "id" => "1mbsu48",
            "title" => "Help with relationship advice",
            "subreddit" => "relationship_advice",
            "score" => 34,
            "num_comments" => 22,
            "text" => "I need help understanding my partner's behavior. Any advice would be appreciated.",
            "created_at" => base_time - Minute(5),
            "source" => "reddit"
        ),
        Dict(
            "id" => "1mbsu47",
            "title" => "Technical support needed",
            "subreddit" => "techsupport",
            "score" => 78,
            "num_comments" => 45,
            "text" => "Having issues with my computer. Can anyone help me troubleshoot this problem?",
            "created_at" => base_time - Minute(2),
            "source" => "reddit"
        )
    ]
    
    return reddit_data
end

# Simple text preprocessing
function preprocess_text(text::String)
    text = lowercase(text)
    text = replace(text, r"[^\w\s]" => " ")
    text = replace(text, r"\s+" => " ")
    return strip(text)
end

# Create document-term matrix (simplified)
function create_dtm(texts::Vector{String})
    word_counts = Dict{String, Dict{Int, Int}}()
    
    for (doc_id, text) in enumerate(texts)
        processed_text = preprocess_text(text)
        words = split(processed_text)
        
        for word in words
            if length(word) > 2
                if !haskey(word_counts, word)
                    word_counts[word] = Dict{Int, Int}()
                end
                word_counts[word][doc_id] = get(word_counts[word], doc_id, 0) + 1
            end
        end
    end
    
    return word_counts
end

# Extract topics (simplified)
function extract_topics(word_counts::Dict{String, Dict{Int, Int}}, n_topics::Int=5)
    word_frequencies = Dict{String, Int}()
    for (word, doc_counts) in word_counts
        word_frequencies[word] = sum(values(doc_counts))
    end
    
    topics = Dict{Int, Vector{Int}}()
    for i in 1:n_topics
        topics[i] = []
    end
    
    for (doc_id, _) in enumerate(1:length(word_counts))
        topic_id = (doc_id % n_topics) + 1
        push!(topics[topic_id], doc_id)
    end
    
    return topics
end

# Analyze temporal patterns
function analyze_temporal(topics::Dict{Int, Vector{Int}}, timestamps::Vector{DateTime})
    time_buckets = create_time_buckets(timestamps, Minute(15))
    
    topic_series = Dict{Int, Vector{Int}}()
    for (topic_id, doc_ids) in topics
        counts = zeros(Int, length(time_buckets))
        for doc_id in doc_ids
            if doc_id <= length(timestamps)
                bucket = find_bucket(timestamps[doc_id], time_buckets)
                counts[bucket] += 1
            end
        end
        topic_series[topic_id] = counts
    end
    
    return topic_series
end

# Create time buckets
function create_time_buckets(timestamps::Vector{DateTime}, interval::Period)
    if isempty(timestamps)
        return DateTime[]
    end
    
    start_time = minimum(timestamps)
    end_time = maximum(timestamps)
    
    buckets = DateTime[]
    current = start_time
    while current <= end_time
        push!(buckets, current)
        current += interval
    end
    
    return buckets
end

# Find bucket for timestamp
function find_bucket(timestamp::DateTime, buckets::Vector{DateTime})
    if isempty(buckets)
        return 1
    end
    
    for (i, bucket) in enumerate(buckets)
        if timestamp < bucket
            return max(1, i - 1)
        end
    end
    
    return length(buckets)
end

# Find emerging trends
function find_emerging_trends(topic_series::Dict{Int, Vector{Int}})
    trends = []
    
    for (topic_id, counts) in topic_series
        if length(counts) > 2
            if counts[end-1] > 0
                growth_rate = (counts[end] - counts[end-1]) / counts[end-1]
                
                if growth_rate > 0.5
                    acceleration = 0.0
                    if length(counts) > 2 && counts[end-2] > 0
                        prev_growth = (counts[end-1] - counts[end-2]) / counts[end-2]
                        acceleration = growth_rate - prev_growth
                    end
                    
                    push!(trends, Dict(
                        "topic_id" => topic_id,
                        "current_volume" => counts[end],
                        "growth_rate" => growth_rate,
                        "acceleration" => acceleration,
                        "peak_time" => now(),
                        "trend_strength" => growth_rate > 1.0 ? "high" : "medium"
                    ))
                end
            end
        end
    end
    
    sort!(trends, by=x->x["growth_rate"], rev=true)
    return trends
end

# Main trend analysis function
function analyze_trends(posts::Vector{Dict{String, Any}})
    println("📊 Step 1: Loading Reddit data...")
    println("✅ Loaded $(length(posts)) Reddit posts")
    
    texts = [post["title"] * " " * get(post, "text", "") for post in posts]
    timestamps = [post["created_at"] for post in posts]
    sources = [post["source"] for post in posts]
    
    println("\n📊 Step 2: Creating document-term matrix...")
    word_counts = create_dtm(texts)
    println("✅ Created DTM with $(length(word_counts)) unique words")
    
    println("\n📊 Step 3: Extracting topics...")
    topics = extract_topics(word_counts, 5)
    println("✅ Extracted $(length(topics)) topics")
    
    println("\n📊 Step 4: Analyzing temporal patterns...")
    topic_series = analyze_temporal(topics, timestamps)
    println("✅ Created temporal analysis with $(length(topic_series)) topic series")
    
    println("\n📊 Step 5: Detecting emerging trends...")
    trends = find_emerging_trends(topic_series)
    println("✅ Detected $(length(trends)) emerging trends")
    
    trend_report = Dict(
        "period_start" => minimum(timestamps),
        "period_end" => maximum(timestamps),
        "total_documents" => length(posts),
        "topics" => topics,
        "trends" => trends,
        "topic_series" => topic_series,
        "word_frequencies" => Dict(
            word => sum(values(doc_counts)) 
            for (word, doc_counts) in word_counts
        )
    )
    
    return trend_report
end

# Main demo function
function demo_trend_analysis()
    println("🎯 Demo: Trend Analysis with Reddit Data")
    println(repeat("=", 60))
    
    posts = get_reddit_data_with_timestamps()
    trend_report = analyze_trends(posts)
    
    println("\n📈 Trend Analysis Results:")
    println("  Period: $(trend_report["period_start"]) to $(trend_report["period_end"])")
    println("  Total documents: $(trend_report["total_documents"])")
    println("  Topics extracted: $(length(trend_report["topics"]))")
    println("  Emerging trends: $(length(trend_report["trends"]))")
    
    println("\n📊 Topic Distribution:")
    for (topic_id, doc_ids) in trend_report["topics"]
        println("  Topic $topic_id: $(length(doc_ids)) documents")
    end
    
    println("\n📈 Emerging Trends:")
    for (i, trend) in enumerate(trend_report["trends"])
        println("  $(i). Topic $(trend["topic_id"])")
        println("     Growth rate: $(round(trend["growth_rate"] * 100, digits=1))%")
        println("     Current volume: $(trend["current_volume"])")
        println("     Acceleration: $(round(trend["acceleration"], digits=3))")
        println("     Strength: $(trend["trend_strength"])")
        println()
    end
    
    println("\n📊 Word Frequencies (Top 10):")
    word_freqs = sort(collect(trend_report["word_frequencies"]), by=x->x[2], rev=true)
    for (i, (word, freq)) in enumerate(word_freqs[1:10])
        println("  $(i). $word: $freq")
    end
    
    return trend_report
end

# Run the demo
if abspath(PROGRAM_FILE) == @__FILE__
    result = demo_trend_analysis()
    println("🎉 Trend analysis demo completed successfully!")
    println("📊 Trend analysis with Reddit data is working!")
end
