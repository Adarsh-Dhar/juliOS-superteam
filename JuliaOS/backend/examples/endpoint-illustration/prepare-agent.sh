#!/bin/bash

URL_BASE="localhost:8052/api/v1"

METHOD="PUT"


echo " ### Agents at the start:"
curl -v "$URL_BASE/agents/"
echo ""

curl -v -X POST -H "Content-Type: application/json" -d "@data/create-agent.json" "$URL_BASE/agents/"

echo ""
echo " ### Agents after creation:"
curl -v "$URL_BASE/agents/"
echo ""

curl -v -X PUT -H "Content-Type: application/json" -d "@data/run-agent.json" "$URL_BASE/agents/example-agent"

echo ""
echo " ### Agents after state change:"
curl -v "$URL_BASE/agents/"
echo ""
