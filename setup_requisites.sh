#!/bin/bash
# setup_requisites.sh
# Ensures all required tools are installed on your local machine for N8N AWS deployment
# Does NOT duplicate any code from n8n-aws-bash (which is for EC2 setup only)

set -e

echo -e "\033[0;32m\033[1m"
echo -e "N 8 N  +  A W S  \033[0m"
echo -e "\033[0m"

# Check for Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "[ERROR] Homebrew is not installed."
  read -p "Would you like to install Homebrew now? [y/N]: " install_brew
  if [[ "$install_brew" =~ ^[Yy]$ ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$($(brew --prefix)/bin/brew shellenv)"
  else
    echo "Please install Homebrew from https://brew.sh and re-run this script."
    exit 1
  fi
else
  echo "[OK] Homebrew is installed."
fi

# Check for AWS CLI
if ! command -v aws >/dev/null 2>&1; then
  echo "[ERROR] AWS CLI is not installed."
  read -p "Would you like to install AWS CLI with Homebrew? [y/N]: " install_aws
  if [[ "$install_aws" =~ ^[Yy]$ ]]; then
    brew install awscli
  else
    echo "Please install AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
  fi
else
  echo "[OK] AWS CLI is installed."
fi

# Check for Terraform
if ! command -v terraform >/dev/null 2>&1; then
  echo "[ERROR] Terraform is not installed."
  read -p "Would you like to install Terraform with Homebrew? [y/N]: " install_tf
  if [[ "$install_tf" =~ ^[Yy]$ ]]; then
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
  else
    echo "Please install Terraform: https://learn.hashicorp.com/tutorials/terraform/install-cli"
    exit 1
  fi
else
  echo "[OK] Terraform is installed."
fi

# Check for Docker
if ! command -v docker >/dev/null 2>&1; then
  echo "[ERROR] Docker is not installed."
  read -p "Would you like to install Docker with Homebrew? [y/N]: " install_docker
  if [[ "$install_docker" =~ ^[Yy]$ ]]; then
    brew install --cask docker
    echo "Please launch Docker Desktop from Applications and ensure it is running."
  else
    echo "Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
  fi
else
  echo "[OK] Docker is installed."
fi

# Check for Docker Compose
if ! command -v docker-compose >/dev/null 2>&1 && ! docker compose version >/dev/null 2>&1; then
  echo "[ERROR] Docker Compose is not installed. Please install it: https://docs.docker.com/compose/install/"
  exit 1
else
  echo "[OK] Docker Compose is installed."
fi

# Check AWS credentials
if ! aws sts get-caller-identity >/dev/null 2>&1; then
  echo "[ERROR] AWS credentials are not configured."
  read -p "Would you like to configure AWS credentials? [y/N]: " configure_aws
  if [[ "$configure_aws" =~ ^[Yy]$ ]]; then
    open "https://console.aws.amazon.com/iam/home?region=us-east-1#security_credential"
    echo "Please follow the instructions to create a new access key pair and save it to ~/.aws/credentials."
    exit 1
  else
    echo "Please follow the instructions to create a new access key pair and save it to ~/.aws/credentials."
    echo "1. Go to https://console.aws.amazon.com/iam/home?region=us-east-1#security_credential"
    echo "2. Click on 'Create New Access Key'"
    echo "3. Choose 'Create a new access key pair'"
    echo "4. Download the CSV file with the access key pair"
    echo "5. Save the file to ~/.aws/credentials"
    exit 1
  fi
else
  echo "[OK] AWS credentials are configured."
fi

# Success
echo -e "\033[0;32m\033[1m"
echo -e "\033[0;32m\033[1mN 8 N  P R E - R E Q U I S I T E S  R E A D Y  !  \033[0m"
echo -e "\033[0;32m\033[1m"
echo -e "\033[0m"
