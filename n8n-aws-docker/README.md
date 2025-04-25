# N8N Docker Deployment

This guide will help you set up and run N8N using Docker Compose for local development, testing, or as a base for production deployment on AWS EC2.

## Prerequisites
- Docker and Docker Compose installed ([Install Docker](https://docs.docker.com/get-docker/))
- (For production) PostgreSQL database available (e.g., AWS RDS)
- (Optional) Domain name and SSL setup for production

## 1. Clone the Repository
```
git clone <your-repo-url>
cd n8n-aws-docker
```

## 2. Configure Environment Variables

Copy the example below to a `.env` file and fill in your secrets and database connection info:

```env
# .env example
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=yourpassword
DB_POSTGRESDB_HOST=your-db-endpoint
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=n8n
DB_POSTGRESDB_PASSWORD=your-db-password
N8N_HOST=n8n.example.com
WEBHOOK_URL=https://n8n.example.com/
```

> **Tip:** Never commit your real .env to version control!

## 3. Start N8N
```
docker-compose up --build -d
```
- This will pull the latest n8n image, create a persistent volume, and start the service.
- Access N8N at [http://localhost:5678](http://localhost:5678) or your configured domain.

## 4. Stopping and Restarting
```
docker-compose stop   # Stop the service
# or
 docker-compose down  # Stop and remove containers/volumes
```

## 5. Logs and Troubleshooting
```
docker-compose logs -f
```
- For healthcheck, see the `docker-compose.yml` healthcheck section.

## 6. Production Recommendations
- Use a managed PostgreSQL database (e.g., AWS RDS)
- Use HTTPS (SSL) via a reverse proxy (Nginx, Traefik) or AWS ALB
- For scaling, see n8n docs on [queue mode](https://docs.n8n.io/hosting/scaling/) and add Redis
- Regularly back up the `n8n_data` volume

## 7. Customization
- You can add plugins or custom files by editing the Dockerfile and mounting additional volumes.
- For advanced scaling and security, see the official [n8n Docker docs](https://docs.n8n.io/hosting/docker/)

---

For more info, visit: [n8n Docs](https://docs.n8n.io/)
