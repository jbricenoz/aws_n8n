#!/bin/bash
# set_n8n_env.sh
# Script to export n8n environment variables for manual use in the EC2 instance shell
sudo apt-get update && sudo apt-get install -y postgresql-client
psql "host=n8n-db.co6klhd9rofv.us-west-2.rds.amazonaws.com port=5432 dbname=postgres user=n8nuser password=your-secure-password sslmode=require"

\du
\l

SELECT usename FROM pg_user;
\c n8n
\du


CREATE USER n8nadmin WITH PASSWORD 'changeme123';

GRANT ALL PRIVILEGES ON DATABASE n8n TO n8nadmin;


ALTER USER n8nadmin WITH PASSWORD 'changeme123';

CREATE DATABASE n8n OWNER n8nadmin;

psql "host=n8n-db.co6klhd9rofv.us-west-2.rds.amazonaws.com port=5432 dbname=n8n user=n8nadmin password=changeme123 sslmode=require"

-- Make n8nadmin the owner of all tables and sequences in public
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' LOOP
    EXECUTE 'ALTER TABLE public.' || quote_ident(r.tablename) || ' OWNER TO n8nadmin;';
  END LOOP;
  FOR r IN SELECT sequence_name FROM information_schema.sequences WHERE sequence_schema = 'public' LOOP
    EXECUTE 'ALTER SEQUENCE public.' || quote_ident(r.sequence_name) || ' OWNER TO n8nadmin;';
  END LOOP;
END;
$$;

-- Grant all privileges on schema, tables, and sequences
GRANT ALL ON SCHEMA public TO n8nadmin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO n8nadmin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO n8nadmin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO n8nadmin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO n8nadmin;

sudo docker rm -f n8n

sudo -E bash docker.sh

sudo docker logs n8n

export DB_TYPE=postgresdb
export DB_POSTGRESDB_SSL_ENABLED=true
export DB_POSTGRESDB_HOST="n8n-db.co6klhd9rofv.us-west-2.rds.amazonaws.com"
export DB_POSTGRESDB_PORT=5432
export DB_POSTGRESDB_DATABASE="n8n"
export DB_POSTGRESDB_USER="n8nadmin"
export DB_POSTGRESDB_PASSWORD="changeme123"
export n8n_host="n8n.modesignstudio.co"
export WEBHOOK_URL="n8n.modesignstudio.co"
export N8N_PORT=5678

echo "n8n environment variables set for this shell."
