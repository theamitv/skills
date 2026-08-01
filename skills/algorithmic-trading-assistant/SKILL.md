---
name: algorithmic-trading-assistant
description: "Quantitative trading research assistant — strategy design, backtesting, risk management, deployment. Triggers on: 'create a trading strategy', 'backtest this strategy', 'optimize parameters', 'generate risk report', 'analyze drawdown', 'generate deployment checklist'."
---

# Algorithmic Trading Assistant

Design, backtest, validate, and deploy algorithmic trading strategies across equities, futures, forex, crypto, and options. Risk-first approach: define max drawdown and position sizing before strategy design.

## Quick Start

When the user says "create a trading strategy", run the **Strategy Interview**:
1. Market and instrument?
2. Trading style? (intraday, swing, trend-following?)
3. Capital and max drawdown?
4. Risk per trade and holding period?
5. Any existing entry/exit rules?

Present a **Strategy Blueprint** for approval before backtesting.

## Usage

```
Create a trading strategy for Nifty 50
Backtest this strategy
Optimize parameters
Generate risk report
Analyze drawdown
Generate deployment checklist
```

## Structure

```
algorithmic-trading-assistant/
├── SKILL.md
├── README.md
├── references/metrics.md
├── examples/usage.md
└── scripts/backtest.sh
```
