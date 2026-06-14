#!/bin/bash

echo "Starting Dev Server..."

# Verify ttyd exists
if ! command -v ttyd &> /dev/null; then
    echo "ttyd not found!"
    exit 1
fi

echo "ttyd found, starting on port ${PORT:-8080}..."

exec ttyd \
  --port ${PORT:-8080} \
  --credential admin:admin123 \
  --writable \
  --ping-interval 30 \
  --title "Dev Server - /root/main/arvin" \
  bash
