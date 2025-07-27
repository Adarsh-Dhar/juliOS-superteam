#!/bin/bash

# Test script for Analysis Agents via curl commands
echo "Testing Analysis Agents via API..."

# Base URL for the server
BASE_URL="http://localhost:8053/api/v1"

# Test 1: Create Sentiment Analyzer
echo -e "\n=== Test 1: Creating Sentiment Analyzer ==="
curl -X POST "$BASE_URL/agents" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "sentiment-analyzer-1",
    "type": "SENTIMENTANALYZER",
    "parameters": {
      "min_confidence": 0.6,
      "batch_size": 32
    }
  }'

echo -e "\n\n=== Test 2: Creating Trend Analyzer ==="
curl -X POST "$BASE_URL/agents" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "trend-analyzer-1",
    "type": "TRENDANALYZER", 
    "parameters": {
      "languages": ["english"],
      "min_trend_growth": 2.0,
      "topic_threshold": 0.15
    }
  }'

echo -e "\n\n=== Test 3: List All Agents ==="
curl -X GET "$BASE_URL/agents"

echo -e "\n\n=== Test 4: Create Another Sentiment Analyzer with Different Config ==="
curl -X POST "$BASE_URL/agents" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "sentiment-analyzer-2",
    "type": "SENTIMENTANALYZER",
    "parameters": {
      "min_confidence": 0.8,
      "batch_size": 64
    }
  }'

echo -e "\n\n=== Test 5: Create Another Trend Analyzer with Different Config ==="
curl -X POST "$BASE_URL/agents" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "trend-analyzer-2",
    "type": "TRENDANALYZER",
    "parameters": {
      "languages": ["english", "spanish"],
      "min_trend_growth": 1.5,
      "topic_threshold": 0.2
    }
  }'

echo -e "\n\n=== Test 6: Final List of All Agents ==="
curl -X GET "$BASE_URL/agents"

echo -e "\n\n=== Test 7: Ping Server ==="
curl -X GET "$BASE_URL/ping"

echo -e "\n\nAnalysis Agent API tests completed!" 