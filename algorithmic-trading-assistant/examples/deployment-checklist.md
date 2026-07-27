# Deployment Checklist — Nifty Momentum Swing

## □ Pre-Deployment

### Broker Setup
- [ ] Broker account funded with ₹5,00,000
- [ ] API access enabled (Zerodha Kite / Angel One SmartAPI / Upstox)
- [ ] API keys generated and stored securely (not in code)
- [ ] Trading limits configured (intraday + delivery)
- [ ] Margin requirements verified for Nifty Futures

### Platform Setup
- [ ] Trading platform installed (Zerodha Kite / TradingView / custom)
- [ ] Market data feed configured (real-time Nifty Futures)
- [ ] Backup data source configured (in case primary fails)
- [ ] Internet backup (mobile hotspot / secondary ISP)

### Risk Controls
- [ ] Max position size set in broker platform (2 lots)
- [ ] Daily loss limit configured (-3% = -₹15,000)
- [ ] Weekly loss limit configured (-5% = -₹25,000)
- [ ] Kill switch mechanism ready (ability to close all positions)
- [ ] Stop losses set on every entry (non-negotiable)

## □ Day 1-5: Soft Launch

### Daily Checks
```
Pre-market:
  □ Market data feed working
  □ ATR(14) and EMAs calculated
  □ Any scheduled news/events today?
  □ Overnight global markets status

During market:
  □ Monitor positions actively
  □ Check stop losses are in system
  □ No manual overrides (follow the plan)

Post-market:
  □ Log all trades in journal
  □ Verify broker P&L matches journal
  □ Check for any execution issues
```

### Soft Launch Rules
- Trade with 1 lot only (not full position size)
- No new positions after 2:30 PM
- Close all positions by 3:15 PM
- If any rule is broken, pause and review

## □ Week 2-4: Ramp Up

- [ ] Increase to full position sizing
- [ ] Allow 2 concurrent positions
- [ ] Review execution quality (slippage, fills)
- [ ] Compare live vs paper trading results
- [ ] Adjust ATR-based stops if needed

## □ Monitoring Setup

### Daily Monitoring
```
Dashboard:
  □ Open positions & P&L
  □ Current drawdown
  □ Today's P&L vs daily limit
  □ ATR values for open positions
  □ Any margin alerts
```

### Alerts
- [ ] Stop loss hit → notification
- [ ] Take profit hit → notification
- [ ] Daily loss limit breached → auto-close all
- [ ] Weekly loss limit breached → auto-close all
- [ ] Margin below 150% → notification
- [ ] Broker API disconnected → notification

### Weekly Review (Every Friday)
- [ ] Calculate weekly P&L
- [ ] Review all trades for strategy adherence
- [ ] Check drawdown vs max drawdown limit
- [ ] Review broker statements
- [ ] Update trade journal

## □ Emergency Procedures

### Kill Switch
```
When to use:
  - Daily loss limit hit (-3%)
  - Weekly loss limit hit (-5%)
  - Broker API issues
  - Unexpected market event (circuit, freeze)
  - Personal emergency

How to execute:
  1. Close all open positions immediately
  2. Cancel all pending orders
  3. Withdraw excess funds
  4. Notify any stakeholders
  5. Document the reason
```

### Recovery After Drawdown
```
Drawdown 5-8%:
  - Reduce position size by 50%
  - Trade for 1 week at reduced size
  - If profitable, return to normal sizing

Drawdown 8-12%:
  - Stop trading entirely
  - Review all recent trades for pattern
  - Identify root cause (strategy vs execution)
  - Paper trade for 2 weeks
  - Resume only after 2 profitable paper weeks

Drawdown > 12%:
  - Full strategy review
  - Consider strategy pivot or pause
  - Review market regime (is strategy still valid?)
  - Do not resume without new validation
```

## □ Go/No-Go Decision

**Ready to deploy?** Check all:
- [ ] 20+ paper trades completed successfully
- [ ] Win rate ≥ 50%
- [ ] Profit factor ≥ 1.3
- [ ] Max drawdown < 10% in paper trading
- [ ] Broker account configured and tested
- [ ] Risk controls in place
- [ ] Monitoring and alerts configured
- [ ] Emergency procedures documented
- [ ] Kill switch tested
- [ ] Backup internet ready
