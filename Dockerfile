# RStudio Server Dockerfile with Trading Packages
# Based on rocker/rstudio with additional financial analysis tools
# Optimized for production deployment

FROM rocker/rstudio:4.4.0

# Metadata
LABEL maintainer="Organiser <jessiorg@github.com>"
LABEL description="RStudio Server with trading and financial analysis packages"
LABEL version="1.0.0"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# Install system dependencies for financial packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build tools
    build-essential \
    gfortran \
    # Math libraries
    libopenblas-dev \
    liblapack-dev \
    libblas-dev \
    # XML/HTTP
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    # Database drivers
    libpq-dev \
    libmariadb-dev \
    # Graphics
    libcairo2-dev \
    libxt-dev \
    # Additional utilities
    git \
    wget \
    curl \
    vim \
    nano \
    htop \
    && rm -rf /var/lib/apt/lists/*

# Install R packages for trading and financial analysis
RUN install2.r --error --skipinstalled \
    # Core trading packages
    quantmod \
    TTR \
    PerformanceAnalytics \
    tidyquant \
    QuantTools \
    # Time series
    xts \
    zoo \
    forecast \
    tseries \
    # Portfolio management
    PortfolioAnalytics \
    rugarch \
    # Data manipulation
    tidyverse \
    data.table \
    lubridate \
    # Visualization
    ggplot2 \
    plotly \
    ggthemes \
    # Financial data
    Quandl \
    alphavantager \
    # API development
    shiny \
    shinydashboard \
    # Database
    DBI \
    RPostgreSQL \
    RMariaDB \
    # Development tools
    devtools \
    usethis \
    roxygen2 \
    testthat \
    # Utilities
    httr \
    jsonlite \
    readr \
    writexl \
    openxlsx \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Install additional trading packages from GitHub
RUN R -e "devtools::install_github('braverock/FinancialInstrument')" && \
    R -e "devtools::install_github('braverock/blotter')" && \
    rm -rf /tmp/downloaded_packages/

# Create directories for user data and libraries
RUN mkdir -p /home/rstudio/workspace && \
    mkdir -p /home/rstudio/trading && \
    mkdir -p /home/rstudio/data && \
    mkdir -p /usr/local/lib/R/site-library-custom && \
    chown -R rstudio:rstudio /home/rstudio && \
    chmod -R 755 /home/rstudio

# Copy RStudio configuration
COPY config/rserver.conf /etc/rstudio/rserver.conf
COPY config/rsession.conf /etc/rstudio/rsession.conf

# Create sample trading scripts
COPY examples/trading_example.R /home/rstudio/trading/
COPY examples/portfolio_analysis.R /home/rstudio/trading/
RUN chown -R rstudio:rstudio /home/rstudio/trading

# Set working directory
WORKDIR /home/rstudio

# Expose RStudio port
EXPOSE 8787

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8787/ || exit 1

# Default command (from base image)
CMD ["/init"]