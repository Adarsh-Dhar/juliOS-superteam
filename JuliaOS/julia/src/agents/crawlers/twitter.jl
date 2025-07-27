# Crawlers/Twitter.jl
module Twitter

using HTTP, JSON3, Dates, Base64, SHA, Random
using JuliaOS.AgentFramework, JuliaOS.Vault, JuliaOS.IPFS, JuliaOS.ReputationKeeper

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

struct TwitterCrawler <: AbstractAgent
    id::String
    config::Dict
    bearer_token::String
    last_scrape::DateTime
    proxy_pool::Vector{String}
    current_proxy::String
    user_agent::String
    backoff_until::DateTime
    next_token::String  # For pagination
end

function TwitterCrawler(id::String, config::Dict)
    # Get credentials from secure vault
    creds = Vault.get_secrets("twitter_api")
    
    # Initialize proxy pool
    proxies = Vault.get_proxies("crawling", config["region"] ? config["region"] : "global")
    
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
    new(
        id,
        merged_config,
        creds["bearer_token"],
        now() - Minute(10),  # Start immediately
        proxies,
        isempty(proxies) ? "" : rand(proxies),
        rand(DEFAULT_USER_AGENTS),
        now(),
        ""  # Initial pagination token
    )
end

function run(agent::TwitterCrawler)
    # Register with reputation system
    ReputationKeeper.stake(agent.id, 0.1)
    
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
            tweets = scrape_twitter(agent)
            
            if !isempty(tweets)
                # Process and store
                processed = process_tweets(tweets)
                cid = store_data(processed)
                
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

function scrape_twitter(agent::TwitterCrawler)
    tweets = Tweet[]
    query = build_query(agent)
    
    while length(tweets) < agent.config["max_tweets"]
        # Build API URL
        url = "https://api.twitter.com/2/tweets/search/recent?query=$query" *
              "&max_results=$MAX_TWEETS_PER_REQUEST" *
              "&tweet.fields=created_at,public_metrics,possibly_sensitive,referenced_tweets,lang" *
              "&expansions=author_id,attachments.media_keys" *
              "&media.fields=type,url" *
              "&user.fields=created_at" *
              (isempty(agent.next_token) ? "" : "&next_token=$(agent.next_token)")
        
        # Make request
        headers = [
            "Authorization" => "Bearer $(agent.bearer_token)",
            "User-Agent" => agent.user_agent
        ]
        
        response = HTTP.get(
            url,
            headers=headers,
            proxy=agent.current_proxy,
            readtimeout=30,
            retry=false
        )
        
        # Handle rate limits
        handle_rate_limits(response)
        
        # Parse response
        if response.status == 200
            data = JSON3.read(response.body)
            new_tweets = parse_response(data)
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
    
    # Keywords
    if !isempty(agent.config["keywords"])
        push!(query_parts, "($(join(agent.config["keywords"], " OR ")))")
    end
    
    # Hashtags
    if !isempty(agent.config["hashtags"])
        hashtags = ["#$tag" for tag in agent.config["hashtags"]]
        push!(query_parts, "($(join(hashtags, " OR ")))")
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
    push!(query_parts, "-is:retweet") unless agent.config["include_retweets"]
    push!(query_parts, "-is:reply") unless agent.config["include_replies"]
    push!(query_parts, "-is:nullcast")  # Always exclude nullcast
    
    # Combine query parts
    return join(query_parts, " ")
end

function parse_response(data::Dict)
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
        # Twitter bearer tokens don't refresh automatically
        @warn "Authentication error - check token validity"
    elseif error_type == "rate_limit"
        agent.backoff_until = now() + Minute(15)
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
    # Check campaign duration
    end_time = agent.config["start_time"] + Second(agent.config["duration"])
    return now() < end_time && agent.status != "terminated"
end

# Agent registration
JuliaOS.register_agent_type(
    "TwitterCrawler",
    TwitterCrawler,
    config_schema=Dict(
        "keywords" => (Vector{String}, []),
        "hashtags" => (Vector{String}, []),
        "users" => (Vector{String}, []),
        "languages" => (Vector{String}, ["en"]),
        "scrape_interval" => (Int, 300),
        "max_tweets" => (Int, 5000),
        "include_retweets" => (Bool, false),
        "include_replies" => (Bool, true),
        "include_media" => (Bool, false),
        "region" => (String, "global"),
        "duration" => (Int, 86400)  # Default 24 hours
    ),
    required_secrets=["twitter_api"]
)

end