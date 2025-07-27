#!/bin/bash

# Test script for JuliaOS crawlers
# This script demonstrates how to test each crawler module

echo "=== JuliaOS Crawler Test Script ==="
echo ""

# Set up environment variables for testing
export REDDIT_CLIENT_ID="your_reddit_client_id"
export REDDIT_CLIENT_SECRET="your_reddit_client_secret"
export REDDIT_ACCESS_TOKEN="your_reddit_access_token"
export REDDIT_REFRESH_TOKEN="your_reddit_refresh_token"

export TWITTER_BEARER_TOKEN="your_twitter_bearer_token"

export INSTAGRAM_ACCESS_TOKEN="your_instagram_access_token"

export DISCORD_BOT_TOKEN="your_discord_bot_token"

export TELEGRAM_BOT_TOKEN="your_telegram_bot_token"

export YOUTUBE_API_KEY="your_youtube_api_key"

echo "1. Testing Reddit Crawler"
echo "------------------------"
curl -X POST http://localhost:8000/api/crawlers/reddit \
  -H "Content-Type: application/json" \
  -d '{
    "id": "reddit_crawler_001",
    "config": {
      "subreddits": ["programming", "technology"],
      "keywords": ["julia", "programming"],
      "max_posts": 100,
      "scrape_interval": 600,
      "time_filter": "day",
      "sort": "new"
    }
  }'

echo ""
echo "2. Testing Twitter Crawler"
echo "-------------------------"
curl -X POST http://localhost:8000/api/crawlers/twitter \
  -H "Content-Type: application/json" \
  -d '{
    "id": "twitter_crawler_001",
    "config": {
      "keywords": ["julia", "programming"],
      "hashtags": ["#JuliaLang", "#Programming"],
      "users": ["julialang"],
      "max_tweets": 500,
      "scrape_interval": 300,
      "include_retweets": false,
      "include_replies": true
    }
  }'

echo ""
echo "3. Testing Instagram Crawler"
echo "----------------------------"
curl -X POST http://localhost:8000/api/crawlers/instagram \
  -H "Content-Type: application/json" \
  -d '{
    "id": "instagram_crawler_001",
    "config": {
      "hashtags": ["julia", "programming", "coding"],
      "keywords": ["julia programming"],
      "max_posts": 200,
      "scrape_interval": 600,
      "include_videos": true,
      "include_carousel": true
    }
  }'

echo ""
echo "4. Testing Discord Crawler"
echo "-------------------------"
curl -X POST http://localhost:8000/api/crawlers/discord \
  -H "Content-Type: application/json" \
  -d '{
    "id": "discord_crawler_001",
    "config": {
      "channels": ["123456789012345678"],
      "guilds": ["987654321098765432"],
      "keywords": ["julia", "help"],
      "max_messages": 500,
      "scrape_interval": 300,
      "include_attachments": false,
      "include_embeds": true
    }
  }'

echo ""
echo "5. Testing Telegram Crawler"
echo "---------------------------"
curl -X POST http://localhost:8000/api/crawlers/telegram \
  -H "Content-Type: application/json" \
  -d '{
    "id": "telegram_crawler_001",
    "config": {
      "chats": ["-1001234567890"],
      "keywords": ["julia", "programming"],
      "max_messages": 300,
      "scrape_interval": 300,
      "include_media": false,
      "include_forwards": false
    }
  }'

echo ""
echo "6. Testing YouTube Crawler"
echo "--------------------------"
curl -X POST http://localhost:8000/api/crawlers/youtube \
  -H "Content-Type: application/json" \
  -d '{
    "id": "youtube_crawler_001",
    "config": {
      "keywords": ["julia programming", "julia tutorial"],
      "channels": ["UC8IuVQvVdDWqh6fXHdWBlEQ"],
      "max_videos": 100,
      "scrape_interval": 600,
      "include_comments": false
    }
  }'

echo ""
echo "7. Get Crawler Status"
echo "--------------------"
curl -X GET http://localhost:8000/api/crawlers/status

echo ""
echo "8. Stop All Crawlers"
echo "-------------------"
curl -X POST http://localhost:8000/api/crawlers/stop \
  -H "Content-Type: application/json" \
  -d '{
    "crawler_ids": ["reddit_crawler_001", "twitter_crawler_001", "instagram_crawler_001", "discord_crawler_001", "telegram_crawler_001", "youtube_crawler_001"]
  }'

echo ""
echo "=== Test Complete ==="
echo ""
echo "Note: Replace the placeholder tokens with actual API credentials"
echo "before running these tests in a real environment." 