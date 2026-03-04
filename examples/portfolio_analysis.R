# Portfolio Analysis Example
# Author: RStudio Trading Template
# Date: 2026-03-04
# Purpose: Demonstrate portfolio construction and analysis

# Load required packages
library(tidyquant)
library(PerformanceAnalytics)
library(PortfolioAnalytics)
library(ggplot2)

cat("\n=== Portfolio Analysis Example ===\n\n")

# Configuration
tickers <- c("AAPL", "GOOGL", "MSFT", "AMZN")
start_date <- "2023-01-01"
end_date <- Sys.Date()

cat(paste("Analyzing portfolio:", paste(tickers, collapse = ", "), "\n"))
cat(paste("Period:", start_date, "to", end_date, "\n\n"))

# 1. Download price data
cat("Step 1: Downloading price data...\n")
prices <- tq_get(tickers,
                 from = start_date,
                 to = end_date,
                 get = "stock.prices")
cat("Data downloaded successfully!\n\n")

# 2. Calculate individual returns
cat("Step 2: Calculating returns...\n")
returns <- prices %>%
  group_by(symbol) %>%
  tq_transmute(select = adjusted,
               mutate_fun = periodReturn,
               period = "daily",
               col_rename = "returns")
cat("Returns calculated!\n\n")

# 3. Equal weight portfolio
cat("Step 3: Creating equal-weight portfolio...\n")
equal_weights <- rep(1/length(tickers), length(tickers))
names(equal_weights) <- tickers

cat("Portfolio weights:\n")
for (i in 1:length(equal_weights)) {
  cat(paste("  ", names(equal_weights)[i], ":",
            round(equal_weights[i] * 100, 2), "%\n"))
}
cat("\n")

# Calculate portfolio returns
portfolio_returns <- returns %>%
  tq_portfolio(assets_col = symbol,
               returns_col = returns,
               weights = equal_weights,
               col_rename = "portfolio_returns")

# 4. Performance metrics
cat("Step 4: Calculating performance metrics...\n\n")

# Portfolio metrics
portfolio_metrics <- portfolio_returns %>%
  tq_performance(Ra = portfolio_returns,
                 performance_fun = table.AnnualizedReturns)

cat("Portfolio Performance:\n")
print(portfolio_metrics)
cat("\n")

# Risk metrics
risk_metrics <- portfolio_returns %>%
  tq_performance(Ra = portfolio_returns,
                 performance_fun = table.DownsideRisk)

cat("Risk Metrics:\n")
print(risk_metrics)
cat("\n")

# 5. Individual stock performance
cat("Step 5: Individual stock performance:\n")
individual_performance <- returns %>%
  group_by(symbol) %>%
  tq_performance(Ra = returns,
                 performance_fun = table.AnnualizedReturns)

print(individual_performance)
cat("\n")

# 6. Correlation analysis
cat("Step 6: Correlation analysis...\n")
returns_wide <- returns %>%
  pivot_wider(names_from = symbol,
              values_from = returns,
              values_fill = 0)

correlation_matrix <- cor(returns_wide[, -1], use = "complete.obs")
cat("\nCorrelation Matrix:\n")
print(round(correlation_matrix, 3))
cat("\n")

# 7. Visualizations
cat("Step 7: Creating visualizations...\n\n")

# Plot 1: Cumulative returns comparison
individual_growth <- returns %>%
  group_by(symbol) %>%
  mutate(growth = cumprod(1 + returns))

portfolio_growth <- portfolio_returns %>%
  mutate(growth = cumprod(1 + portfolio_returns),
         symbol = "Portfolio")

# Combine and plot
growth_comparison <- bind_rows(
  individual_growth %>% select(date, symbol, growth),
  portfolio_growth %>% select(date, symbol, growth)
)

p1 <- ggplot(growth_comparison, aes(x = date, y = growth, color = symbol)) +
  geom_line(size = 1) +
  labs(title = "Cumulative Returns Comparison",
       subtitle = paste("Portfolio vs Individual Assets:", paste(tickers, collapse = ", ")),
       x = "Date",
       y = "Growth of $1",
       color = "Asset") +
  theme_minimal() +
  theme(legend.position = "bottom")

print(p1)

# Plot 2: Portfolio performance chart
portfolio_returns_xts <- xts(portfolio_returns$portfolio_returns,
                              order.by = portfolio_returns$date)

charts.PerformanceSummary(portfolio_returns_xts,
                          main = "Portfolio Performance Summary",
                          wealth.index = TRUE)

# 8. Risk-Return scatter
cat("Step 8: Risk-Return analysis...\n")

risk_return <- returns %>%
  group_by(symbol) %>%
  summarise(
    avg_return = mean(returns, na.rm = TRUE) * 252,  # Annualized
    volatility = sd(returns, na.rm = TRUE) * sqrt(252),  # Annualized
    sharpe = avg_return / volatility
  )

cat("\nRisk-Return Profile:\n")
print(risk_return)
cat("\n")

p2 <- ggplot(risk_return, aes(x = volatility, y = avg_return)) +
  geom_point(size = 4, color = "blue") +
  geom_text(aes(label = symbol), vjust = -1) +
  labs(title = "Risk-Return Profile",
       subtitle = "Annualized Returns vs Volatility",
       x = "Volatility (Annualized)",
       y = "Return (Annualized)") +
  theme_minimal()

print(p2)

cat("\n✅ Portfolio analysis complete!\n")
cat("\nNext steps:\n")
cat("1. Optimize portfolio weights using PortfolioAnalytics\n")
cat("2. Add more assets for diversification\n")
cat("3. Implement rebalancing strategy\n")
cat("4. Test different weighting schemes (market cap, equal risk, etc.)\n")
cat("5. Add constraints (sector limits, position limits, etc.)\n")