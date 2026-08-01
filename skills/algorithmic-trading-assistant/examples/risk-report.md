# Risk Report — Nifty Momentum Swing

## Portfolio Risk Summary

| Risk Metric | Value | Status |
|-------------|-------|--------|
| Capital at Risk | ₹5,00,000 | ✅ |
| Max Drawdown Limit | 15% (₹75,000) | ✅ |
| Risk Per Trade | 1% (₹5,000) | ✅ |
| Max Open Positions | 2 (40% capital) | ✅ |
| Daily Loss Limit | 3% (₹15,000) | ✅ |
| Weekly Loss Limit | 5% (₹25,000) | ✅ |
| Leverage (max) | ~2× (futures) | ✅ |

## Scenario Analysis

### Scenario 1: Normal Market (+5% trend, low volatility)
| Outcome | Probability | Impact |
|---------|-------------|--------|
| Win | 60% | +₹3,000 to +₹8,000 per trade |
| Loss | 40% | -₹3,000 to -₹5,000 per trade |
| **Monthly P&L** | **Expected** | **+₹12,000 to +₹30,000** |

### Scenario 2: Trending Market (+10% strong trend)
| Outcome | Probability | Impact |
|---------|-------------|--------|
| Win | 70% | +₹5,000 to +₹12,000 per trade |
| Loss | 30% | -₹3,000 to -₹5,000 per trade |
| **Monthly P&L** | **Expected** | **+₹25,000 to +₹60,000** |

### Scenario 3: Range-Bound Market (0-3% move, choppy)
| Outcome | Probability | Impact |
|---------|-------------|--------|
| Win | 40% | +₹2,000 to +₹5,000 per trade |
| Loss | 60% | -₹3,000 to -₹5,000 per trade |
| **Monthly P&L** | **Expected** | **-₹5,000 to -₹15,000** |

### Scenario 4: High Volatility / Crash (VIX > 25)
| Outcome | Probability | Impact |
|---------|-------------|--------|
| Win | 35% | +₹8,000 to +₹15,000 per trade |
| Loss | 65% | -₹5,000 to -₹8,000 per trade |
| **Monthly P&L** | **Expected** | **-₹10,000 to -₹25,000** |

### Scenario 5: Worst Case (20 consecutive losses)
| Losses | Capital Remaining | Drawdown |
|--------|-------------------|----------|
| 5 | ₹4,75,000 | -5% |
| 10 | ₹4,50,000 | -10% |
| 15 | ₹4,25,000 | -15% ← Max drawdown hit |
| 20 | ₹4,00,000 | -20% ← STOP |

## Risk Heat Map

```
                    Volatility
              Low      Normal    High     Extreme
Trending     [  ]      [  ]      [⚠]      [✗]
Slight Trend [  ]      [✅]      [⚠]      [✗]
Range-Bound  [⚠]      [⚠]      [✗]      [✗]
Declining    [  ]      [⚠]      [✗]      [✗]

  ✅ = Favorable    ⚠ = Caution    ✗ = Avoid
```

## Risk Controls

### Pre-Trade Checks
```
Before every entry, verify:
  □ ATR(14) < 3× ATR(20) average (normal volatility)
  □ No scheduled major news today (RBI, budget, FOMC)
  □ Daily loss limit not breached
  □ Weekly loss limit not breached
  □ Cool-off period not active
  □ Less than 2 positions currently open
  □ Margin sufficient for the trade
```

### Position-Level Risk
```
Stop Loss:    1× ATR(14) from entry
  - ATR(14) = 200 → SL = 200 points
  - Loss = 200 × 25 (1 lot) = ₹5,000 = 1% of capital ✅

Take Profit:  2× ATR(14) from entry
  - ATR(14) = 200 → TP = 400 points
  - Profit = 400 × 25 (1 lot) = ₹10,000 = 2% of capital ✅

Risk/Reward:  1:2 ✅
```

### Portfolio-Level Risk
```
Max Exposure: 2 positions × ₹5,000 risk = ₹10,000 (2% of capital)
Max Correlation: No two positions in same sector
Max Leverage: 2 lots × ~₹2,00,000 margin = ₹4,00,000 (80% of capital)
```

## Stress Test Results

| Stress Event | Expected Drawdown | Recovery Time |
|-------------|-------------------|---------------|
| 2008-style crash (50% drop) | 15-20% | 6-12 months |
| COVID crash (Mar 2020, -38%) | 12-18% | 4-8 months |
| Hindenburg (Jan 2023, -5%) | 5-8% | 2-4 weeks |
| Budget day volatility | 3-5% | 1-2 weeks |
| FOMC rate decision | 2-4% | 3-5 days |
| 3-month range-bound market | 8-12% | 1-3 months |

## Risk Escalation Rules

```
Normal (DD < 5%):     Continue normal trading
Caution (DD 5-8%):    Reduce position size by 50%
Elevated (DD 8-12%):  Stop trading, full review
Critical (DD > 12%):  Stop trading, strategy pivot required
```

## Emergency Shutdown

Triggered automatically if any of:
1. Daily loss > ₹15,000 (3%)
2. Weekly loss > ₹25,000 (5%)
3. Drawdown > ₹60,000 (12%)
4. 3 consecutive losses
5. Broker API disconnected > 5 minutes
6. Circuit breaker on Nifty 50

**Shutdown Procedure:**
1. Close all positions at market price
2. Cancel all pending orders
3. Move funds to safety (liquid funds)
4. Document the reason
5. Do not resume without 2-week paper trading validation
