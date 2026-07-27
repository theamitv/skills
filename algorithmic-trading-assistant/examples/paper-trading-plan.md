# Paper Trading Plan — Nifty Momentum Swing

## Phase 1: Validation (2-4 weeks)

### Setup
- **Platform**: TradingView paper trading or Zerodha Sensibull
- **Capital**: ₹5,00,000 (virtual)
- **Execution**: Manual, following the strategy rules exactly
- **Journal**: Record every trade in the template below

### Daily Routine
```
Pre-market (9:00 AM):
  □ Check Nifty 50 Futures gap/open
  □ Calculate ATR(14) and EMAs
  □ Identify any entry signals
  □ Note any news/events (FOMC, budget, RBI)

Market hours (9:15 AM - 3:30 PM):
  □ Monitor open positions
  □ Check stop losses
  □ Log any manual overrides

Post-market (3:30 PM):
  □ Update trade journal
  □ Calculate daily P&L
  □ Review strategy adherence
```

### Trade Journal Template

```
Date: _______________
Instrument: Nifty Futures

ENTRY
  Signal type:  □ EMA cross  □ RSI cross  □ Breakout
  Entry price:  ________
  Quantity:     ________
  Stop loss:    ________
  Take profit:  ________
  ATR(14):      ________
  Conviction:   □ Strong  □ Moderate  □ Weak

EXIT
  Exit date:    ________
  Exit price:   ________
  Exit reason:  □ SL hit  □ TP hit  □ Trailing  □ Time  □ Manual
  Gross P&L:    ________
  Net P&L:      ________
  Hold days:    ________

REVIEW
  Strategy followed?  □ Yes  □ No (reason: ________)
  Would take again?   □ Yes  □ No
  Notes: __________________________________
```

### Success Criteria for Going Live

| Metric | Minimum | Target |
|--------|---------|--------|
| Trades taken | 20+ | 30+ |
| Win rate | 50%+ | 55%+ |
| Profit factor | 1.3+ | 1.5+ |
| Max drawdown | < 10% | < 8% |
| Strategy adherence | 90%+ | 95%+ |

## Phase 2: Optimization (1-2 weeks)

After 20+ paper trades, optimize:
1. **Parameter sweep**: Test EMA(10/30), EMA(20/50), EMA(50/200)
2. **RSI threshold**: Try 40, 45, 50, 55
3. **ATR multiples**: Test SL 0.5×, 1×, 1.5× and TP 1.5×, 2×, 3×
4. **Time filter**: Test skipping first 30 min, last 30 min

## Phase 3: Go Live Decision

**Go live only if:**
- [ ] 20+ paper trades completed
- [ ] Win rate ≥ 50%
- [ ] Profit factor ≥ 1.3
- [ ] Max drawdown < 10%
- [ ] Strategy followed > 90% of the time
- [ ] All parameter decisions documented
- [ ] Broker account configured
- [ ] Risk limits set in trading platform
