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
