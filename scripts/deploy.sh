#!/bin/bash
# RStudio Server Deployment Script
# Automates the deployment process

set -e  # Exit on error

echo "======================================"
echo "RStudio Server Deployment"
echo "======================================"
echo ""

# Configuration
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/..
" && pwd)"
DATA_DIR="/data"
RSTUDIO_DIR="${DATA_DIR}/rstudio-server"
NGINX_CONF_DIR="${DATA_DIR}/docker/nginx/conf.d"
DOCKER_DIR="${DATA_DIR}/docker"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run with sudo or as root"
    exit 1
fi

# Function to create directory
create_dir() {
    if [ ! -d "$1" ]; then
        echo "Creating directory: $1"
        mkdir -p "$1"
    else
        echo "Directory exists: $1"
    fi
}

# Create required directories
echo "Step 1: Creating directory structure..."
create_dir "${RSTUDIO_DIR}/config"
create_dir "${RSTUDIO_DIR}/home"
create_dir "${RSTUDIO_DIR}/libs"
create_dir "${RSTUDIO_DIR}/logs"
create_dir "${NGINX_CONF_DIR}"

# Copy Dockerfile and configs
echo ""
echo "Step 2: Copying application files..."
cp -v "${REPO_DIR}/Dockerfile" "${RSTUDIO_DIR}/"
cp -v "${REPO_DIR}/config/"*.conf "${RSTUDIO_DIR}/config/" 2>/dev/null || echo "No config files found"

# Copy examples
echo ""
echo "Step 3: Copying example scripts..."
create_dir "${RSTUDIO_DIR}/examples"
cp -v "${REPO_DIR}/examples/"*.R "${RSTUDIO_DIR}/examples/" 2>/dev/null || echo "No example files found"

# Copy Nginx configuration
echo ""
echo "Step 4: Copying Nginx configuration..."
cp -v "${REPO_DIR}/nginx/rstudio.conf" "${NGINX_CONF_DIR}/"

# Update docker-compose.yml
echo ""
echo "Step 5: Checking docker-compose.yml..."
if [ -f "${DOCKER_DIR}/docker-compose.yml" ]; then
    if ! grep -q "rstudio-server" "${DOCKER_DIR}/docker-compose.yml"; then
        echo "Adding rstudio-server service to docker-compose.yml..."
        cat "${REPO_DIR}/docker-compose.service.yml" >> "${DOCKER_DIR}/docker-compose.yml"
    else
        echo "rstudio-server service already exists in docker-compose.yml"
    fi
else
    echo "Creating docker-compose.yml..."
    cp -v "${REPO_DIR}/docker-compose.service.yml" "${DOCKER_DIR}/docker-compose.yml"
fi

# Set permissions
echo ""
echo "Step 6: Setting permissions..."
chown -R 1000:1000 "${RSTUDIO_DIR}/home" 2>/dev/null || chown -R $SUDO_USER:$SUDO_USER "${RSTUDIO_DIR}/home"
chown -R $SUDO_USER:$SUDO_USER "${RSTUDIO_DIR}"
chmod -R 755 "${RSTUDIO_DIR}"

# Create environment file
echo ""
echo "Step 7: Creating environment file..."
if [ ! -f "${RSTUDIO_DIR}/.env" ]; then
    cp -v "${REPO_DIR}/.env.example" "${RSTUDIO_DIR}/.env"
    echo "⚠️  IMPORTANT: Edit ${RSTUDIO_DIR}/.env to change default password!"
else
    echo "Environment file already exists"
fi

# Build and start containers
echo ""
echo "Step 8: Building and starting Docker containers..."
cd "${DOCKER_DIR}"

# Build the image
echo "Building rstudio-server image..."
docker-compose build rstudio-server

# Start the service
echo "Starting rstudio-server service..."
docker-compose up -d rstudio-server

# Wait for service to be healthy
echo ""
echo "Waiting for service to be ready..."
sleep 15

# Test health endpoint
echo ""
echo "Step 9: Testing RStudio Server..."
for i in {1..10}; do
    if curl -f http://localhost:8787/ > /dev/null 2>&1; then
        echo "✓ RStudio Server is ready!"
        break
    else
        echo "Waiting for RStudio to be ready... (attempt $i/10)"
        sleep 3
    fi
    
    if [ $i -eq 10 ]; then
        echo "⚠ Warning: RStudio health check failed"
        echo "Check logs with: docker-compose logs rstudio-server"
    fi
done

# Restart Nginx to apply configuration
echo ""
echo "Step 10: Restarting Nginx..."
docker-compose restart nginx || echo "Note: Nginx restart failed or not running"

echo ""
echo "======================================"
echo "Deployment Complete!"
echo "======================================"
echo ""
echo "Access RStudio Server at:"
echo "  URL: http://your-domain.com/rstudio/"
echo "  Username: rstudio"
echo "  Password: (check ${RSTUDIO_DIR}/.env)"
echo ""
echo "Useful commands:"
echo "  View logs:    docker-compose logs -f rstudio-server"
echo "  Restart:      docker-compose restart rstudio-server"
echo "  Stop:         docker-compose stop rstudio-server"
echo "  Rebuild:      docker-compose build --no-cache rstudio-server"
echo ""
echo "⚠️  SECURITY REMINDER:"
echo "1. Change default password: ${RSTUDIO_DIR}/.env"
echo "2. Update Nginx config with your domain: ${NGINX_CONF_DIR}/rstudio.conf"
echo "3. Set up SSL with Let's Encrypt (see README.md)"
echo ""