# JuliaOS Crawlers

This directory contains crawler modules for various social media platforms and content sources. Each crawler is designed to collect, process, and store data in a privacy-conscious manner.

## Available Crawlers

### 1. Reddit Crawler (`reddit.jl`)
- **Purpose**: Scrapes posts and comments from Reddit subreddits
- **Features**:
  - Monitor specific subreddits
  - Keyword filtering
  - Time-based filtering (hour, day, week, month, year, all)
  - Sort options (hot, new, top, rising)
  - PII sanitization
  - Rate limit handling

### 2. Twitter Crawler (`twitter.jl`)
- **Purpose**: Collects tweets based on keywords, hashtags, and users
- **Features**:
  - Keyword and hashtag search
  - User timeline monitoring
  - Language filtering
  - Retweet and reply filtering
  - Media attachment handling
  - Sentiment analysis preparation

### 3. Instagram Crawler (`instagram.jl`)
- **Purpose**: Scrapes Instagram posts and stories
- **Features**:
  - Hashtag-based content discovery
  - User profile monitoring
  - Media type filtering (images, videos, carousels)
  - Location-based filtering
  - Caption and comment analysis

### 4. Discord Crawler (`discord.jl`)
- **Purpose**: Monitors Discord channels and servers
- **Features**:
  - Channel and guild monitoring
  - Message content analysis
  - Attachment handling
  - Embed processing
  - Bot message filtering

### 5. Telegram Crawler (`telegram.jl`)
- **Purpose**: Collects messages from Telegram channels and groups
- **Features**:
  - Chat monitoring
  - Media message handling
  - Forward and reply tracking
  - Entity extraction (mentions, hashtags)
  - Message type filtering

### 6. YouTube Crawler (`youtube.jl`)
- **Purpose**: Scrapes YouTube videos and metadata
- **Features**:
  - Keyword-based video search
  - Channel monitoring
  - Playlist tracking
  - Video statistics collection
  - Comment analysis (optional)

## Common Features

All crawlers share these common features:

- **Privacy Protection**: PII sanitization and user anonymization
- **Rate Limiting**: Intelligent backoff and rate limit handling
- **Error Handling**: Robust error classification and recovery
- **Data Storage**: Efficient binary storage with IPFS integration
- **Resource Rotation**: Proxy and user agent rotation
- **Configurable**: Flexible configuration options
- **Monitoring**: Comprehensive logging and status reporting

## Configuration

Each crawler accepts a configuration dictionary with platform-specific options:

### Common Configuration Options
```julia
config = Dict(
    "scrape_interval" => 300,  # 5 minutes
    "max_items" => 1000,       # Maximum items to collect
    "region" => "global",       # Geographic region
    "keywords" => [],           # Keywords to filter
    "start_time" => now(),      # Campaign start time
    "duration" => 3600          # Campaign duration in seconds
)
```

### Platform-Specific Options

#### Reddit
```julia
reddit_config = Dict(
    "subreddits" => ["programming", "technology"],
    "time_filter" => "day",
    "sort" => "new",
    "include_comments" => false
)
```

#### Twitter
```julia
twitter_config = Dict(
    "keywords" => ["julia", "programming"],
    "hashtags" => ["#JuliaLang"],
    "users" => ["julialang"],
    "languages" => ["en"],
    "include_retweets" => false,
    "include_replies" => true
)
```

#### Instagram
```julia
instagram_config = Dict(
    "hashtags" => ["julia", "programming"],
    "users" => ["julialang"],
    "include_videos" => true,
    "include_carousel" => true
)
```

#### Discord
```julia
discord_config = Dict(
    "channels" => ["123456789012345678"],
    "guilds" => ["987654321098765432"],
    "include_attachments" => false,
    "include_embeds" => true
)
```

#### Telegram
```julia
telegram_config = Dict(
    "chats" => ["-1001234567890"],
    "include_media" => false,
    "include_forwards" => false
)
```

#### YouTube
```julia
youtube_config = Dict(
    "keywords" => ["julia programming"],
    "channels" => ["UC8IuVQvVdDWqh6fXHdWBlEQ"],
    "include_comments" => false
)
```

## Environment Variables

Set these environment variables for API access:

```bash
# Reddit
export REDDIT_CLIENT_ID="your_client_id"
export REDDIT_CLIENT_SECRET="your_client_secret"
export REDDIT_ACCESS_TOKEN="your_access_token"
export REDDIT_REFRESH_TOKEN="your_refresh_token"

# Twitter
export TWITTER_BEARER_TOKEN="your_bearer_token"

# Instagram
export INSTAGRAM_ACCESS_TOKEN="your_access_token"

# Discord
export DISCORD_BOT_TOKEN="your_bot_token"

# Telegram
export TELEGRAM_BOT_TOKEN="your_bot_token"

# YouTube
export YOUTUBE_API_KEY="your_api_key"
```

## Usage Examples

### Starting a Crawler

```julia
using JuliaOS.Crawlers

# Create a Reddit crawler
reddit_crawler = RedditCrawler("reddit_001", Dict(
    "subreddits" => ["programming"],
    "keywords" => ["julia"],
    "max_posts" => 100
))

# Start the crawler
run(reddit_crawler)
```

### Testing with curl

Use the provided test script:

```bash
./test_crawlers.sh
```

Or test individual crawlers:

```bash
# Test Reddit crawler
curl -X POST http://localhost:8000/api/crawlers/reddit \
  -H "Content-Type: application/json" \
  -d '{
    "id": "reddit_test",
    "config": {
      "subreddits": ["programming"],
      "keywords": ["julia"],
      "max_posts": 50
    }
  }'

# Check status
curl -X GET http://localhost:8000/api/crawlers/status

# Stop crawler
curl -X POST http://localhost:8000/api/crawlers/stop \
  -H "Content-Type: application/json" \
  -d '{"crawler_ids": ["reddit_test"]}'
```

## Data Structures

Each crawler defines platform-specific data structures:

### RedditPost
```julia
struct RedditPost
    id::String
    subreddit::String
    title::String
    text::String
    url::String
    created_utc::DateTime
    score::Int
    num_comments::Int
    upvote_ratio::Float64
    awards::Int
    author_hash::String
    nsfw::Bool
    spoiler::Bool
    distinguished::String
end
```

### Tweet
```julia
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
```

### InstagramPost
```julia
struct InstagramPost
    id::String
    shortcode::String
    caption::String
    media_type::String
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
```

## Error Handling

Crawlers implement comprehensive error handling:

- **Authentication Errors**: Invalid tokens or credentials
- **Rate Limit Errors**: API quota exceeded
- **Permission Errors**: Insufficient access rights
- **Network Errors**: Connection timeouts and failures
- **Data Errors**: Malformed responses

Each error type triggers appropriate recovery mechanisms:

- Exponential backoff for rate limits
- Token refresh for authentication errors
- Resource rotation for permission errors
- Retry logic for network errors

## Privacy and Security

### Data Sanitization
- PII removal (phone numbers, emails, SSNs)
- URL anonymization
- User mention anonymization
- Location data filtering

### User Anonymization
- SHA-256 hashing of usernames
- Salt-based anonymization
- No storage of original identifiers

### Secure Storage
- Binary data compression
- IPFS integration for decentralized storage
- Encrypted data transmission

## Performance Considerations

### Rate Limiting
- Platform-specific rate limit handling
- Intelligent backoff strategies
- Request queuing and prioritization

### Resource Management
- Proxy rotation for load distribution
- User agent rotation for request diversity
- Connection pooling and reuse

### Scalability
- Configurable batch sizes
- Parallel processing capabilities
- Memory-efficient data structures

## Monitoring and Logging

### Status Reporting
- Real-time crawler status
- Performance metrics
- Error rate tracking
- Data collection statistics

### Logging
- Structured logging with JSON format
- Error classification and reporting
- Debug information for troubleshooting
- Audit trails for compliance

## Development and Testing

### Unit Testing
```julia
using Test

@testset "Reddit Crawler" begin
    crawler = RedditCrawler("test", Dict("subreddits" => ["test"]))
    @test crawler.id == "test"
    @test crawler.config["subreddits"] == ["test"]
end
```

### Integration Testing
```bash
# Run the test suite
julia --project=. test/runtests.jl

# Test specific crawler
julia --project=. test/test_reddit_crawler.jl
```

### Performance Testing
```julia
# Benchmark crawler performance
using BenchmarkTools

@btime run(reddit_crawler)
```

## Contributing

When adding new crawlers:

1. Follow the established pattern in existing crawlers
2. Implement all required methods (`run`, `error_count`, `compress`, etc.)
3. Add comprehensive error handling
4. Include data sanitization and anonymization
5. Write tests for new functionality
6. Update documentation

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- Create an issue on GitHub
- Check the documentation
- Review the test examples
- Consult the API documentation for each platform 