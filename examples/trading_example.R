# Trading Analysis Example
# Author: RStudio Trading Template
# Date: 2026-03-04
# Purpose: Demonstrate basic trading analysis with quantmod and TTR

# Load required packages
library(quantmod)
library(TTR)
library(PerformanceAnalytics)

cat("\n=== Stock Trading Analysis Example ===\n\n")

# Configuration
symbol <- "AAPL"
start_date <- "2023-01-01"
end_date <- Sys.Date()

cat(paste("Analyzing", symbol, "from", start_date, "to", end_date, "\n\n"))

# 1. Download stock data
cat("Step 1: Downloading stock data...\n")
getSymbols(symbol, from = start_date, to = end_date, auto.assign = TRUE)
stock_data <- get(symbol)
cat("Data downloaded successfully!\n\n")

# 2. Calculate returns
cat("Step 2: Calculating returns...\n")
daily_returns <- dailyReturn(stock_data)
cat(paste("Total returns:", round(Return.cumulative(daily_returns) * 100, 2), "%\n\n"))

# 3. Technical indicators
cat("Step 3: Calculating technical indicators...\n")

# Simple Moving Averages
sma_20 <- SMA(Cl(stock_data), n = 20)
sma_50 <- SMA(Cl(stock_data), n = 50)
sma_200 <- SMA(Cl(stock_data), n = 200)

# RSI (Relative Strength Index)
rsi_14 <- RSI(Cl(stock_data), n = 14)

# MACD
macd <- MACD(Cl(stock_data), nFast = 12, nSlow = 26, nSig = 9)

# Bollinger Bands
bbands <- BBands(HLC(stock_data), n = 20, sd = 2)

cat("Indicators calculated successfully!\n\n")

# 4. Current signals
cat("Step 4: Current trading signals:\n")
current_price <- as.numeric(tail(Cl(stock_data), 1))
current_sma20 <- as.numeric(tail(sma_20, 1))
current_sma50 <- as.numeric(tail(sma_50, 1))
current_rsi <- as.numeric(tail(rsi_14, 1))

cat(paste("Current Price:", round(current_price, 2), "\n"))
cat(paste("SMA 20:", round(current_sma20, 2), "\n"))
cat(paste("SMA 50:", round(current_sma50, 2), "\n"))
cat(paste("RSI:", round(current_rsi, 2), "\n\n"))

# Trend analysis
if (current_sma20 > current_sma50) {
  cat("✅ Bullish trend (SMA 20 > SMA 50)\n")
} else {
  cat("❌ Bearish trend (SMA 20 < SMA 50)\n")
}

# RSI signal
if (current_rsi > 70) {
  cat("⚠️ RSI indicates overbought condition\n")
} else if (current_rsi < 30) {
  cat("⚠️ RSI indicates oversold condition\n")
} else {
  cat("✅ RSI in neutral zone\n")
}

cat("\n")

# 5. Performance metrics
cat("Step 5: Performance metrics:\n")
annual_returns <- Return.annualized(daily_returns)
sharpe_ratio <- SharpeRatio(daily_returns, Rf = 0.02/252)
max_dd <- maxDrawdown(daily_returns)
volatility <- sd(daily_returns) * sqrt(252)

cat(paste("Annualized Return:", round(annual_returns * 100, 2), "%\n"))
cat(paste("Sharpe Ratio:", round(sharpe_ratio, 2), "\n"))
cat(paste("Max Drawdown:", round(max_dd * 100, 2), "%\n"))
cat(paste("Annualized Volatility:", round(volatility * 100, 2), "%\n\n"))

# 6. Visualizations
cat("Step 6: Creating visualizations...\n")

# Chart 1: Price with SMAs
chartSeries(stock_data,
            name = paste(symbol, "- Price Chart with Moving Averages"),
            theme = "white",
            TA = NULL)
addSMA(n = 20, col = "blue")
addSMA(n = 50, col = "red")
addSMA(n = 200, col = "green")
addRSI(n = 14)
addMACD()
addBBands()

cat("\n✅ Analysis complete!\n")
cat("\nNext steps:\n")
cat("1. Modify the symbol variable to analyze different stocks\n")
cat("2. Adjust indicator parameters for your strategy\n")
cat("3. Implement entry/exit rules based on signals\n")
cat("4. Backtest your strategy (see portfolio_analysis.R)\n")