#!/bin/sh
# Custom health check script

# Check if npm run preview is running
if ps aux | grep 'npm run preview' | grep -v grep; then
  exit 0 # Process found, container is healthy
else
  exit 1 # Process not found, container is not healthy
fi