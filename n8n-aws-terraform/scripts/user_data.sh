#!/bin/bash
# user_data.sh
# Bootstrap script for EC2 to install Docker and run n8n with production best practices

set -e

# Install Docker if not present
if ! command -v docker &> /dev/null; then
  sudo apt-get update
  sudo apt-get install -y docker.io
fi

# Variables: use environment if set, otherwise use Terraform interpolation
DB_TYPE=${DB_TYPE:-postgresdb}
DB_POSTGRESDB_HOST=${DB_POSTGRESDB_HOST}
DB_POSTGRESDB_PORT=${DB_POSTGRESDB_PORT}
DB_POSTGRESDB_DATABASE=${DB_POSTGRESDB_DATABASE}
DB_POSTGRESDB_USER=${DB_POSTGRESDB_USER}
DB_POSTGRESDB_PASSWORD=${DB_POSTGRESDB_PASSWORD}
n8n_host=${n8n_host}
N8N_PORT=${N8N_PORT}
WEBHOOK_URL=${WEBHOOK_URL}

# Mount EBS volume for persistent n8n data (if not already mounted)
if ! mountpoint -q /mnt/n8n_data; then
  sudo mkdir -p /mnt/n8n_data
  sudo mount /dev/xvdf /mnt/n8n_data || true
fi
sudo chown -R 1000:1000 /mnt/n8n_data

# Remove any existing n8n container
sudo docker rm -f n8n 2>/dev/null || true

# Run n8n with persistent data and restart policy for resilience
sudo docker rm -f n8n
sudo docker run -d --restart unless-stopped --name n8n -p 5678:5678 \
  -e DB_TYPE=$DB_TYPE \
  -e DB_POSTGRESDB_HOST=$DB_POSTGRESDB_HOST \
  -e DB_POSTGRESDB_PORT=$DB_POSTGRESDB_PORT \
  -e DB_POSTGRESDB_DATABASE=$DB_POSTGRESDB_DATABASE \
  -e DB_POSTGRESDB_USER=$DB_POSTGRESDB_USER \
  -e DB_POSTGRESDB_PASSWORD=$DB_POSTGRESDB_PASSWORD \
  -e DB_POSTGRESDB_SSL_ENABLED=true \
  -e DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED=false \
  -e N8N_PORT=$N8N_PORT \
  -e N8N_HOST=$n8n_host \
  -e WEBHOOK_URL=$WEBHOOK_URL \
  -e N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
  -v /mnt/n8n_data:/home/node/.n8n \
  n8nio/n8n


# Log the status of the container startup
sleep 5
if sudo docker ps | grep -q n8n; then
  sudo docker ps
  echo "n8n Docker container started successfully." | sudo tee -a /var/log/n8n-docker.log
else
  echo "n8n Docker container failed to start." | sudo tee -a /var/log/n8n-docker.log
fi
