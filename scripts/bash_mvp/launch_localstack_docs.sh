#!/bin/bash

echo -e "\n🚀 Starting LocalStack and Docsify..."

# Start LocalStack container
docker start localstack_main > /dev/null 2>&1
sleep 5

# Serve Docsify site
docsify serve docs &
sleep 2

# Launch browser to Docsify site
if command -v xdg-open > /dev/null; then
    xdg-open "http://localhost:3000"
elif command -v open > /dev/null; then
    open "http://localhost:3000"
else
    echo "Could not automatically open browser. Please visit http://localhost:3000 manually."
fi 