"""
Nifty Momentum Swing — Backtest Engine
Strategy: 20/50 EMA crossover + RSI(14) momentum + volume confirmation
Instrument: Nifty 50 Futures
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import warnings
warnings.filterwarnings('ignore')

# ============================================================
# CONFIGURATION
# ============================================================
CONFIG = {
    'capital': 500000,          # ₹5,00,000
    'risk_per_trade': 0.01,     # 1%
    'max_drawdown': 0.15,       # 15%
    'slippage': 0.0005,         # 0.05%
    'commission': 20,           # ₹20 per trade
    'ema_fast': 20,
    'ema_slow': 50,
    'rsi_period': 14,
    'rsi_threshold': 50,
    'atr_period': 14,
    'take_profit_atr': 2.0,
    'trail_atr': 1.0,
    'trail_activate_atr': 1.5,
    'max_hold_days': 10,
    'max_open_positions': 2,
    'daily_loss_limit': 0.03,   # 3%
    'weekly_loss_limit': 0.05,  # 5%
    'cooloff_losses': 3,
    'cooloff_days': 2,
}

# ============================================================
# INDICATORS
# ============================================================
def add_indicators(df):
    """Add all technical indicators to the dataframe."""
    df = df.copy()

    # EMAs
    df['ema_fast'] = df['close'].ewm(span=CONFIG['ema_fast'], adjust=False).mean()
    df['ema_slow'] = df['close'].ewm(span=CONFIG['ema_slow'], adjust=False).mean()

    # ATR
    df['high_low'] = df['high'] - df['low']
    df['high_close'] = abs(df['high'] - df['close'].shift(1))
    df['low_close'] = abs(df['low'] - df['close'].shift(1))
    df['tr'] = df[['high_low', 'high_close', 'low_close']].max(axis=1)
    df['atr'] = df['tr'].ewm(span=CONFIG['atr_period'], adjust=False).mean()

    # RSI
    delta = df['close'].diff()
    gain = delta.where(delta > 0, 0.0)
    loss = -delta.where(delta < 0, 0.0)
    avg_gain = gain.ewm(span=CONFIG['rsi_period'], adjust=False).mean()
    avg_loss = loss.ewm(span=CONFIG['rsi_period'], adjust=False).mean()
    rs = avg_gain / avg_loss.replace(0, np.nan)
    df['rsi'] = 100 - (100 / (1 + rs))

    # Volume average
    df['vol_avg'] = df['volume'].rolling(window=20).mean()

    # ATR volatility filter
    df['atr_avg'] = df['atr'].rolling(window=20).mean()

    return df

# ============================================================
# SIGNAL GENERATION
# ============================================================
def generate_signals(df):
    """Generate entry/exit signals based on strategy rules."""
    df = df.copy()

    # Trend condition: 20 EMA > 50 EMA
    df['uptrend'] = df['ema_fast'] > df['ema_slow']

    # RSI momentum: RSI crosses above 50
    df['rsi_above_50'] = df['rsi'] > CONFIG['rsi_threshold']
    df['rsi_cross'] = df['rsi_above_50'] & ~df['rsi_above_50'].shift(1).fillna(False)

    # Volume confirmation
    df['high_volume'] = df['volume'] > df['vol_avg']

    # Price breakout: close > previous high
    df['breakout'] = df['close'] > df['high'].shift(1)

    # Volatility filter: ATR not excessively high
    df['normal_vol'] = df['atr'] <= df['atr_avg'] * 3

    # Entry signal
    df['entry'] = (
        df['uptrend']
        & df['rsi_cross']
        & df['high_volume']
        & df['breakout']
        & df['normal_vol']
    )

    # Trend reversal exit
    df['trend_reversal'] = df['ema_fast'] < df['ema_slow']

    return df

# ============================================================
# BACKTEST ENGINE
# ============================================================
def run_backtest(df):
    """Run the complete backtest."""
    df = add_indicators(df)
    df = generate_signals(df)

    trades = []
    position = None
    equity_curve = [CONFIG['capital']]
    equity = CONFIG['capital']
    peak = CONFIG['capital']
    consecutive_losses = 0
    cooloff_until = None
    daily_pnl = 0
    weekly_pnl = 0
    last_week = None

    for i in range(CONFIG['ema_slow'], len(df)):
        date = df.index[i]
        row = df.iloc[i]
        current_week = date.isocalendar()[1]

        # Reset daily/weekly counters
        if last_week is not None and current_week != last_week:
            weekly_pnl = 0
        last_week = current_week

        # Check cool-off
        if cooloff_until and date < cooloff_until:
            equity_curve.append(equity)
            continue

        # Check loss limits
        if daily_pnl <= -CONFIG['capital'] * CONFIG['daily_loss_limit']:
            equity_curve.append(equity)
            continue
        if weekly_pnl <= -CONFIG['capital'] * CONFIG['weekly_loss_limit']:
            equity_curve.append(equity)
            continue

        # --- EXIT LOGIC ---
        if position:
            exit_signal = False
            exit_reason = ''

            # Stop loss
            if row['low'] <= position['stop_loss']:
                exit_price = position['stop_loss']
                exit_reason = 'stop_loss'
                exit_signal = True

            # Take profit
            elif row['high'] >= position['take_profit']:
                exit_price = position['take_profit']
                exit_reason = 'take_profit'
                exit_signal = True

            # Trailing stop
            elif position['trail_active']:
                new_stop = row['close'] - CONFIG['trail_atr'] * position['entry_atr']
                position['stop_loss'] = max(position['stop_loss'], new_stop)
                if row['low'] <= position['stop_loss']:
                    exit_price = position['stop_loss']
                    exit_reason = 'trailing_stop'
                    exit_signal = True

            # Activate trailing
            elif (row['close'] - position['entry_price']) >= CONFIG['trail_activate_atr'] * position['entry_atr']:
                position['trail_active'] = True
                position['stop_loss'] = row['close'] - CONFIG['trail_atr'] * position['entry_atr']

            # Time stop
            elif (date - position['entry_date']).days >= CONFIG['max_hold_days']:
                exit_price = row['close']
                exit_reason = 'time_stop'
                exit_signal = True

            # Trend reversal
            elif row['trend_reversal']:
                exit_price = row['close']
                exit_reason = 'trend_reversal'
                exit_signal = True

            if exit_signal:
                # Apply slippage
                exit_price *= (1 - CONFIG['slippage'])
                gross_pnl = (exit_price - position['entry_price']) * position['quantity']
                net_pnl = gross_pnl - CONFIG['commission']

                trade = {
                    'entry_date': position['entry_date'],
                    'exit_date': date,
                    'entry_price': round(position['entry_price'], 2),
                    'exit_price': round(exit_price, 2),
                    'quantity': position['quantity'],
                    'gross_pnl': round(gross_pnl, 2),
                    'net_pnl': round(net_pnl, 2),
                    'return_pct': round((exit_price / position['entry_price'] - 1) * 100, 2),
                    'exit_reason': exit_reason,
                    'hold_days': (date - position['entry_date']).days,
                }
                trades.append(trade)

                equity += net_pnl
                daily_pnl += net_pnl
                weekly_pnl += net_pnl

                if net_pnl < 0:
                    consecutive_losses += 1
                    if consecutive_losses >= CONFIG['cooloff_losses']:
                        cooloff_until = date + timedelta(days=CONFIG['cooloff_days'])
                        consecutive_losses = 0
                else:
                    consecutive_losses = 0

                position = None

        # --- ENTRY LOGIC ---
        if not position and row['entry']:
            # Check max open positions
            open_count = sum(1 for t in trades if t['exit_date'] >= date)
            if open_count < CONFIG['max_open_positions']:
                atr_value = row['atr']
                risk_amount = CONFIG['capital'] * CONFIG['risk_per_trade']
                quantity = max(1, int(risk_amount / atr_value))
                entry_price = row['close'] * (1 + CONFIG['slippage'])

                position = {
                    'entry_price': entry_price,
                    'entry_date': date,
                    'quantity': quantity,
                    'entry_atr': atr_value,
                    'stop_loss': entry_price - CONFIG['trail_atr'] * atr_value,
                    'take_profit': entry_price + CONFIG['take_profit_atr'] * atr_value,
                    'trail_active': False,
                }

        equity_curve.append(equity)
        peak = max(peak, equity)

    return trades, equity_curve, df

# ============================================================
# PERFORMANCE METRICS
# ============================================================
def calculate_metrics(trades, equity_curve, initial_capital):
    """Calculate comprehensive performance metrics."""
    if not trades:
        return {'error': 'No trades generated'}

    equity = pd.Series(equity_curve)
    returns = equity.pct_change().dropna()

    final_equity = equity.iloc[-1]
    total_return = (final_equity / initial_capital - 1) * 100

    # Drawdown
    peak = equity.cummax()
    drawdown = (equity - peak) / peak
    max_dd = drawdown.min() * 100

    # Trade stats
    winning_trades = [t for t in trades if t['net_pnl'] > 0]
    losing_trades = [t for t in trades if t['net_pnl'] <= 0]
    win_rate = len(winning_trades) / len(trades) * 100 if trades else 0

    gross_profit = sum(t['net_pnl'] for t in winning_trades)
    gross_loss = abs(sum(t['net_pnl'] for t in losing_trades))
    profit_factor = gross_profit / gross_loss if gross_loss > 0 else float('inf')

    avg_win = np.mean([t['net_pnl'] for t in winning_trades]) if winning_trades else 0
    avg_loss = np.mean([t['net_pnl'] for t in losing_trades]) if losing_trades else 0
    expectancy = (win_rate / 100 * avg_win) - ((1 - win_rate / 100) * abs(avg_loss))

    # Risk metrics
    daily_returns = returns * 100
    sharpe = np.sqrt(252) * daily_returns.mean() / daily_returns.std() if daily_returns.std() > 0 else 0
    downside = daily_returns[daily_returns < 0]
    sortino = np.sqrt(252) * daily_returns.mean() / downside.std() if len(downside) > 0 and downside.std() > 0 else 0
    calmar = (total_return / 100) / (abs(max_dd) / 100) if max_dd != 0 else 0

    # VaR
    var_95 = np.percentile(daily_returns, 5) if len(daily_returns) > 0 else 0

    return {
        'total_return_pct': round(total_return, 2),
        'final_equity': round(final_equity, 2),
        'max_drawdown_pct': round(max_dd, 2),
        'sharpe_ratio': round(sharpe, 2),
        'sortino_ratio': round(sortino, 2),
        'calmar_ratio': round(calmar, 2),
        'total_trades': len(trades),
        'winning_trades': len(winning_trades),
        'losing_trades': len(losing_trades),
        'win_rate_pct': round(win_rate, 2),
        'profit_factor': round(profit_factor, 2),
        'avg_win': round(avg_win, 2),
        'avg_loss': round(avg_loss, 2),
        'expectancy': round(expectancy, 2),
        'var_95_pct': round(var_95, 2),
        'avg_hold_days': round(np.mean([t['hold_days'] for t in trades]), 1),
    }

# ============================================================
# MAIN
# ============================================================
if __name__ == '__main__':
    print("=" * 60)
    print("NIFTY MOMENTUM SWING — BACKTEST ENGINE")
    print("=" * 60)
    print(f"\nConfig:")
    for k, v in CONFIG.items():
        print(f"  {k}: {v}")

    print("\n" + "=" * 60)
    print("TO RUN:")
    print("=" * 60)
    print("""
    1. Get Nifty 50 Futures daily data (OHLCV) as CSV
       Columns: date, open, high, low, close, volume
       Sources: Yahoo Finance, Alpha Vantage, Zerodha API

    2. Load and run:
       import pandas as pd
       df = pd.read_csv('nifty_data.csv', index_col='date', parse_dates=True)
       trades, equity, df = run_backtest(df)
       metrics = calculate_metrics(trades, equity, 500000)

    3. View results:
       for k, v in metrics.items():
           print(f'{k}: {v}')
    """)

    print("\nStrategy Rules Summary:")
    print("  Entry: 20 EMA > 50 EMA AND RSI crosses above 50")
    print("         AND Volume > 20d avg AND Close > prev high")
    print("  Exit:  Stop loss (1× ATR) | Take profit (2× ATR)")
    print("         Trailing stop | Time stop (10 days)")
    print("         Trend reversal (EMA cross)")
    print(f"\n  Risk per trade: {CONFIG['risk_per_trade']*100}%")
    print(f"  Max drawdown:   {CONFIG['max_drawdown']*100}%")
    print(f"  Max positions:  {CONFIG['max_open_positions']}")
