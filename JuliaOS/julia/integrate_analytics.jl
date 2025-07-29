#!/usr/bin/env julia

# Comprehensive analytics integration script
# Integrates data from reddit.jl, sentiment.jl, trend.jl, consensusVerifier.jl
using JSON3, Dates, Random, Statistics

# Helper function to count occurrences
function countmap(items)
    counts = Dict{Any, Int}()
    for item in items
        counts[item] = get(counts, item, 0) + 1
    end
    return counts
end

println("🔗 Integrating Analytics from All Julia Agents")
println(repeat("=", 60))

# Configuration
const CAMPAIGN_ID = "reddit_campaign_$(randstring(6))"
const JULIA_API_BASE = get(ENV, "JULIA_API_BASE", "http://localhost:8053/api/v1")

# Sample Reddit data (in production, this would come from reddit.jl)
reddit_data = [
    Dict(
        "id" => "1mbsu4d",
        "title" => "Dating a married woman",
        "subreddit" => "nonmonogamy",
        "score" => 15,
        "num_comments" => 8,
        "url" => "/r/nonmonogamy/comments/1mbsu4d/dating_a_married_woman/",
        "author" => "Altruistic-Smile-471",
        "created_utc" => 1753737799
    ),
    Dict(
        "id" => "1mbsu4c",
        "title" => "how do i help?",
        "subreddit" => "EatingDisorders",
        "score" => 23,
        "num_comments" => 12,
        "url" => "/r/EatingDisorders/comments/1mbsu4c/how_do_i_help/",
        "author" => "Waste-Bug-3197",
        "created_utc" => 1753737799
    ),
    Dict(
        "id" => "1mbsu4b",
        "title" => "Where do these hoses connect to?",
        "subreddit" => "Miata",
        "score" => 45,
        "num_comments" => 18,
        "url" => "/r/Miata/comments/1mbsu4b/where_do_these_hoses_connect_to/",
        "author" => "easykill2517",
        "created_utc" => 1753737799
    ),
    Dict(
        "id" => "1mbsu4a",
        "title" => "Would you rather…",
        "subreddit" => "ChuckleSandwich",
        "score" => 67,
        "num_comments" => 34,
        "url" => "/r/ChuckleSandwich/comments/1mbsu4a/would_you_rather/",
        "author" => "supersmallpee",
        "created_utc" => 1753737799
    ),
    Dict(
        "id" => "1mbsu49",
        "title" => "Warning: Crimson glitch can also permanently reduce your hand size",
        "subreddit" => "balatro",
        "score" => 89,
        "num_comments" => 56,
        "url" => "/r/balatro/comments/1mbsu49/warning_crimson_glitch_can_also_permanently/",
        "author" => "misterrandom1",
        "created_utc" => 1753737799
    )
]

println("📊 Processing $(length(reddit_data)) Reddit posts")
println()

# Step 1: Process Reddit Data (from reddit.jl)
println("🔧 Step 1: Processing Reddit Data")
println(repeat("-", 40))

function process_reddit_data(posts)
    reddit_analytics = Dict(
        "total_posts" => length(posts),
        "platforms" => ["reddit"],
        "subreddits" => unique([post["subreddit"] for post in posts]),
        "total_engagement" => sum([post["score"] + post["num_comments"] for post in posts]),
        "average_engagement" => mean([post["score"] + post["num_comments"] for post in posts]),
        "posts" => posts,
        "stats" => Dict(
            "total_score" => sum([post["score"] for post in posts]),
            "total_comments" => sum([post["num_comments"] for post in posts]),
            "unique_authors" => length(unique([post["author"] for post in posts])),
            "subreddit_distribution" => countmap([post["subreddit"] for post in posts])
        )
    )
    return reddit_analytics
end

reddit_analytics = process_reddit_data(reddit_data)
println("✅ Reddit data processed")
println("  Total posts: $(reddit_analytics["total_posts"])")
println("  Total engagement: $(reddit_analytics["total_engagement"])")
println("  Subreddits: $(join(reddit_analytics["subreddits"], ", "))")

# Step 2: Sentiment Analysis (from sentiment.jl)
println("\n🔧 Step 2: Processing Sentiment Analysis")
println(repeat("-", 40))

function process_sentiment_data(posts)
    # Mock sentiment analysis (in production, use real sentiment.jl)
    sentiment_results = []
    sentiment_distribution = Dict(:positive => 0, :negative => 0, :neutral => 0)
    
    for post in posts
        # Mock sentiment analysis
        sentiment = rand([:positive, :negative, :neutral])
        confidence = rand() * 0.5 + 0.5
        
        sentiment_distribution[sentiment] += 1
        
        result = Dict(
            "post_id" => post["id"],
            "text" => post["title"],
            "sentiment" => sentiment,
            "confidence" => confidence,
            "subreddit" => post["subreddit"]
        )
        push!(sentiment_results, result)
    end
    
    return Dict(
        "results" => sentiment_results,
        "distribution" => sentiment_distribution,
        "total_analyzed" => length(posts),
        "average_confidence" => mean([r["confidence"] for r in sentiment_results])
    )
end

sentiment_analytics = process_sentiment_data(reddit_data)
println("✅ Sentiment analysis processed")
println("  Analyzed posts: $(sentiment_analytics["total_analyzed"])")
println("  Distribution: $(sentiment_analytics["distribution"])")
println("  Avg confidence: $(round(sentiment_analytics["average_confidence"], digits=2))")

# Step 3: Trend Analysis (from trend.jl)
println("\n🔧 Step 3: Processing Trend Analysis")
println(repeat("-", 40))

function process_trend_data(posts)
    # Mock trend analysis (in production, use real trend.jl)
    texts = [post["title"] for post in posts]
    
    # Extract trending topics
    word_counts = Dict{String, Int}()
    for text in texts
        words = split(lowercase(text))
        for word in words
            if length(word) > 3
                word_counts[word] = get(word_counts, word, 0) + 1
            end
        end
    end
    
    # Find trending topics
    trending_topics = []
    for (word, count) in sort(collect(word_counts), by=x->x[2], rev=true)
        if count > 1
            push!(trending_topics, Dict(
                "topic" => word,
                "frequency" => count,
                "growth_rate" => rand() * 2.0 + 0.5,
                "confidence" => rand() * 0.3 + 0.7
            ))
        end
    end
    
    return Dict(
        "trending_topics" => trending_topics,
        "total_topics" => length(trending_topics),
        "top_trends" => trending_topics[1:min(5, length(trending_topics))],
        "analysis_period" => Dict(
            "start" => string(minimum([unix2datetime(post["created_utc"]) for post in posts])),
            "end" => string(maximum([unix2datetime(post["created_utc"]) for post in posts]))
        )
    )
end

trend_analytics = process_trend_data(reddit_data)
println("✅ Trend analysis processed")
println("  Trending topics: $(trend_analytics["total_topics"])")
println("  Top trends: $(length(trend_analytics["top_trends"]))")

# Step 4: Consensus Verification (from consensusVerifier.jl)
println("\n🔧 Step 4: Processing Consensus Verification")
println(repeat("-", 40))

function process_consensus_data(posts)
    # Mock consensus verification (in production, use real consensusVerifier.jl)
    consensus_results = []
    agent_performance = []
    
    # Create mock agents
    num_agents = 5
    for i in 1:num_agents
        push!(agent_performance, Dict(
            "id" => "agent_$i",
            "reputation" => rand(60.0:1.0:90.0),
            "stake" => rand(0.05:0.01:0.2),
            "total_verifications" => length(posts),
            "success_rate" => rand() * 0.8 + 0.2
        ))
    end
    
    # Process each post
    for post in posts
        # Mock consensus verification
        bot_votes = sum([rand(Bool) for _ in 1:num_agents])
        manip_votes = sum([rand(Bool) for _ in 1:num_agents])
        auth_votes = sum([rand(Bool) for _ in 1:num_agents])
        
        consensus = Dict(
            "post_id" => post["id"],
            "title" => post["title"],
            "bot_detected" => bot_votes > num_agents/2,
            "manipulation_detected" => manip_votes > num_agents/2,
            "authentic" => auth_votes > num_agents/2,
            "confidence" => rand() * 0.5 + 0.5,
            "total_votes" => num_agents
        )
        push!(consensus_results, consensus)
    end
    
    return Dict(
        "results" => consensus_results,
        "agent_performance" => agent_performance,
        "total_agents" => num_agents,
        "consensus_score" => mean([r["confidence"] for r in consensus_results]),
        "authentic_posts" => sum([r["authentic"] for r in consensus_results]),
        "fake_posts" => sum([!r["authentic"] for r in consensus_results])
    )
end

consensus_analytics = process_consensus_data(reddit_data)
println("✅ Consensus verification processed")
println("  Total agents: $(consensus_analytics["total_agents"])")
println("  Authentic posts: $(consensus_analytics["authentic_posts"])")
println("  Fake posts: $(consensus_analytics["fake_posts"])")
println("  Consensus score: $(round(consensus_analytics["consensus_score"], digits=2))")

# Step 5: Integrate All Analytics
println("\n🔧 Step 5: Integrating All Analytics")
println(repeat("-", 40))

function create_unified_analytics(campaign_id, reddit_data, sentiment_data, trend_data, consensus_data)
    # Create comprehensive analytics object
    analytics = Dict(
        "campaign" => Dict(
            "id" => campaign_id,
            "name" => "Reddit Campaign Analysis",
            "platform" => "reddit",
            "start_date" => string(now()),
            "status" => "active"
        ),
        
        # Crawler Analytics (from reddit.jl)
        "crawler" => Dict(
            "total_posts" => reddit_data["total_posts"],
            "platforms" => reddit_data["platforms"],
            "subreddits" => reddit_data["subreddits"],
            "total_engagement" => reddit_data["total_engagement"],
            "average_engagement" => reddit_data["average_engagement"],
            "stats" => reddit_data["stats"],
            "recent_posts" => reddit_data["posts"][1:min(5, length(reddit_data["posts"]))]
        ),
        
        # Analysis Analytics (from sentiment.jl and trend.jl)
        "analysis" => Dict(
            "sentiment" => Dict(
                "distribution" => sentiment_data["distribution"],
                "total_analyzed" => sentiment_data["total_analyzed"],
                "average_confidence" => sentiment_data["average_confidence"],
                "results" => sentiment_data["results"]
            ),
            "trends" => Dict(
                "trending_topics" => trend_data["trending_topics"],
                "total_topics" => trend_data["total_topics"],
                "top_trends" => trend_data["top_trends"],
                "analysis_period" => trend_data["analysis_period"]
            )
        ),
        
        # Consensus Analytics (from consensusVerifier.jl)
        "consensus" => Dict(
            "total_agents" => consensus_data["total_agents"],
            "consensus_score" => consensus_data["consensus_score"],
            "authentic_posts" => consensus_data["authentic_posts"],
            "fake_posts" => consensus_data["fake_posts"],
            "agent_performance" => consensus_data["agent_performance"],
            "verification_results" => consensus_data["results"]
        ),
        
        # Performance Metrics
        "performance" => Dict(
            "total_engagement" => reddit_data["total_engagement"],
            "average_sentiment_confidence" => sentiment_data["average_confidence"],
            "trending_topics_count" => trend_data["total_topics"],
            "consensus_confidence" => consensus_data["consensus_score"]
        ),
        
        # Timeline Data
        "timeline" => Dict(
            "posts" => [Dict(
                "date" => string(unix2datetime(post["created_utc"])),
                "engagement" => post["score"] + post["num_comments"],
                "platform" => "reddit"
            ) for post in reddit_data["posts"]],
            "sentiment" => [Dict(
                "date" => string(now()),
                "positive" => sentiment_data["distribution"][:positive],
                "negative" => sentiment_data["distribution"][:negative],
                "neutral" => sentiment_data["distribution"][:neutral]
            )],
            "trends" => [Dict(
                "date" => string(now()),
                "topics" => length(trend_data["trending_topics"])
            )]
        )
    )
    
    return analytics
end

unified_analytics = create_unified_analytics(
    CAMPAIGN_ID, 
    reddit_analytics, 
    sentiment_analytics, 
    trend_analytics, 
    consensus_analytics
)

println("✅ Unified analytics created")
println("  Campaign ID: $(unified_analytics["campaign"]["id"])")
println("  Total posts: $(unified_analytics["crawler"]["total_posts"])")
println("  Sentiment analyzed: $(unified_analytics["analysis"]["sentiment"]["total_analyzed"])")
println("  Trending topics: $(unified_analytics["analysis"]["trends"]["total_topics"])")
println("  Consensus agents: $(unified_analytics["consensus"]["total_agents"])")

# Step 6: Export Analytics for Frontend
println("\n🔧 Step 6: Exporting Analytics for Frontend")
println(repeat("-", 40))

# Export individual analytics files
JSON3.write("analytics_reddit.json", reddit_analytics)
JSON3.write("analytics_sentiment.json", sentiment_analytics)
JSON3.write("analytics_trend.json", trend_analytics)
JSON3.write("analytics_consensus.json", consensus_analytics)
JSON3.write("analytics_unified.json", unified_analytics)

println("✅ Analytics exported:")
println("  analytics_reddit.json")
println("  analytics_sentiment.json")
println("  analytics_trend.json")
println("  analytics_consensus.json")
println("  analytics_unified.json")

# Step 7: Create API Endpoints Data
println("\n🔧 Step 7: Creating API Endpoints Data")
println(repeat("-", 40))

# Campaign analytics endpoint data
campaign_analytics = Dict(
    "campaign" => unified_analytics["campaign"],
    "crawler" => unified_analytics["crawler"],
    "analysis" => unified_analytics["analysis"],
    "consensus" => unified_analytics["consensus"],
    "performance" => unified_analytics["performance"],
    "timeline" => unified_analytics["timeline"]
)

# Analysis analytics endpoint data
analysis_analytics = Dict(
    "sentiment" => unified_analytics["analysis"]["sentiment"],
    "trends" => unified_analytics["analysis"]["trends"],
    "engagement" => Dict(
        "total" => unified_analytics["crawler"]["total_engagement"],
        "average" => unified_analytics["crawler"]["average_engagement"],
        "rate" => unified_analytics["crawler"]["total_engagement"] / unified_analytics["crawler"]["total_posts"]
    ),
    "content" => Dict(
        "totalPosts" => unified_analytics["crawler"]["total_posts"],
        "averageLength" => mean([length(post["title"]) for post in unified_analytics["crawler"]["recent_posts"]]),
        "mediaPosts" => 0,
        "textOnlyPosts" => unified_analytics["crawler"]["total_posts"]
    ),
    "juliaData" => Dict(
        "sentimentAnalysis" => unified_analytics["analysis"]["sentiment"],
        "trendAnalysis" => unified_analytics["analysis"]["trends"]
    ),
    "timeline" => unified_analytics["timeline"]
)

# Consensus analytics endpoint data
consensus_endpoint_analytics = Dict(
    "consensus" => Dict(
        "totalVerifications" => unified_analytics["consensus"]["authentic_posts"] + unified_analytics["consensus"]["fake_posts"],
        "authenticPosts" => unified_analytics["consensus"]["authentic_posts"],
        "fakePosts" => unified_analytics["consensus"]["fake_posts"],
        "pendingPosts" => 0,
        "consensusScore" => unified_analytics["consensus"]["consensus_score"],
        "averageConfidence" => unified_analytics["consensus"]["consensus_score"]
    ),
    "agents" => Dict(
        "totalAgents" => unified_analytics["consensus"]["total_agents"],
        "activeAgents" => unified_analytics["consensus"]["total_agents"],
        "agentPerformance" => unified_analytics["consensus"]["agent_performance"]
    ),
    "verification" => Dict(
        "results" => unified_analytics["consensus"]["verification_results"],
        "breakdown" => Dict(
            "authentic" => unified_analytics["consensus"]["authentic_posts"],
            "fake" => unified_analytics["consensus"]["fake_posts"],
            "pending" => 0
        )
    ),
    "juliaData" => Dict(
        "consensusVerification" => unified_analytics["consensus"],
        "agentConsensus" => unified_analytics["consensus"]["agent_performance"]
    )
)

# Crawler analytics endpoint data
crawler_endpoint_analytics = Dict(
    "totalPosts" => unified_analytics["crawler"]["total_posts"],
    "platforms" => unified_analytics["crawler"]["platforms"],
    "recentPosts" => unified_analytics["crawler"]["recent_posts"],
    "platformStats" => Dict(
        "reddit" => Dict(
            "posts" => unified_analytics["crawler"]["total_posts"],
            "engagement" => unified_analytics["crawler"]["total_engagement"],
            "likes" => sum([post["score"] for post in unified_analytics["crawler"]["recent_posts"]]),
            "comments" => sum([post["num_comments"] for post in unified_analytics["crawler"]["recent_posts"]]),
            "shares" => 0
        )
    ),
    "juliaData" => Dict(
        "redditStats" => Dict(
            "posts" => unified_analytics["crawler"]["total_posts"],
            "engagement" => unified_analytics["crawler"]["total_engagement"],
            "reach" => unified_analytics["crawler"]["total_engagement"] * 10
        ),
        "agentStatus" => [Dict("status" => "active", "agent" => "reddit_crawler")],
        "recentActivity" => unified_analytics["crawler"]["recent_posts"],
        "averageResponseTime" => 2.5
    ),
    "timeline" => unified_analytics["timeline"]["posts"]
)

# Export API endpoint data
JSON3.write("api_campaign_analytics.json", campaign_analytics)
JSON3.write("api_analysis_analytics.json", analysis_analytics)
JSON3.write("api_consensus_analytics.json", consensus_endpoint_analytics)
JSON3.write("api_crawler_analytics.json", crawler_endpoint_analytics)

println("✅ API endpoint data exported:")
println("  api_campaign_analytics.json")
println("  api_analysis_analytics.json")
println("  api_consensus_analytics.json")
println("  api_crawler_analytics.json")

# Final summary
println("\n🎉 Analytics Integration Complete")
println(repeat("=", 60))
println("✅ Reddit data processed: $(unified_analytics["crawler"]["total_posts"]) posts")
println("✅ Sentiment analysis: $(unified_analytics["analysis"]["sentiment"]["total_analyzed"]) posts")
println("✅ Trend analysis: $(unified_analytics["analysis"]["trends"]["total_topics"]) topics")
println("✅ Consensus verification: $(unified_analytics["consensus"]["total_agents"]) agents")
println("✅ All data integrated and exported for frontend consumption")

println("\n📋 Integration Summary:")
println("  - Campaign ID: $(CAMPAIGN_ID)")
println("  - Total engagement: $(unified_analytics["crawler"]["total_engagement"])")
println("  - Sentiment confidence: $(round(unified_analytics["analysis"]["sentiment"]["average_confidence"], digits=2))")
println("  - Consensus score: $(round(unified_analytics["consensus"]["consensus_score"], digits=2))")
println("  - Ready for frontend integration")

println("\n🚀 All Julia agent data successfully integrated into analytics system!") 