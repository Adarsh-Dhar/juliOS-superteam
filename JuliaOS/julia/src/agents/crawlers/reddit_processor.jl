# Reddit Data Processor
# Converts Reddit API data to format expected by sentiment and trend analyzers

using JSON3, Dates, Random

"""
Convert Reddit API data to the format expected by sentiment and trend analyzers
"""
function process_reddit_data(reddit_posts::Vector{Dict})
    processed_content = []
    
    for post in reddit_posts
        # Convert Reddit post to analyzer format
        processed_post = Dict(
            "id" => post["id"],
            "text" => post["title"],  # Use title as main text
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
                "author" => post["author"],
                "upvote_ratio" => get(post, "upvote_ratio", 1.0),
                "over_18" => get(post, "over_18", false),
                "spoiler" => get(post, "spoiler", false)
            )
        )
        
        push!(processed_content, processed_post)
    end
    
    return processed_content
end

"""
Create a message for the sentiment analyzer
"""
function create_sentiment_message(content::Vector{Dict}, source_id::String="reddit_crawler")
    return Dict(
        "type" => "new_content",
        "source" => source_id,
        "cid" => "mock_cid_$(randstring(8))",  # In real implementation, this would be IPFS CID
        "content" => content,
        "timestamp" => now(),
        "count" => length(content)
    )
end

"""
Create a message for the trend analyzer
"""
function create_trend_message(content::Vector{Dict}, source_id::String="reddit_crawler")
    return Dict(
        "type" => "new_content",
        "source" => source_id,
        "cid" => "mock_cid_$(randstring(8))",
        "content" => content,
        "timestamp" => now(),
        "count" => length(content)
    )
end

"""
Validate Reddit data structure
"""
function validate_reddit_data(data::Vector{Dict})
    required_fields = ["id", "title", "subreddit", "score", "num_comments", "url", "author", "created_utc"]
    
    for (i, post) in enumerate(data)
        for field in required_fields
            if !haskey(post, field)
                @warn "Missing required field '$field' in post $i"
                return false
            end
        end
    end
    
    return true
end

"""
Extract subreddit statistics from processed content
"""
function extract_subreddit_stats(content::Vector{Dict})
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

"""
Filter content by subreddit
"""
function filter_by_subreddit(content::Vector{Dict}, subreddits::Vector{String})
    return filter(post -> post["subreddit"] in subreddits, content)
end

"""
Filter content by score threshold
"""
function filter_by_score(content::Vector{Dict}, min_score::Int=0)
    return filter(post -> post["score"] >= min_score, content)
end

"""
Sort content by various criteria
"""
function sort_content(content::Vector{Dict}, by_field::String="created_at", reverse::Bool=true)
    if by_field == "created_at"
        return sort(content, by=x->x["created_at"], rev=reverse)
    elseif by_field == "score"
        return sort(content, by=x->x["score"], rev=reverse)
    elseif by_field == "num_comments"
        return sort(content, by=x->x["num_comments"], rev=reverse)
    else
        return content
    end
end

"""
Export processed content to JSON file
"""
function export_to_json(content::Vector{Dict}, filename::String)
    try
        JSON3.write(filename, content)
        @info "Exported $(length(content)) posts to $filename"
        return true
    catch e
        @error "Failed to export to $filename: $e"
        return false
    end
end

"""
Load content from JSON file
"""
function load_from_json(filename::String)
    try
        content = JSON3.read(filename)
        @info "Loaded $(length(content)) posts from $filename"
        return content
    catch e
        @error "Failed to load from $filename: $e"
        return []
    end
end 