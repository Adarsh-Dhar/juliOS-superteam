#!/bin/bash

echo "=== Telegram Crawler Test Script ==="
echo ""

# Set up environment variables for testing
export TELEGRAM_BOT_TOKEN="your_telegram_bot_token"

echo "1. Creating Telegram Crawler"
echo "---------------------------"
curl -X POST http://localhost:8053/api/v1/agents \
  -H "Content-Type: application/json" \
  -d '{
    "name": "telegram_crawler_001",
    "type": "TELEGRAMCRAWLER",
    "parameters": {
      "chats": ["YOUR_CHAT_ID"],
      "keywords": ["julia", "programming", "help"],
      "hashtags": ["#julia", "#programming"],
      "max_messages": 100,
      "scrape_interval": 60,
      "include_media": false,
      "include_forwards": false
    }
  }'

echo ""
echo "2. Starting Telegram Crawler"
echo "---------------------------"
curl -X POST http://localhost:8053/api/v1/agents/telegram_crawler_001/start

echo ""
echo "3. Checking Agent Status"
echo "----------------------"
curl -X GET http://localhost:8053/api/v1/agents/telegram_crawler_001

echo ""
echo "4. Getting Agent Memory (Last Scrape Data)"
echo "----------------------------------------"
curl -X GET http://localhost:8053/api/v1/agents/telegram_crawler_001/memory/last_scrape

echo ""
echo "5. List All Agents"
echo "----------------"
curl -X GET http://localhost:8053/api/v1/agents

echo ""
echo "=== Test Complete ==="
echo ""
echo "Note: Replace 'your_telegram_bot_token' and 'YOUR_CHAT_ID' with actual values"
echo "Monitor the server logs to see crawling activity:"
echo "  INFO: Telegram crawler telegram_crawler_001 started"
echo "  INFO: Crawler telegram_crawler_001 scraped X messages successfully"
echo "  INFO: Stored data with CID: bafybeib..." 