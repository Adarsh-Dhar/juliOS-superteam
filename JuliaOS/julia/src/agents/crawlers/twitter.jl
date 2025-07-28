# Crawlers/Twitter.jl
# 
# Twitter API Crawler for JuliaOS
# 
# Required Environment Variables:
# - TWITTER_BEARER_TOKEN: Your Twitter API v2 Bearer Token
# - TWITTER_CLIENT_ID: Your Twitter API Client ID  
# - TWITTER_CLIENT_SECRET: Your Twitter API Client Secret
# - TWITTER_ACCESS_TOKEN: Your Twitter API Access Token
# - TWITTER_ACCESS_TOKEN_SECRET: Your Twitter API Access Token Secret
#
# Note: Twitter API tokens do not auto-refresh. When tokens expire,
# you need to manually regenerate them through the Twitter Developer Portal.
# The crawler will detect authentication errors and provide helpful error messages.

module Twitter

using HTTP, JSON3, Dates, Base64, SHA, Random

# Import the required modules from the main server context
# These modules are loaded by the server and available in the main context
using ..Vault
using ..ReputationKeeper
using ..IPFS
using ..SwarmComms

# Import the required modules - these will be loaded by the server
# For now, we'll define the AbstractAgent type locally
abstract type AbstractAgent end

const DEFAULT_USER_AGENTS = [
    "JuliaOS-Crawler/1.0 (Linux; U; Android 13; en-US)",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Safari/605.1.15"
]

const RATE_LIMIT_BUFFER = 0.2  # 20% buffer for rate limits
const MAX_TWEETS_PER_REQUEST = 100

struct Tweet
    id::String
    text::String
    created_at::DateTime
    author_hash::String
    language::String
    retweet_count::Int32
    reply_count::Int32
    like_count::Int32
    quote_count::Int32
    impression_count::Int32
    url::String
    is_retweet::Bool
    is_quote::Bool
    possibly_sensitive::Bool
    referenced_tweets::Vector{Dict}
    hashtags::Vector{String}
    mentions::Vector{String}
    media::Vector{Dict}
end

mutable struct TwitterCrawler <: AbstractAgent
    id::String
    config::Dict
    bearer_token::String
    client_id::String
    client_secret::String
    access_token::String
    access_token_secret::String
    last_scrape::DateTime
    proxy_pool::Vector{String}
    current_proxy::String
    user_agent::String
    backoff_until::DateTime
    next_token::String  # For pagination
    error_count::Int  # Add error count field
    status::String  # Add status field
    start_time::DateTime  # Add start_time field
end

function TwitterCrawler(id::String, config::Dict)
    # Check environment variables first
    if !check_twitter_env_vars()
        error("Twitter API environment variables are not set. Please set TWITTER_BEARER_TOKEN, TWITTER_CLIENT_ID, TWITTER_CLIENT_SECRET, TWITTER_ACCESS_TOKEN, and TWITTER_ACCESS_TOKEN_SECRET.")
    end
    
    # Get credentials from secure vault
    creds = Vault.get_secrets("twitter_api")
    
    # Validate credentials before proceeding
    if !validate_twitter_credentials(creds)
        error("Twitter API credentials are missing or invalid. Please check environment variables.")
    end
    
    # Initialize proxy pool
    region = get(config, "region", "global")
    proxies = Vault.get_proxies("crawling", region)
    
    # Default configuration
    default_config = Dict(
        "keywords" => [],
        "hashtags" => [],
        "users" => [],
        "languages" => ["en"],
        "scrape_interval" => 300,  # 5 minutes
        "max_tweets" => 5000,
        "include_retweets" => false,
        "include_replies" => true,
        "include_media" => false,
        "region" => "global"
    )
    
    # Merge with user config
    merged_config = merge(default_config, config)
    
    # Initialize state
    TwitterCrawler(
        id,
        merged_config,
        creds["bearer_token"],
        creds["client_id"],
        creds["client_secret"],
        creds["access_token"],
        creds["access_token_secret"],
        now() - Minute(10),  # Start immediately
        proxies,
        isempty(proxies) ? "" : rand(proxies),
        rand(DEFAULT_USER_AGENTS),
        now(),
        "",  # Initial pagination token
        0,    # Initial error count
        "CREATED", # Initial status
        now() # Initial start time
    )
end

# Add missing helper functions
function error_count(agent::TwitterCrawler)
    return agent.error_count
end

function validate_twitter_credentials(creds::Dict{String, Any})
    """Validate that all required Twitter API credentials are present"""
    required_fields = ["bearer_token", "client_id", "client_secret", "access_token", "access_token_secret"]
    missing_fields = String[]
    
    for field in required_fields
        if !haskey(creds, field) || isempty(creds[field])
            push!(missing_fields, field)
        end
    end
    
    if !isempty(missing_fields)
        @error "Missing or empty Twitter API credentials: $(join(missing_fields, ", "))"
        @error "Please set the following environment variables:"
        for field in missing_fields
            env_var = "TWITTER_$(uppercase(replace(field, "_" => "")))"
            @error "  - $env_var"
        end
        return false
    end
    
    return true
end

function check_twitter_env_vars()
    """Check if all required Twitter environment variables are set"""
    required_vars = [
        "TWITTER_BEARER_TOKEN",
        "TWITTER_CLIENT_ID", 
        "TWITTER_CLIENT_SECRET",
        "TWITTER_ACCESS_TOKEN",
        "TWITTER_ACCESS_TOKEN_SECRET"
    ]
    
    missing_vars = String[]
    for var in required_vars
        if !haskey(ENV, var) || isempty(ENV[var])
            push!(missing_vars, var)
        end
    end
    
    if !isempty(missing_vars)
        @warn "Missing Twitter environment variables: $(join(missing_vars, ", "))"
        @warn "Twitter crawler will fail to initialize without these variables"
        return false
    end
    
    return true
end

function compress(data::IOBuffer)
    # Simple compression - in production, use proper compression
    return take!(data)
end

function process_tweets(tweets::Vector{Tweet})
    # Process tweets for analysis
    return tweets
end

function run(agent::TwitterCrawler)
    @info "Starting Twitter crawler: $(agent.id)"
    @info "Crawler config: $(agent.config)"
    
    # Register with reputation system
    ReputationKeeper.stake(agent.id, 0.1)
    
    while is_active(agent)
        try
            @info "Twitter crawler $(agent.id) is active, checking backoff..."
            
            # Check if in backoff period
            if now() < agent.backoff_until
                @info "Twitter crawler $(agent.id) in backoff until $(agent.backoff_until)"
                sleep(ceil(Int, (agent.backoff_until - now()).value / 1000))
                continue
            end
            
            @info "Twitter crawler $(agent.id) starting scrape..."
            
            # Rotate resources
            rotate_resources!(agent)
            
            # Scrape data
            tweets = scrape_twitter(agent)
            
            @info "Twitter crawler $(agent.id) scraped $(length(tweets)) tweets"
            
            if !isempty(tweets)
                # Log tweets to console
                println("=== TWITTER CRAWLER $(agent.id) - CRAWLED TWEETS ===")
                for (i, tweet) in enumerate(tweets)
                    println("Tweet $i:")
                    println("  ID: $(tweet.id)")
                    println("  Text: $(tweet.text)")
                    println("  Author: $(tweet.author_hash)")
                    println("  Created: $(tweet.created_at)")
                    println("  Language: $(tweet.language)")
                    println("  Metrics: $(tweet.like_count) likes, $(tweet.retweet_count) retweets, $(tweet.reply_count) replies")
                    println("  URL: $(tweet.url)")
                    println("  Hashtags: $(join(tweet.hashtags, ", "))")
                    println("  Mentions: $(join(tweet.mentions, ", "))")
                    println("  Is Retweet: $(tweet.is_retweet)")
                    println("  Is Quote: $(tweet.is_quote)")
                    println("  Sensitive: $(tweet.possibly_sensitive)")
                    println("---")
                end
                println("=== END OF TWEETS ===")
                
                # Process and store
                processed = process_tweets(tweets)
                cid = store_data(processed)
                
                @info "Twitter crawler $(agent.id) stored data with CID: $cid"
                
                # Send to analyzers
                send_to_analyzers(agent, cid, length(tweets))
                
                # Update last scrape time
                agent.last_scrape = now()
                
                # Report success
                ReputationKeeper.report(
                    agent.id, 
                    "scrape_success", 
                    Dict("tweet_count" => length(tweets))
                )
                
                @info "Twitter crawler $(agent.id) completed successful scrape"
            else
                @info "Twitter crawler $(agent.id) found no tweets"
            end
            
            # Sleep until next scrape
            sleep_time = agent.config["scrape_interval"]
            @info "Twitter crawler $(agent.id) sleeping for $sleep_time seconds"
            sleep(sleep_time)
            
        catch e
            @error "Twitter crawler $(agent.id) encountered error: $e"
            handle_error(agent, e)
            # Exponential backoff
            backoff = min(2^(error_count(agent)) * 60, 3600)  # Max 1 hour
            agent.backoff_until = now() + Second(backoff)
        end
    end
    
    @info "Twitter crawler $(agent.id) stopped"
end

function scrape_twitter(agent::TwitterCrawler)
    tweets = Tweet[]
    query = build_query(agent)
    
    @info "Twitter crawler $(agent.id) building query: $query"
    
    while length(tweets) < agent.config["max_tweets"]
        # Build API URL
        url = "https://api.twitter.com/2/tweets/search/recent?query=$query" *
              "&max_results=$MAX_TWEETS_PER_REQUEST" *
              "&tweet.fields=created_at,public_metrics,possibly_sensitive,referenced_tweets,lang" *
              "&expansions=author_id,attachments.media_keys" *
              "&media.fields=type,url" *
              "&user.fields=created_at" *
              (isempty(agent.next_token) ? "" : "&next_token=$(agent.next_token)")
        
        @info "Twitter crawler $(agent.id) making request to: $url"
        
        # Make request
        headers = [
            "Authorization" => "Bearer $(agent.bearer_token)",
            "User-Agent" => agent.user_agent
        ]
        
        # Handle proxy properly - only use if not empty
        request_kwargs = Dict{Symbol, Any}(
            :headers => headers,
            :readtimeout => 30,
            :retry => false
        )
        
        # Only add proxy if it's not empty
        if !isempty(agent.current_proxy)
            request_kwargs[:proxy] = agent.current_proxy
            @info "Twitter crawler $(agent.id) using proxy: $(agent.current_proxy)"
        else
            @info "Twitter crawler $(agent.id) not using proxy"
        end
        
        response = HTTP.get(url; request_kwargs...)
        
        # Handle rate limits
        handle_rate_limits(response)
        
        # Parse response
        if response.status == 200
            data = JSON3.read(response.body)
            new_tweets = parse_response(data, agent)
            append!(tweets, new_tweets)
            
            # Update pagination token
            agent.next_token = get(data, "meta", Dict()).get("next_token", "")
            
            # Break if no more pages
            if isempty(agent.next_token)
                break
            end
        else
            throw(HTTPException(response.status, response.body))
        end
    end
    
    return tweets
end

function build_query(agent::TwitterCrawler)
    query_parts = String[]
    
    # Keywords - don't wrap single keyword in parentheses
    if !isempty(agent.config["keywords"])
        if length(agent.config["keywords"]) == 1
            push!(query_parts, agent.config["keywords"][1])
        else
            push!(query_parts, "($(join(agent.config["keywords"], " OR ")))")
        end
    end
    
    # Hashtags
    if !isempty(agent.config["hashtags"])
        hashtags = String[]
        for tag in agent.config["hashtags"]
            clean_tag = replace(tag, r"^#" => "")
            push!(hashtags, "#$clean_tag")
        end
        if length(hashtags) == 1
            push!(query_parts, hashtags[1])
        else
            push!(query_parts, "($(join(hashtags, " OR ")))")
        end
    end
    
    # Users
    if !isempty(agent.config["users"])
        users = ["from:$user" for user in agent.config["users"]]
        push!(query_parts, "($(join(users, " OR ")))")
    end
    
    # Language filters
    if !isempty(agent.config["languages"])
        push!(query_parts, "lang:$(join(agent.config["languages"], " OR lang:"))")
    end
    
    # Content filters
    if !agent.config["include_retweets"]
        push!(query_parts, "-is:retweet")
    end
    if !agent.config["include_replies"]
        push!(query_parts, "-is:reply")
    end
    push!(query_parts, "-is:nullcast")
    
    # Combine query parts
    return join(query_parts, " ")
end

function parse_response(data::Dict, agent::TwitterCrawler)
    tweets = Tweet[]
    includes = get(data, "includes", Dict())
    users = get(includes, "users", Dict())
    media = get(includes, "media", Dict())
    
    for tweet in data["data"]
        # Skip retweets if configured
        if !agent.config["include_retweets"] && has_retweet(tweet)
            continue
        end
        
        # Extract hashtags and mentions
        hashtags = get_entities(tweet, "hashtags")
        mentions = get_entities(tweet, "mentions")
        
        # Get media if requested
        tweet_media = agent.config["include_media"] ? get_tweet_media(tweet, media) : []
        
        # Create tweet object
        push!(tweets, Tweet(
            tweet["id"],
            sanitize_text(tweet["text"]),
            DateTime(tweet["created_at"], dateformat"yyyy-mm-ddTHH:MM:SSZ"),
            anonymize_author(tweet["author_id"], users),
            get(tweet, "lang", "und"),
            tweet["public_metrics"]["retweet_count"],
            tweet["public_metrics"]["reply_count"],
            tweet["public_metrics"]["like_count"],
            tweet["public_metrics"]["quote_count"],
            get(tweet["public_metrics"], "impression_count", 0),
            "https://twitter.com/i/status/$(tweet["id"])",
            has_retweet(tweet),
            has_quote(tweet),
            get(tweet, "possibly_sensitive", false),
            get(tweet, "referenced_tweets", []),
            hashtags,
            mentions,
            tweet_media
        ))
    end
    return tweets
end

function get_entities(tweet::Dict, entity_type::String)
    entities = get(tweet, "entities", Dict())
    entity_list = get(entities, entity_type, [])
    return [e["tag"] for e in entity_list]  # For hashtags
end

function get_tweet_media(tweet::Dict, media_list::Vector)
    attachments = get(tweet, "attachments", Dict())
    media_keys = get(attachments, "media_keys", [])
    
    media_data = []
    for key in media_keys
        for m in media_list
            if m["media_key"] == key
                push!(media_data, Dict(
                    "type" => m["type"],
                    "url" => get(m, "url", ""),
                    "alt_text" => get(m, "alt_text", "")
                ))
            end
        end
    end
    return media_data
end

function has_retweet(tweet::Dict)
    refs = get(tweet, "referenced_tweets", [])
    return any(r -> r["type"] == "retweeted", refs)
end

function has_quote(tweet::Dict)
    refs = get(tweet, "referenced_tweets", [])
    return any(r -> r["type"] == "quoted", refs)
end

function sanitize_text(text::String)
    # Remove PII and sensitive information
    text = replace(text, r"@\w+" => "@[USER]")
    text = replace(text, r"\b\d{3}[-.]?\d{3}[-.]?\d{4}\b" => "[PHONE]")
    text = replace(text, r"\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b"i => "[EMAIL]")
    text = replace(text, r"\b\d{3}-\d{2}-\d{4}\b" => "[SSN]")
    text = replace(text, r"http\S+" => "[URL]")
    return text
end

function anonymize_author(author_id::String, users::Vector)
    # Find user in includes
    user = findfirst(u -> u["id"] == author_id, users)
    username = user !== nothing ? user["username"] : "unknown"
    
    salt = Vault.get_global_salt()
    return bytes2hex(sha256("$username$salt"))
end

function store_data(tweets::Vector{Tweet})
    # Create efficient binary representation
    binary_data = IOBuffer()
    for tweet in tweets
        write(binary_data, tweet.id)
        write(binary_data, tweet.text)
        write(binary_data, datetime2unix(tweet.created_at))
        write(binary_data, tweet.author_hash)
        write(binary_data, tweet.language)
        write(binary_data, Int32(tweet.retweet_count))
        write(binary_data, Int32(tweet.reply_count))
        write(binary_data, Int32(tweet.like_count))
        write(binary_data, Int32(tweet.quote_count))
        write(binary_data, Int32(tweet.impression_count))
        write(binary_data, tweet.is_retweet ? 0x01 : 0x00)
        write(binary_data, tweet.is_quote ? 0x01 : 0x00)
        write(binary_data, tweet.possibly_sensitive ? 0x01 : 0x00)
        
        # Write referenced tweets count
        write(binary_data, UInt8(length(tweet.referenced_tweets)))
        for ref in tweet.referenced_tweets
            write(binary_data, ref["id"])
            write(binary_data, ref["type"])
        end
        
        # Write hashtags
        write(binary_data, UInt8(length(tweet.hashtags)))
        for tag in tweet.hashtags
            write(binary_data, tag)
        end
        
        # Write mentions
        write(binary_data, UInt8(length(tweet.mentions)))
        for mention in tweet.mentions
            write(binary_data, mention)
        end
    end
    
    # Compress and store on IPFS
    compressed = compress(binary_data)
    cid = IPFS.add(compressed, options=Dict(
        "cid-version" => 1,
        "raw-leaves" => true,
        "hash" => "blake3"
    ))
    return cid
end

function handle_rate_limits(response::HTTP.Response)
    remaining = tryparse(Int, HTTP.header(response, "x-rate-limit-remaining", "15"))
    reset_time = tryparse(Int, HTTP.header(response, "x-rate-limit-reset", "900"))
    
    if remaining < 5
        current_time = round(Int, time())
        sleep_seconds = max(reset_time - current_time, 0) + 30
        sleep(sleep_seconds)
    end
end

function rotate_resources!(agent::TwitterCrawler)
    # Rotate proxy
    if !isempty(agent.proxy_pool)
        agent.current_proxy = rand(agent.proxy_pool)
    end
    
    # Rotate user agent
    agent.user_agent = rand(DEFAULT_USER_AGENTS)
end

function send_to_analyzers(agent::TwitterCrawler, cid::String, count::Int)
    # Send to sentiment analyzer
    SwarmComms.send(
        "sentiment_analyzer",
        Dict(
            "type" => "new_content",
            "source" => "twitter",
            "cid" => cid,
            "count" => count,
            "crawler_id" => agent.id
        )
    )
    
    # Send to threat analyzer
    SwarmComms.send(
        "threat_analyzer",
        Dict(
            "type" => "new_content",
            "source" => "twitter",
            "cid" => cid,
            "count" => count,
            "crawler_id" => agent.id
        )
    )
end

function handle_error(agent::TwitterCrawler, e)
    error_type = classify_error(e)
    ReputationKeeper.report(agent.id, "error", Dict("type" => error_type))
    
    if error_type == "authentication"
        # Twitter tokens don't refresh automatically - manual intervention required
        @error "Twitter authentication failed - tokens may be expired or invalid"
        @error "Please check and update the following environment variables:"
        @error "  - TWITTER_BEARER_TOKEN"
        @error "  - TWITTER_CLIENT_ID" 
        @error "  - TWITTER_CLIENT_SECRET"
        @error "  - TWITTER_ACCESS_TOKEN"
        @error "  - TWITTER_ACCESS_TOKEN_SECRET"
        @error "Twitter API tokens need manual renewal when they expire"
        
        # Set a longer backoff for authentication errors
        agent.backoff_until = now() + Hour(1)
    elseif error_type == "rate_limit"
        # Calculate proper backoff based on Twitter's rate limit reset time
        if e isa HTTPException
            reset_header = HTTP.header(e.response, "x-rate-limit-reset", "")
            if !isempty(reset_header)
                reset_time = tryparse(Int, reset_header)
                if reset_time !== nothing
                    current_time = round(Int, time())
                    wait_seconds = max(reset_time - current_time, 0) + 60  # Add 1 minute buffer
                    agent.backoff_until = now() + Second(wait_seconds)
                    @info "Twitter rate limit hit. Waiting until $(agent.backoff_until) (reset time: $reset_time, current: $current_time, wait: $wait_seconds seconds)"
                else
                    agent.backoff_until = now() + Hour(1)  # Fallback to 1 hour
                end
            else
                agent.backoff_until = now() + Hour(1)  # Fallback to 1 hour
            end
        else
            agent.backoff_until = now() + Hour(1)  # Fallback to 1 hour
        end
    elseif error_type == "ban"
        rotate_resources!(agent)
        agent.backoff_until = now() + Hour(2)
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
        else
            return "http_$(e.status)"
        end
    else
        return "unknown"
    end
end

function is_active(agent::TwitterCrawler)
    # Check if agent is terminated
    if agent.status == "terminated"
        return false
    end
    
    # Check campaign duration if specified
    if haskey(agent.config, "duration")
        end_time = agent.start_time + Second(agent.config["duration"])
        return now() < end_time
    end
    
    return true  # Default to active if no duration specified
end

end # module Twitter

# Add to the top of twitter.jl after the imports
struct HTTPException <: Exception
    status::Int
    body::Vector{UInt8}
end

struct AuthenticationException <: Exception
    message::String
end