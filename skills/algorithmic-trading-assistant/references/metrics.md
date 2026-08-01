# Trading Performance Metrics Reference

## Return Metrics
| Metric | Formula | Target |
|--------|---------|--------|
| Total Return | (End Value - Start Value) / Start Value | > 0% |
| Annualized Return | (1 + Total Return)^(1/Years) - 1 | > Risk-free rate |
| CAGR | (End Value / Start Value)^(1/Years) - 1 | > Benchmark |

## Risk Metrics
| Metric | Description | Target |
|--------|-------------|--------|
| Max Drawdown | Largest peak-to-trough decline | < 20% |
| Volatility | Standard deviation of returns | Varies by strategy |
| VaR (95%) | Worst expected loss in a day | < Risk budget |
| Sharpe Ratio | (Return - Risk-free) / Volatility | > 1.0 |
| Sortino Ratio | (Return - Risk-free) / Downside Volatility | > 1.5 |
| Calmar Ratio | Annualized Return / Max Drawdown | > 1.0 |

## Trade Metrics
| Metric | Description | Target |
|--------|-------------|--------|
| Win Rate | Winning trades / Total trades | > 40% |
| Profit Factor | Gross Profit / Gross Loss | > 1.5 |
| Expectancy | Average Win × Win Rate - Average Loss × Loss Rate | > 0 |
| Average Trade | Total PnL / Total Trades | > 0 |
