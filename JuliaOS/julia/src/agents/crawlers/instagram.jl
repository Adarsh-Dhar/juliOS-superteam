# Crawlers/Instagram.jl
module Instagram

using HTTP, JSON3, Dates, Base64, SHA, Random

# Import the required modules - these will be loaded by the server
# For now, we'll define the AbstractAgent type locally
abstract type AbstractAgent end

const DEFAULT_USER_AGENTS = [
    "JuliaOS-Crawler/1.0 (Linux; U; Android 13; en-US)",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Safari/605.1.15"
]

const RATE_LIMIT_BUFFER = 0.2  # 20% buffer for rate limits
const MAX_POSTS_PER_REQUEST = 50

struct InstagramPost
    id::String
    shortcode::String
    caption::String
    media_type::String  # IMAGE, VIDEO, CAROUSEL_ALBUM
    media_url::String
    thumbnail_url::String
    permalink::String
    timestamp::DateTime
    like_count::Int
    comment_count::Int
    author_hash::String
    author_username::String
    location::Union{String, Nothing}
    hashtags::Vector{String}
    mentions::Vector{String}
    is_video::Bool
    video_url::Union{String, Nothing}
    carousel_media::Vector{Dict}
end

struct InstagramCrawler <: AbstractAgent
    id::String
    config::Dict
    access_token::String
    last_scrape::DateTime
    proxy_pool::Vector{String}
    current_proxy::String
    user_agent::String
    backoff_until::DateTime
    error_count::Int
end

function InstagramCrawler(id::String, config::Dict)
    # Get credentials from environment or secure vault
    access_token = get(ENV, "INSTAGRAM_ACCESS_TOKEN", "")
    
    # Mock proxy pool
    proxies = String[]
    
    # Default configuration
    default_config = Dict(
        "hashtags" => [],
        "users" => [],
        "locations" => [],
        "keywords" => [],
        "scrape_interval" => 300,  # 5 minutes
        "max_posts" => 1000,
        "include_videos" => true,
        "include_carousel" => true,
        "region" => "global"
    )
    
    # Merge with user config
    merged_config = merge(default_config, config)
    
    # Initialize state
    InstagramCrawler(
        id,
        merged_config,
        access_token,
        now() - Minute(10),  # Start immediately
        proxies,
        isempty(proxies) ? "" : rand(proxies),
        rand(DEFAULT_USER_AGENTS),
        now(),
        0    # Initial error count
    )
end

function error_count(agent::InstagramCrawler)
    return agent.error_count
end

function compress(data::IOBuffer)
    # Simple compression - in production, use proper compression
    return take!(data)
end

function process_posts(posts::Vector{InstagramPost})
    # Process posts for analysis
    return posts
end

function run(agent::InstagramCrawler)
    # Mock reputation system
    @info "Instagram crawler $(agent.id) started"
    
    while is_active(agent)
        try
            # Check if in backoff period
            if now() < agent.backoff_until
                sleep(ceil(Int, (agent.backoff_until - now()).value / 1000))
                continue
            end
            
            # Rotate resources
            rotate_resources!(agent)
            
            # Scrape data
            posts = scrape_instagram(agent)
            
            if !isempty(posts)
                # Process and store
                processed = process_posts(posts)
                cid = store_data(processed)
                
                # Send to analyzers
                send_to_analyzers(agent, cid, length(posts))
                
                # Update last scrape time
                agent.last_scrape = now()
                
                # Report success
                @info "Crawler $(agent.id) scraped $(length(posts)) posts successfully"
            end
            
            # Sleep until next scrape
            sleep(agent.config["scrape_interval"])
            
        catch e
            handle_error(agent, e)
            # Exponential backoff
            backoff = min(2^(error_count(agent)) * 60, 3600)  # Max 1 hour
            agent.backoff_until = now() + Second(backoff)
        end
    end
end

function scrape_instagram(agent::InstagramCrawler)
    posts = InstagramPost[]
    
    # Get hashtags to monitor
    hashtags = get_hashtags_to_monitor(agent)
    
    for hashtag in hashtags
        # Build API URL
        url = "https://graph.instagram.com/v12.0/ig_hashtag_search"
        
        # Add parameters
        params = Dict(
            "user_token" => agent.access_token,
            "q" => hashtag,
            "limit" => MAX_POSTS_PER_REQUEST
        )
        
        # Make request
        headers = [
            "User-Agent" => agent.user_agent
        ]
        
        response = HTTP.get(
            url,
            headers=headers,
            query=params,
            proxy=agent.current_proxy,
            readtimeout=30,
            retry=false
        )
        
        # Handle rate limits
        handle_rate_limits(response)
        
        # Parse response
        if response.status == 200
            data = JSON3.read(response.body)
            if haskey(data, "data")
                for item in data["data"]
                    # Get detailed post information
                    post_details = get_post_details(agent, item["id"])
                    if post_details !== nothing
                        push!(posts, post_details)
                    end
                end
                
                # Enforce max posts limit
                if length(posts) >= agent.config["max_posts"]
                    resize!(posts, agent.config["max_posts"])
                    break
                end
            end
        else
            throw(HTTPException(response.status, response.body))
        end
    end
    
    return posts
end

function get_hashtags_to_monitor(agent::InstagramCrawler)
    hashtags = String[]
    
    # Add specific hashtags if configured
    if !isempty(agent.config["hashtags"])
        append!(hashtags, agent.config["hashtags"])
    end
    
    # Add hashtags from keywords
    if !isempty(agent.config["keywords"])
        for keyword in agent.config["keywords"]
            push!(hashtags, keyword)
        end
    end
    
    return unique(hashtags)
end

function get_post_details(agent::InstagramCrawler, post_id::String)
    url = "https://graph.instagram.com/v12.0/$post_id"
    
    params = Dict(
        "fields" => "id,shortcode,caption,media_type,media_url,thumbnail_url,permalink,timestamp,like_count,comment_count,owner,location,children{media_url,media_type}",
        "access_token" => agent.access_token
    )
    
    headers = [
        "User-Agent" => agent.user_agent
    ]
    
    response = HTTP.get(
        url,
        headers=headers,
        query=params,
        proxy=agent.current_proxy,
        readtimeout=30,
        retry=false
    )
    
    if response.status == 200
        data = JSON3.read(response.body)
        return parse_post_data(data)
    end
    
    return nothing
end

function parse_post_data(data::Dict)
    # Extract hashtags and mentions from caption
    caption = get(data, "caption", "")
    hashtags = extract_hashtags(caption)
    mentions = extract_mentions(caption)
    
    # Parse carousel media if present
    carousel_media = []
    if haskey(data, "children")
        for child in data["children"]["data"]
            push!(carousel_media, Dict(
                "media_url" => child["media_url"],
                "media_type" => child["media_type"]
            ))
        end
    end
    
    # Create post object
    return InstagramPost(
        data["id"],
        data["shortcode"],
        sanitize_text(caption),
        data["media_type"],
        get(data, "media_url", ""),
        get(data, "thumbnail_url", ""),
        data["permalink"],
        DateTime(data["timestamp"], dateformat"yyyy-mm-ddTHH:MM:SS+ssss"),
        get(data, "like_count", 0),
        get(data, "comment_count", 0),
        anonymize_author(data["owner"]["id"], data["owner"]["username"]),
        data["owner"]["username"],
        get(data, "location", nothing),
        hashtags,
        mentions,
        data["media_type"] == "VIDEO",
        data["media_type"] == "VIDEO" ? get(data, "media_url", nothing) : nothing,
        carousel_media
    )
end

function extract_hashtags(text::String)
    hashtags = String[]
    for match in eachmatch(r"#(\w+)", text)
        push!(hashtags, match[1])
    end
    return hashtags
end

function extract_mentions(text::String)
    mentions = String[]
    for match in eachmatch(r"@(\w+)", text)
        push!(mentions, match[1])
    end
    return mentions
end

function sanitize_text(text::String)
    # Remove PII and sensitive information
    text = replace(text, r"@\w+" => "@[USER]")
    text = replace(text, r"http\S+" => "[URL]")
    text = replace(text, r"\b\d{3}[-.]?\d{3}[-.]?\d{4}\b" => "[PHONE]")
    text = replace(text, r"\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b"i => "[EMAIL]")
    return text
end

function anonymize_author(user_id::String, username::String)
    # Mock salt for now
    salt = "juliaos_salt_$(randstring(16))"
    return bytes2hex(sha256("$username$salt"))
end

function store_data(posts::Vector{InstagramPost})
    # Create efficient binary representation
    binary_data = IOBuffer()
    for post in posts
        write(binary_data, post.id)
        write(binary_data, post.shortcode)
        write(binary_data, post.caption)
        write(binary_data, post.media_type)
        write(binary_data, post.media_url)
        write(binary_data, post.thumbnail_url)
        write(binary_data, post.permalink)
        write(binary_data, datetime2unix(post.timestamp))
        write(binary_data, Int32(post.like_count))
        write(binary_data, Int32(post.comment_count))
        write(binary_data, post.author_hash)
        write(binary_data, post.author_username)
        write(binary_data, post.is_video ? 0x01 : 0x00)
        
        # Write optional fields
        write(binary_data, post.location !== nothing ? post.location : "")
        write(binary_data, post.video_url !== nothing ? post.video_url : "")
        
        # Write hashtags
        write(binary_data, UInt8(length(post.hashtags)))
        for tag in post.hashtags
            write(binary_data, tag)
        end
        
        # Write mentions
        write(binary_data, UInt8(length(post.mentions)))
        for mention in post.mentions
            write(binary_data, mention)
        end
        
        # Write carousel media
        write(binary_data, UInt8(length(post.carousel_media)))
        for media in post.carousel_media
            write(binary_data, media["media_url"])
            write(binary_data, media["media_type"])
        end
    end
    
    # Mock IPFS storage
    data = take!(binary_data)
    cid = "bafybeib$(bytes2hex(sha256(string(length(data)))))"
    
    @info "Stored data with CID: $cid"
    return cid
end

function handle_rate_limits(response::HTTP.Response)
    remaining = tryparse(Int, HTTP.header(response, "X-RateLimit-Remaining", "200"))
    reset_time = tryparse(Int, HTTP.header(response, "X-RateLimit-Reset", "3600"))
    
    if remaining < 10
        current_time = round(Int, time())
        sleep_seconds = max(reset_time - current_time, 0) + 60
        sleep(sleep_seconds)
    end
end

function rotate_resources!(agent::InstagramCrawler)
    # Rotate proxy
    if !isempty(agent.proxy_pool)
        agent.current_proxy = rand(agent.proxy_pool)
    end
    
    # Rotate user agent
    agent.user_agent = rand(DEFAULT_USER_AGENTS)
end

function send_to_analyzers(agent::InstagramCrawler, cid::String, count::Int)
    # Mock analyzer communication
    @info "Sending $(count) posts to analyzers with CID: $cid"
    
    # In a real implementation, this would send to actual analyzers
    # For now, just log the action
end

function handle_error(agent::InstagramCrawler, e)
    error_type = classify_error(e)
    # Mock reputation reporting
    @info "Crawler $(agent.id) encountered error: $error_type"
    
    if error_type == "authentication"
        @warn "Authentication error - check access token validity"
    elseif error_type == "rate_limit"
        agent.backoff_until = now() + Minute(15)
    elseif error_type == "permission"
        @warn "Insufficient permissions for requested data"
    end
    
    @error "Crawler error: $e"
end

function classify_error(e)
    if e isa HTTPException
        if e.status == 401 || e.status == 403
            return "authentication"
        elseif e.status == 429
            return "rate_limit"
        elseif e.status == 400
            return "bad_request"
        elseif e.status == 403
            return "permission"
        else
            return "http_$(e.status)"
        end
    else
        return "unknown"
    end
end

function is_active(agent::InstagramCrawler)
    # Check campaign duration
    if haskey(agent.config, "start_time") && haskey(agent.config, "duration")
        end_time = agent.config["start_time"] + Second(agent.config["duration"])
        return now() < end_time
    end
    return true  # Default to active if no duration specified
end

function status(agent::InstagramCrawler)
    # Return the current status of the agent
    return "running"  # Default status
end

struct HTTPException <: Exception
    status::Int
    body::Vector{UInt8}
end

end # module Instagram 