# N8N AWS Bash Scripts

This folder contains bash scripts to help set up your EC2 instance for running N8N after provisioning your infrastructure with Terraform.

## When to Use These Scripts
After you have deployed your AWS infrastructure (EC2, RDS, networking, etc.) with Terraform, use these scripts to:
- Install all necessary dependencies (Docker, Node.js)
- Configure environment variables for N8N and database
- Start the N8N engine in Docker with production settings

## Step-by-Step Usage

### 1. SSH into your EC2 Instance
```
ssh ubuntu@<your-ec2-public-dns>
```

### 2. Install Prerequisites
This script installs Docker, Node.js, and other required packages:
```
bash install_prerequisites.sh
```
- **Why:** N8N runs in Docker, and some N8N features require Node.js. This ensures your EC2 is ready to run N8N containers securely and efficiently.

### 3. Configure Environment Variables
Edit `setup_env.sh` to add your secrets and database connection info:
```
nano setup_env.sh
```
- **Why:** Environment variables are the standard way to securely configure N8N (auth, DB, host, etc.).

### 4. Source Environment Variables
```
source setup_env.sh
```
- **Why:** Loads your configuration into the shell so the next script can use them.

### 5. Run N8N in Docker
```
bash run_n8n.sh
```
- **Why:** This script runs the official N8N Docker container with your environment variables and persistent storage.

### 6. Verify N8N is Running
```
docker ps
```
Visit `http://<your-ec2-public-dns>:5678` or your configured domain to access N8N.

## Advanced/Production Tips
- For HTTPS, use a reverse proxy (Nginx, Traefik) or AWS ALB in front of N8N.
- For scaling, see n8n docs on [queue mode](https://docs.n8n.io/hosting/scaling/) and add Redis.
- Regularly back up the Docker volume or sync `/home/node/.n8n` to S3.
- Always keep your secrets and credentials secure.

---

These scripts are modular and can be used as-is or integrated into EC2 user_data for full automation.
