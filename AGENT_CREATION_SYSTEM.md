# Agent Creation System Documentation

## Overview

The agent creation system integrates the Julia backend with the frontend campaign creation to automatically create and deploy agents when a campaign is created. The system supports multiple types of agents including crawlers, analyzers, and consensus agents.

## Architecture

### Frontend Components

#### Campaign Creation API (`frontend/app/api/campaigns/route.ts`)
- **Purpose**: Handles campaign creation and triggers agent creation
- **Key Functions**:
  - `createCampaignAgents()`: Creates agents using Julia backend
  - Agent type mapping for different platforms
  - Error handling and logging

#### Agent Types Supported

##### Crawler Agents
- **TwitterCrawler**: Monitors Twitter for keywords and hashtags
- **RedditCrawler**: Scrapes Reddit posts and comments
- **DiscordCrawler**: Monitors Discord channels and messages
- **TelegramCrawler**: Crawls Telegram channels and groups
- **InstagramCrawler**: Monitors Instagram posts and hashtags
- **YouTubeCrawler**: Scrapes YouTube videos and comments

##### Analysis Agents
- **SentimentAnalyzer**: Analyzes sentiment of collected content
- **TrendAnalyzer**: Identifies trends and patterns in data

##### Consensus Agents
- **ConsensusCoordinator**: Coordinates multiple consensus agents for verification

### Julia Backend Components

#### Agent Modules (`JuliaOS/julia/src/agents/`)

##### Crawler Modules
- **`crawlers/twitter.jl`**: Twitter API integration
- **`crawlers/reddit.jl`**: Reddit API integration
- **`crawlers/discord.jl`**: Discord Bot API integration
- **`crawlers/telegram.jl`**: Telegram Bot API integration
- **`crawlers/instagram.jl`**: Instagram Graph API integration
- **`crawlers/youtube.jl`**: YouTube Data API integration

##### Analysis Modules
- **`analysis/sentiment.jl`**: Sentiment analysis using LLMs
- **`analysis/trend.jl`**: Trend analysis and pattern recognition

##### Consensus Modules
- **`consensusVerifier.jl`**: Individual consensus agents with personality traits
- **`ConsensusSwarm.jl`**: Swarm coordination for consensus verification

#### Server Integration (`JuliaOS/julia/src/juliaos_server.jl`)
- **Agent Registry**: Registers all custom agent types
- **API Endpoints**: Handles agent creation requests
- **Type Mapping**: Maps frontend agent types to Julia types

## Agent Creation Flow

### 1. Campaign Creation
```typescript
// Frontend sends campaign data
const campaignData = {
  name: "Test Campaign",
  hashtag: "test_campaign",
  metadata: {
    platforms: ["twitter", "reddit"],
    keywords: ["test", "example"],
    hashtags: ["#test"],
    crawlerAgents: ["twitter.jl", "reddit.jl"],
    consensusAgentCount: 3,
    fixedAnalyzers: ["sentiment_analyzer", "trend_analyzer"]
  }
}
```

### 2. Agent Creation Process
```typescript
// Backend creates agents for the campaign
const { createdAgents, errors } = await createCampaignAgents(campaignId, metadata);
```

### 3. Julia Backend Integration
```julia
# Julia server receives agent creation request
POST /api/v1/agents
{
  "name": "campaign_id_twitter.jl",
  "type": "TWITTERCRAWLER",
  "status": "ACTIVE",
  "parameters": {
    "campaignId": "campaign_id",
    "platform": "twitter",
    "keywords": ["test", "example"],
    "hashtags": ["#test"]
  }
}
```

## Agent Configuration

### Crawler Agent Configuration
```typescript
const agentConfig = {
  campaignId: string,
  platform: string,
  keywords: string[],
  hashtags: string[],
  spamThreshold: number,
  sentimentThreshold: number,
  scrapeInterval: number,
  maxPosts: number,
  region: string
}
```

### Analysis Agent Configuration
```typescript
const analyzerConfig = {
  campaignId: string,
  model: string,
  threshold: number,
  analysisType: string,
  llm_config: {
    provider: string,
    model: string,
    temperature: number
  }
}
```

### Consensus Agent Configuration
```typescript
const consensusConfig = {
  campaignId: string,
  agentIndex: number,
  totalConsensusAgents: number,
  scoringMetrics: string[],
  votingWeight: number,
  consensusThreshold: number,
  personality: {
    bot_skepticism: number,
    manipulation_sensitivity: number,
    authenticity_optimism: number,
    novelty_preference: number,
    conformity_bias: number,
    risk_aversion: number
  }
}
```

## Agent Types and Capabilities

### Crawler Agents

#### TwitterCrawler
- **API**: Twitter API v2
- **Capabilities**: 
  - Search tweets by keywords and hashtags
  - Monitor specific users
  - Filter by language and content type
  - Rate limit handling
- **Data Collected**: Tweets, retweets, replies, engagement metrics

#### RedditCrawler
- **API**: Reddit API
- **Capabilities**:
  - Monitor subreddits
  - Search posts by keywords
  - Collect comments and engagement
  - Handle rate limits
- **Data Collected**: Posts, comments, upvotes, awards

#### DiscordCrawler
- **API**: Discord Bot API
- **Capabilities**:
  - Monitor specific channels
  - Collect messages and reactions
  - Handle bot permissions
- **Data Collected**: Messages, reactions, user mentions

#### TelegramCrawler
- **API**: Telegram Bot API
- **Capabilities**:
  - Monitor channels and groups
  - Collect messages and media
  - Handle bot token authentication
- **Data Collected**: Messages, media, forwards, replies

#### InstagramCrawler
- **API**: Instagram Graph API
- **Capabilities**:
  - Monitor hashtags
  - Collect posts and engagement
  - Handle API quotas
- **Data Collected**: Posts, likes, comments, hashtags

#### YouTubeCrawler
- **API**: YouTube Data API v3
- **Capabilities**:
  - Search videos by keywords
  - Monitor channels
  - Collect video metadata
- **Data Collected**: Videos, views, likes, comments, duration

### Analysis Agents

#### SentimentAnalyzer
- **Purpose**: Analyze sentiment of collected content
- **Capabilities**:
  - Sentiment scoring
  - Emotion detection
  - Threshold-based alerts
- **LLM Integration**: GPT-4, Claude, or other providers

#### TrendAnalyzer
- **Purpose**: Identify trends and patterns
- **Capabilities**:
  - Pattern recognition
  - Trend detection
  - Anomaly identification
- **Output**: Trend reports and alerts

### Consensus Agents

#### ConsensusCoordinator
- **Purpose**: Coordinate multiple consensus agents
- **Capabilities**:
  - Agent swarm management
  - Voting coordination
  - Result aggregation
- **Personality Traits**: Each agent has unique personality traits for diverse perspectives

## Error Handling and Resilience

### Frontend Error Handling
```typescript
// Graceful degradation when Julia backend is unavailable
try {
  const juliaAgent = await createJuliaAgent(agentData);
  // Store in database with Julia backend reference
} catch (error) {
  // Create agent in database only
  console.warn('Julia backend unavailable, creating database-only agent');
}
```

### Julia Backend Error Handling
```julia
# Rate limit handling
function handle_rate_limits(response::HTTP.Response)
    remaining = tryparse(Int, HTTP.header(response, "X-RateLimit-Remaining", "100"))
    if remaining < 10
        sleep(60)  # Wait 1 minute
    end
end

# Exponential backoff
backoff = min(2^(error_count(agent)) * 60, 3600)
```

## Security and Privacy

### Data Anonymization
```julia
# Anonymize user data
function anonymize_author(user_id::String, username::String)
    salt = Vault.get_global_salt()
    return bytes2hex(sha256("$username$salt"))
end
```

### PII Removal
```julia
# Remove sensitive information
function sanitize_text(text::String)
    text = replace(text, r"@\w+" => "@[USER]")
    text = replace(text, r"http\S+" => "[URL]")
    text = replace(text, r"\b\d{3}[-.]?\d{3}[-.]?\d{4}\b" => "[PHONE]")
    return text
end
```

## Monitoring and Metrics

### Agent Metrics
- **Success Rate**: Percentage of successful scrapes
- **Error Count**: Number of errors per agent
- **Processing Time**: Time to process content
- **Data Volume**: Amount of data collected

### Campaign Metrics
- **Total Agents**: Number of agents created
- **Agent Types**: Distribution of agent types
- **Creation Errors**: Number of failed agent creations

## Deployment and Configuration

### Environment Variables
```bash
# Julia backend configuration
JULIA_API_BASE=http://localhost:8000/api/v1

# API credentials (stored in Vault)
TWITTER_BEARER_TOKEN=xxx
REDDIT_CLIENT_ID=xxx
DISCORD_BOT_TOKEN=xxx
TELEGRAM_BOT_TOKEN=xxx
INSTAGRAM_ACCESS_TOKEN=xxx
YOUTUBE_API_KEY=xxx
```

### Agent Registration
```julia
# Register all agent types
register_custom_agent_type("TWITTERCRAWLER", TwitterCrawler)
register_custom_agent_type("REDDITCRAWLER", RedditCrawler)
register_custom_agent_type("DISCORDCRAWLER", DiscordCrawler)
register_custom_agent_type("TELEGRAMCRAWLER", TelegramCrawler)
register_custom_agent_type("INSTAGRAMCRAWLER", InstagramCrawler)
register_custom_agent_type("YOUTUBECRAWLER", YouTubeCrawler)
register_custom_agent_type("SENTIMENTANALYZER", SentimentAgent)
register_custom_agent_type("TRENDANALYZER", TrendAgent)
register_custom_agent_type("CONSENSUSCOORDINATOR", ConsensusSwarm.ConsensusCoordinator)
```

## Usage Examples

### Creating a Campaign with Multiple Platforms
```typescript
const campaignData = {
  name: "Brand Monitoring Campaign",
  hashtag: "brand_monitoring_2024",
  metadata: {
    platforms: ["twitter", "reddit", "discord"],
    keywords: ["brand_name", "product"],
    hashtags: ["#brand", "#product"],
    crawlerAgents: ["twitter.jl", "reddit.jl", "discord.jl"],
    consensusAgentCount: 5,
    spamThreshold: 15,
    sentimentThreshold: 30
  }
}
```

### Agent Creation Response
```json
{
  "id": "campaign-uuid",
  "name": "Brand Monitoring Campaign",
  "agentCreation": {
    "createdAgents": 10,
    "errors": 0,
    "agentDetails": [
      {"id": "agent-1", "name": "campaign_twitter.jl", "type": "TWITTERCRAWLER"},
      {"id": "agent-2", "name": "campaign_reddit.jl", "type": "REDDITCRAWLER"},
      {"id": "agent-3", "name": "campaign_discord.jl", "type": "DISCORDCRAWLER"},
      {"id": "agent-4", "name": "campaign_sentiment_analyzer", "type": "SENTIMENTANALYZER"},
      {"id": "agent-5", "name": "campaign_trend_analyzer", "type": "TRENDANALYZER"},
      {"id": "agent-6", "name": "campaign_consensus_agent_1", "type": "CONSENSUSCOORDINATOR"},
      {"id": "agent-7", "name": "campaign_consensus_agent_2", "type": "CONSENSUSCOORDINATOR"},
      {"id": "agent-8", "name": "campaign_consensus_agent_3", "type": "CONSENSUSCOORDINATOR"},
      {"id": "agent-9", "name": "campaign_consensus_agent_4", "type": "CONSENSUSCOORDINATOR"},
      {"id": "agent-10", "name": "campaign_consensus_agent_5", "type": "CONSENSUSCOORDINATOR"}
    ]
  }
}
```

## Future Enhancements

### Planned Features
1. **Dynamic Agent Scaling**: Automatically adjust agent count based on workload
2. **Advanced Analytics**: More sophisticated trend and pattern analysis
3. **Multi-language Support**: Support for content in multiple languages
4. **Real-time Alerts**: Instant notifications for critical events
5. **Agent Learning**: Agents that improve over time based on performance

### Integration Opportunities
1. **Blockchain Integration**: Store agent results on blockchain for immutability
2. **AI/ML Models**: Integration with custom ML models for analysis
3. **Third-party APIs**: Support for additional social media platforms
4. **Dashboard Integration**: Real-time monitoring dashboard for campaigns

## Conclusion

The agent creation system provides a comprehensive solution for automatically creating and deploying agents when campaigns are created. The system is designed to be scalable, resilient, and secure, with support for multiple social media platforms and analysis types. The integration between the frontend and Julia backend ensures seamless agent creation and management. 