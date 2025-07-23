#!/bin/bash

URL_BASE="localhost:8052/api/v1"

echo " ### Agents at the start:"
curl -v "$URL_BASE/agents/"
echo ""

curl -v -X POST -H "Content-Type: application/json" -d "@data/create-agent.json" "$URL_BASE/agents/"

echo ""
echo " ### Agents after creation:"
curl -v "$URL_BASE/agents/"
echo ""

curl -v -X PUT -H "Content-Type: application/json" -d "@data/run-agent.json" "$URL_BASE/agents/telegram-agent"

echo ""
echo " ### Agents after state change:"
curl -v "$URL_BASE/agents/"
echo ""


echo " ### Logs at the start:"
curl -v "$URL_BASE/agents/telegram-agent/logs"
echo ""

curl -v -X POST -H "Content-Type: application/json" -d "@data/value.json" "$URL_BASE/agents/telegram-agent/webhook"

sleep 1

echo ""
echo " ### Logs after successful execution:"
curl -v "$URL_BASE/agents/telegram-agent/logs"
echo ""