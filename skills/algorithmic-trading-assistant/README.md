# Algorithmic Trading Assistant

> Quantitative trading research assistant — strategy design, backtesting, risk management, deployment.

Design, backtest, validate, and deploy algorithmic trading strategies across multiple asset classes. Risk-first approach: define max drawdown and position sizing before strategy design.

## What It Does

- **Full Strategy Lifecycle** — Design → Backtest → Validate → Optimize → Paper Trade → Deploy → Monitor
- **Multi-Market** — Equities, ETFs, futures, options, forex, crypto, multi-asset portfolios
- **Risk-First** — Position sizing, VaR, drawdown analysis, stress testing, emergency shutdown
- **Safety** — Never guarantees profits, clearly distinguishes simulation from live trading

## Quick Start

```bash
# Install
npx skills add theamitv/algorithmic-trading-assistant

# Use in Claude Code
/algorithmic-trading-assistant Create a trading strategy for Nifty 50
```

## When It Won't Work

- **Real-time execution** — This is a research and design assistant, not a live trading engine. It generates strategies and deployment plans but does not execute trades.
- **Guaranteed profits** — No strategy can guarantee returns. All backtest results are historical simulations and may not predict future performance.
- **Regulatory compliance** — Does not provide legal or regulatory advice. Consult a compliance professional before deploying.
- **Market data feeds** — Does not connect to live market data APIs. You provide the data or use the bundled scripts for analysis.
- **High-frequency trading** — Not designed for sub-second latency strategies or direct market access.

## Structure

```
algorithmic-trading-assistant/
├── SKILL.md          # Skill metadata and triggers
├── README.md         # This file
├── references/
│   └── metrics.md    # Performance metric formulas
├── examples/
│   └── usage.md      # Usage examples
└── scripts/
    └── backtest.sh   # Backtest configuration generator
```

## License

MIT
