#!/bin/bash

URL_BASE="localhost:8052/api/v1"

METHOD="PUT"


echo " ### Logs at the start:"
curl -v "$URL_BASE/agents/example-agent/logs"
echo ""

curl -v -X POST -H "Content-Type: application/json" -d "@data/no-value.json" "$URL_BASE/agents/example-agent/webhook"

sleep 1

echo ""
echo " ### Logs after failed execution:"
curl -v "$URL_BASE/agents/example-agent/logs"
echo ""

curl -v -X POST -H "Content-Type: application/json" -d "@data/value.json" "$URL_BASE/agents/example-agent/webhook"

sleep 1

echo ""
echo " ### Logs after successful execution:"
curl -v "$URL_BASE/agents/example-agent/logs"
echo ""

