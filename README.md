# RStudio Server Application - Production Ready

![RStudio](https://img.shields.io/badge/RStudio-Server-75AADB)
![R](https://img.shields.io/badge/R-4.4+-276DC3)
![Docker](https://img.shields.io/badge/Docker-Enabled-blue)
![Trading](https://img.shields.io/badge/Trading_Packages-Included-green)

## 🚀 Overview

A production-ready RStudio Server application with comprehensive trading and financial analysis packages pre-installed. Designed for quantitative trading, financial analysis, and data science workflows. Features Docker deployment with Nginx reverse proxy.

## ✨ Features

- **RStudio Server**: Full RStudio IDE in your browser
- **Trading Packages**: quantmod, TTR, PerformanceAnalytics, tidyquant, QuantTools
- **Data Science Stack**: tidyverse, data.table, plotly, shiny
- **Financial Tools**: xts, zoo, forecast, rugarch, PortfolioAnalytics
- **Docker Deployment**: Complete containerized setup
- **Nginx Reverse Proxy**: Secure access at /rstudio/ path
- **Production Ready**: Resource limits, health checks, logging
- **Persistent Sessions**: User data and packages preserved

## 📦 Pre-installed Trading Packages

### Core Trading
- **quantmod** - Financial data retrieval and charting
- **TTR** - Technical Trading Rules
- **PerformanceAnalytics** - Performance and risk analytics
- **tidyquant** - Tidy financial analysis
- **QuantTools** - Quantitative trading toolkit

### Time Series
- **xts** - Extensible time series
- **zoo** - S3 infrastructure for time series
- **forecast** - Forecasting functions
- **tseries** - Time series analysis

### Risk & Portfolio
- **PortfolioAnalytics** - Portfolio optimization
- **rugarch** - GARCH modeling
- **PerformanceAnalytics** - Risk metrics

### Data & Visualization
- **tidyverse** - Data manipulation suite
- **data.table** - Fast data manipulation
- **plotly** - Interactive graphics
- **ggplot2** - Static graphics
- **shiny** - Interactive web apps

## 📁 Architecture

```
/data/
├── docker/
│   ├── nginx/
│   │   └── conf.d/
│   │       └── rstudio.conf        # Nginx config
│   └── docker-compose.yml          # Main compose file
└── rstudio-server/                 # RStudio backend
    ├── Dockerfile
    ├── config/
    │   └── rserver.conf            # RStudio config
    ├── home/                       # User home directories
    └── libs/                       # Custom R libraries
```

## 🛠️ Installation

### Prerequisites

- Docker 24.0+
- Docker Compose 2.20+
- Minimum 4GB RAM
- 20GB free disk space

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/jessiorg/r-studio-app.git
   cd r-studio-app
   ```

2. **Run the deployment script**
   ```bash
   sudo chmod +x scripts/deploy.sh
   sudo ./scripts/deploy.sh
   ```

3. **Access RStudio Server**
   - URL: `http://your-domain.com/rstudio/`
   - Default credentials: `rstudio` / `rstudio123` (change immediately!)

### Manual Installation

1. **Set up directory structure**
   ```bash
   sudo mkdir -p /data/rstudio-server/{config,home,libs}
   sudo mkdir -p /data/docker/nginx/conf.d
   ```

2. **Copy files**
   ```bash
   sudo cp -r * /data/rstudio-server/
   sudo cp nginx/rstudio.conf /data/docker/nginx/conf.d/
   ```

3. **Configure environment**
   ```bash
   cd /data/rstudio-server
   cp .env.example .env
   nano .env  # Edit configuration
   ```

4. **Deploy**
   ```bash
   cd /data/docker
   docker-compose up -d rstudio-server
   docker-compose restart nginx
   ```

## 🌐 Usage

### Accessing RStudio

1. Navigate to: `http://your-domain.com/rstudio/`
2. Login with your credentials
3. Start analyzing!

### Example: Basic Trading Analysis

```r
# Load packages
library(quantmod)
library(TTR)
library(PerformanceAnalytics)

# Get stock data
getSymbols("AAPL", from = "2023-01-01")

# Calculate returns
returns <- dailyReturn(AAPL)

# Technical indicators
sma_20 <- SMA(Cl(AAPL), n = 20)
sma_50 <- SMA(Cl(AAPL), n = 50)
rsi <- RSI(Cl(AAPL), n = 14)

# Plot
chartSeries(AAPL, theme = "white")
addSMA(n = 20, col = "blue")
addSMA(n = 50, col = "red")
addRSI(n = 14)

# Performance analytics
charts.PerformanceSummary(returns)
table.AnnualizedReturns(returns)
maxDrawdown(returns)
```

### Example: Portfolio Analysis

```r
library(tidyquant)
library(PortfolioAnalytics)

# Get multiple stocks
tickers <- c("AAPL", "GOOGL", "MSFT", "AMZN")
prices <- tq_get(tickers, from = "2023-01-01")

# Calculate returns
returns <- prices %>%
  group_by(symbol) %>%
  tq_transmute(select = adjusted,
               mutate_fun = periodReturn,
               period = "daily")

# Portfolio weights
weights <- c(0.25, 0.25, 0.25, 0.25)

# Portfolio returns
portfolio_returns <- returns %>%
  tq_portfolio(assets_col = symbol,
               returns_col = daily.returns,
               weights = weights)

# Performance metrics
portfolio_returns %>%
  tq_performance(Ra = portfolio.returns,
                 performance_fun = table.AnnualizedReturns)
```

## 🔧 Configuration

### Environment Variables

**.env file:**
```bash
# RStudio Configuration
RSTUDIO_USER=rstudio
RSTUDIO_PASSWORD=rstudio123
RSTUDIO_PORT=8787

# Resource Limits
MEMORY_LIMIT=4G
CPU_LIMIT=4

# Paths
HOME_DIR=/data/rstudio-server/home
LIBS_DIR=/data/rstudio-server/libs

# Security
DISABLE_AUTH=false
AUTH_REQUIRED_USER_GROUP=rstudio-users
```

### RStudio Server Configuration

**config/rserver.conf:**
```conf
# Server Configuration
www-address=0.0.0.0
www-port=8787
rsession-which-r=/usr/local/bin/R

# Session timeout (minutes)
rsession-timeout-minutes=120

# Authentication
auth-required-user-group=rstudio-users
auth-minimum-user-id=500
```

### Custom R Libraries

Install additional packages:

```r
# In RStudio console
install.packages(c(
  "package1",
  "package2"
))

# Or from GitHub
devtools::install_github("user/package")
```

### Nginx Path Configuration

Modify `/data/docker/nginx/conf.d/rstudio.conf` for custom paths:

```nginx
location /rstudio/ {
    # Change to your preferred path
    rewrite ^/rstudio/(.*)$ /$1 break;
    proxy_pass http://rstudio-server:8787;
    ...
}
```

## 📊 Trading Use Cases

### 1. Algorithmic Trading
```r
library(quantmod)
library(QuantTools)

# Implement simple moving average crossover strategy
strategy <- function(symbol) {
  getSymbols(symbol)
  prices <- Cl(get(symbol))
  
  sma_fast <- SMA(prices, 20)
  sma_slow <- SMA(prices, 50)
  
  signal <- ifelse(sma_fast > sma_slow, 1, -1)
  returns <- ROC(prices) * Lag(signal)
  
  charts.PerformanceSummary(returns)
  return(Return.cumulative(returns))
}
```

### 2. Risk Management
```r
library(PerformanceAnalytics)

# Calculate risk metrics
VaR(returns, p = 0.95, method = "historical")
ES(returns, p = 0.95, method = "historical")
maxDrawdown(returns)
SharpeRatio(returns, Rf = 0.02/252)
```

### 3. Backtesting
```r
library(quantmod)
library(PerformanceAnalytics)

# Backtest a strategy
backtest <- function(symbols, start_date, end_date) {
  # Implementation here
  returns <- apply_strategy(symbols, start_date, end_date)
  
  table.AnnualizedReturns(returns)
  table.DownsideRisk(returns)
  charts.PerformanceSummary(returns)
}
```

## 🔒 Security

### Change Default Password

```bash
# Method 1: Environment variable
export RSTUDIO_PASSWORD=your_secure_password

# Method 2: In container
docker exec -it rstudio-server passwd rstudio
```

### Enable HTTPS

```bash
# Get SSL certificate
sudo certbot --nginx -d your-domain.com

# Update nginx config (see nginx/rstudio.conf)
```

### Restrict Access

```nginx
# In nginx config
location /rstudio/ {
    # IP whitelist
    allow 192.168.1.0/24;
    deny all;
    ...
}
```

## 📝 Monitoring & Logging

### View Logs
```bash
# Container logs
docker-compose logs -f rstudio-server

# RStudio logs
docker exec rstudio-server cat /var/log/rstudio/rserver.log

# Session logs
docker exec rstudio-server cat /var/log/rstudio/rsession.log
```

### Resource Monitoring
```bash
# Container stats
docker stats rstudio-server

# Memory usage
docker exec rstudio-server free -h

# Disk usage
docker exec rstudio-server df -h
```

## 🐛 Troubleshooting

### RStudio Won't Start

```bash
# Check logs
docker-compose logs rstudio-server

# Rebuild container
docker-compose build --no-cache rstudio-server
docker-compose up -d rstudio-server
```

### Can't Access via Browser

1. Check if container is running: `docker ps | grep rstudio`
2. Test direct access: `curl http://localhost:8787`
3. Check nginx config: `docker exec nginx nginx -t`
4. Restart nginx: `docker-compose restart nginx`

### Package Installation Fails

```r
# Check CRAN mirror
options(repos = c(CRAN = "https://cran.rstudio.com/"))

# Install with dependencies
install.packages("package", dependencies = TRUE)

# Install system dependencies (in container)
# docker exec -it rstudio-server bash
# apt-get update && apt-get install -y lib-name-dev
```

### Session Timeout

```conf
# In config/rserver.conf
rsession-timeout-minutes=240  # Increase timeout
```

## 🚀 Production Deployment

### 1. SSL/TLS Setup
```bash
sudo certbot --nginx -d your-domain.com
```

### 2. Firewall Configuration
```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 3. Backup Strategy
```bash
#!/bin/bash
# Backup user data and libraries
tar -czf rstudio-backup-$(date +%Y%m%d).tar.gz \
  /data/rstudio-server/home \
  /data/rstudio-server/libs
```

### 4. Regular Updates
```bash
# Update RStudio
cd /data/rstudio-server
git pull
docker-compose build --no-cache rstudio-server
docker-compose up -d rstudio-server
```

## 🔄 Updates & Maintenance

### Update R Packages

```r
# Update all packages
update.packages(ask = FALSE)

# Update specific package
install.packages("quantmod")
```

### Update RStudio Server

```bash
# Pull latest Dockerfile
git pull

# Rebuild
docker-compose build --no-cache rstudio-server
docker-compose up -d rstudio-server
```

## 📚 Documentation

- [RStudio Server Guide](https://docs.posit.co/ide/server-pro/)
- [quantmod Documentation](https://www.quantmod.com/)
- [Trading Strategies in R](https://www.r-bloggers.com/)
- [Financial Analysis with R](https://www.datacamp.com/)

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details

## 🙏 Acknowledgments

- [RStudio](https://www.rstudio.com/) - IDE platform
- [Rocker Project](https://www.rocker-project.org/) - Docker images
- [quantmod](https://github.com/joshuaulrich/quantmod) - Financial data
- [TTR](https://github.com/joshuaulrich/TTR) - Technical indicators

## 📧 Support

For issues and questions:
- GitHub Issues: [Create an issue](https://github.com/jessiorg/r-studio-app/issues)
- RStudio Community: [community.rstudio.com](https://community.rstudio.com/)

---

**Version**: 1.0.0  
**Last Updated**: March 4, 2026  
**Maintained by**: Organiser (@jessiorg)