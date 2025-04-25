#!/bin/bash
# user_data.sh
# Bootstrap script for EC2 to install Docker and run N8N

# Install Docker
apt-get update
apt-get install -y docker.io

# Run N8N in Docker (placeholder, will be parameterized)
docker run -d --name n8n -p 5678:5678 n8nio/n8n
