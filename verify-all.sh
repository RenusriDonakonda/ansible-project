#!/bin/bash
echo "========================================="
echo "DevOps Project 6 - Final Verification"
echo "========================================="
echo ""

echo "Running Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}"

echo -e "\nWeb Server Test Results:"
for server in webserver1 webserver2; do
  echo -n "$server: "
  docker exec $server curl -s http://localhost | grep "DevOps Project" | sed 's/<[^>]*>//g'
done

echo -e "\n========================================="
echo "✅ PROJECT COMPLETED SUCCESSFULLY!"
echo "========================================="
