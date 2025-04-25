#!/bin/bash
# setup_env.sh
# Script to set up environment variables for N8N

# Example environment variables (customize as needed)
export N8N_BASIC_AUTH_ACTIVE=true
export N8N_BASIC_AUTH_USER=admin
export N8N_BASIC_AUTH_PASSWORD=admin
export DB_TYPE=postgresdb
export DB_POSTGRESDB_HOST=<RDS_ENDPOINT>
export DB_POSTGRESDB_DATABASE=n8n
export DB_POSTGRESDB_USER=n8n
export DB_POSTGRESDB_PASSWORD=<YOUR_PASSWORD>

# Add any other required environment variables below
