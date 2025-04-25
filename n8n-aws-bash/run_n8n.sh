#!/bin/bash
# run_n8n.sh
# Script to run N8N in Docker using environment variables

# Load environment variables
source ./setup_env.sh

# Run N8N Docker container
sudo docker run -d \
  --name n8n \
  -p 5678:5678 \
  --env-file <(env | grep N8N_ ; env | grep DB_) \
  -v n8n_data:/home/node/.n8n \
  n8nio/n8n:latest

# To check logs:
# sudo docker logs -f n8n
