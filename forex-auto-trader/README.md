# Forex Auto Trader Research Framework

Personal research framework for automated Forex trading with a focus on reproducible experiments, cost-aware backtests and strict risk controls.

## Safety defaults
- Live trading is **disabled by default**.
- The CLI does not expose live order execution.
- Backtests include configurable spread, slippage and commission.
- Position sizing is risk-based.
- Daily loss and max drawdown kill-switches are part of the design.
- In-sample leaderboard rank is treated only as a screening result, not proof of an edge.

## Current architecture

```text
forex-auto-trader/
├─ config.example.yaml
├─ requirements.txt
├─ src/
│  ├─ config.py
│  ├─ data.py
│  ├─ strategy.py
│  ├─ research.py
│  ├─ risk.py
│  ├─ backtest.py
│  ├─ mt5_broker.py
│  └─ main.py
└─ tests/
   ├─ test_data.py
   ├─ test_research.py
   ├─ test_risk.py
   └─ test_strategy_factory.py
```

## Phase status

### Phase 1 — Core backtest/risk engine ✅
- Cost-aware backtest
- ATR exits
- Risk-based position sizing
- Daily-loss and drawdown kill switches
- MT5 market-data adapter

### Phase 2 — Data Engine ✅
- UTC-normalized OHLC validation
- Duplicate handling and sorting
- CSV.GZ local cache
- Incremental upsert/merge
- OHLC resampling
- MT5 cache command

### Phase 3 — Strategy Factory + Batch Research ✅
The registry currently contains 13 testable hypotheses across multiple families:

- `ema_trend`
- `sma_trend`
- `donchian_breakout`
- `bollinger_reversion`
- `rsi_reversion`
- `momentum`
- `macd_trend`
- `ema_pullback`
- `volatility_breakout`
- `zscore_reversion`
- `trend_breakout`
- `range_reversion`
- `long_term_momentum`

Every strategy returns the same contract:

```text
signal                 -1 / 0 / +1
stop_distance          price distance
take_profit_distance   price distance
```

This allows the same backtest engine to compare hypotheses without strategy-specific execution code.

## Quick start

```bash
cd forex-auto-trader
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
copy config.example.yaml config.yaml
```

List strategies:

```bash
python -m src.main --mode list-strategies
```

Run one synthetic-data backtest:

```bash
python -m src.main --mode demo-backtest --strategy ema_trend --bars 5000
```

Run all strategies on the same synthetic sample:

```bash
python -m src.main --mode batch-demo --strategies all --bars 10000
```

Run all strategies on MT5 history:

```bash
python -m src.main --mode batch-mt5 --strategies all --bars 20000
```

Cache MT5 history locally:

```bash
python -m src.main --mode cache-mt5 --bars 50000
```

Batch results are exported by default to:

```text
results/strategy_leaderboard.csv
```

## Research discipline

Do **not** select a strategy for live trading because it tops the current leaderboard. Testing many hypotheses creates multiple-testing and overfitting risk. The next validation phase must evaluate candidates on data they were not optimized on.

## Next phases

### Phase 4 — Robust Validation
- Train / validation / untouched out-of-sample splits
- Rolling walk-forward evaluation
- Parameter stability maps
- Bootstrap / Monte Carlo trade-path analysis
- Multiple-testing-aware scoring
- More realistic timeframe-aware performance metrics

### Phase 5 — Portfolio Research
- Correlation between strategy equity curves
- Strategy diversification
- Risk budgeting
- Portfolio-level drawdown controls

### Phase 6 — Paper Trading
- MT5 paper daemon
- Broker execution logging
- Backtest-vs-forward slippage comparison
- Health monitoring and alerting

### Phase 7 — Guarded Small Live Deployment
Only after robust out-of-sample and paper validation. Live trading should remain small, capped and reversible with hard kill switches.

## Important
This project is a research framework, not a guarantee of profit. Leveraged FX/CFD trading can lose money quickly. Spread, slippage, commission, swap, gaps, execution quality, leverage and regime changes can materially alter live results versus backtests.
