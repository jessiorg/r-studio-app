# RStudio Server - Quick Start Guide

## 5-Minute Setup

### 1. Clone Repository
```bash
git clone https://github.com/jessiorg/r-studio-app.git
cd r-studio-app
```

### 2. Run Deployment Script
```bash
sudo chmod +x scripts/deploy.sh
sudo ./scripts/deploy.sh
```

### 3. Change Default Password
```bash
sudo nano /data/rstudio-server/.env
# Change RSTUDIO_PASSWORD to something secure

sudo docker-compose -f /data/docker/docker-compose.yml restart rstudio-server
```

### 4. Access RStudio
Open browser: `http://your-server-ip/rstudio/`

Login:
- Username: `rstudio`
- Password: (what you set in step 3)

## First Trading Analysis

In RStudio, run:

```r
# Open the example script
file.edit("~/trading/trading_example.R")

# Or run directly
source("~/trading/trading_example.R")
```

## Test Installation

```r
# Test packages
library(quantmod)
library(TTR)
library(PerformanceAnalytics)

# Quick test
getSymbols("AAPL")
chartSeries(AAPL)
```

## Common Commands

```bash
# View logs
sudo docker logs rstudio-server

# Restart service
sudo docker-compose -f /data/docker/docker-compose.yml restart rstudio-server

# Stop service
sudo docker-compose -f /data/docker/docker-compose.yml stop rstudio-server

# Access container shell
sudo docker exec -it rstudio-server bash
```

## Troubleshooting

**Can't access RStudio?**
```bash
# Check if running
sudo docker ps | grep rstudio

# Check logs
sudo docker logs rstudio-server

# Test direct access
curl http://localhost:8787
```

**Forgot password?**
```bash
# Reset in container
sudo docker exec -it rstudio-server passwd rstudio
```

**Need more memory?**
```bash
sudo nano /data/docker/docker-compose.yml
# Increase memory limit under rstudio-server service
sudo docker-compose restart rstudio-server
```

## Next Steps

1. Run example scripts in `~/trading/`
2. Install additional packages as needed
3. Set up SSL (see README.md)
4. Configure backups
5. Customize environment

For full documentation, see [README.md](README.md)