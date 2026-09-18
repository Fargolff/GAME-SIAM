# Forex Auto Trader Research Framework

Personal research framework for automated Forex trading with reproducible experiments, cost-aware backtests, robust validation, portfolio-level risk control, paper-forward verification and explicitly guarded live execution.

## Safety defaults
- Live trading is **disabled by default**.
- Paper mode never calls `order_send`.
- Live order execution is exposed only through explicit Phase 7 CLI modes.
- Real-order modes require **both** `live.enabled: true` and the exact operator arming phrase.
- Phase 7 supports **MT5 hedging accounts only** so individual strategy positions remain separable.
- Phase 7 applies per-order lot caps, total managed-lot caps, open-position caps and a maximum-spread gate.
- Phase 7 uses broker-reported tick size, tick value, volume min/step/max and supported filling checks.
- Emergency flatten affects only positions for the configured symbol and magic number.
- Backtests include configurable spread, slippage and commission.
- Bar-close signals execute on the **next bar open** in research/paper models.
- Live mode evaluates only the newest completed bar and never replays missed historical bars into broker orders.
- Daily-loss and max-drawdown kill switches are part of paper and live design.
- A Phase 4 `PASS` remains only a research gate; none of these controls guarantee profitability.

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
│  ├─ validation.py
│  ├─ portfolio.py
│  ├─ paper.py
│  ├─ live.py
│  ├─ risk.py
│  ├─ backtest.py
│  ├─ mt5_broker.py
│  └─ main.py
└─ tests/
   ├─ test_backtest_execution.py
   ├─ test_data.py
   ├─ test_live_guards.py
   ├─ test_paper.py
   ├─ test_portfolio.py
   ├─ test_research.py
   ├─ test_risk.py
   ├─ test_strategy_factory.py
   └─ test_validation.py
```

## Phase status

### Phase 1 — Core backtest/risk engine ✅
- Cost-aware backtest
- ATR exits
- Risk-based position sizing
- Daily-loss and drawdown kill switches
- MT5 market-data adapter
- Conservative same-bar stop/TP handling
- Gap-stop handling
- Next-bar execution for bar-close signals
- End-of-sample position realization
- Timeframe-aware Sharpe annualization

### Phase 2 — Data Engine ✅
- UTC-normalized OHLC validation
- Duplicate handling and sorting
- CSV.GZ local cache
- Incremental upsert/merge
- OHLC resampling
- MT5 cache command

### Phase 3 — Strategy Factory + Batch Research ✅
The registry currently contains 13 testable hypotheses across trend, breakout, momentum and mean-reversion families.

Every strategy returns the same contract:

```text
signal                 -1 / 0 / +1
stop_distance          price distance
take_profit_distance   price distance
```

### Phase 4 — Robust Validation ✅
- Chronological Train / Validation / untouched Out-of-Sample split
- Local parameter-neighborhood search
- Validation-weighted parameter selection
- Rolling walk-forward evaluation
- Parameter-stability analysis
- Bootstrap / Monte Carlo trade-path simulation
- Sharpe decay from Train to OOS
- Automated `PASS`, `WATCH`, `REJECT`, or `ERROR` verdict

### Phase 5 — Portfolio Research ✅
- Phase 4 verdict gate before portfolio inclusion
- Strategy return-correlation analysis
- Inverse-volatility allocation with absolute-correlation penalty
- Maximum strategy-weight constraint
- Risk-contribution and diversification metrics
- Frozen weights evaluated on untouched OOS data
- Portfolio-level Sharpe, volatility, max drawdown and Monte Carlo path risk
- CSV exports for weights, candidates, correlation, OOS equity and summary

### Phase 6 — MT5 Paper Trading ✅
- Persistent atomic JSON state
- Restart-safe `last_bar_time`
- Idempotent processing
- Loads Phase 5 portfolio weights and selected parameters
- Signal-at-close → next-completed-bar-open simulation
- Spread/slippage/commission paper fills
- Gap stop / gap take-profit handling
- Portfolio mark-to-market equity
- Daily-loss and max-drawdown kill switch
- Persistent hard halt after a breach
- CSV event audit trail
- MT5 completed-bar filter
- `paper-demo`, `paper-mt5-once`, and `paper-mt5-daemon`

### Phase 7 — Guarded Small Live Deployment ✅
Phase 7 adds a deliberately constrained real-order path instead of turning paper mode directly into live mode.

Implemented:
- Broker-native symbol specification via MT5:
  - `trade_tick_size`
  - `trade_tick_value_loss` / tick value fallback
  - contract size
  - volume min / step / max
  - digits / point / pip-size derivation
- Risk sizing based on broker tick value rather than a generic `$10/pip` assumption
- MT5 `order_check()` before every order
- Filling-mode fallback checks before `order_send`
- Hedging-account requirement for strategy-level position separation
- Strategy tagging via magic number + `fat:<strategy>` comment
- Per-order lot cap
- Total managed-lot cap
- Managed open-position cap
- Maximum spread gate
- Daily-loss and max-drawdown hard halt
- Emergency flatten for managed positions
- Persistent live state and CSV audit log
- No historical-order replay after restart
- Read-only `live-preflight`
- Explicit operator arming requirement
- `live-mt5-once`, `live-mt5-daemon`, and `live-flatten`

The default example configuration is intentionally very small:

```text
risk_per_trade      0.25%
max_daily_loss      1.00%
max_drawdown        5.00%
max_lot_per_order   0.02
max_total_lots      0.05
max_open_positions  3
max_spread_pips     2.0
```

These are engineering defaults, not a claim that the risk is acceptable for every account or broker.

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

Run a synthetic backtest:

```bash
python -m src.main --mode demo-backtest --strategy ema_trend --bars 5000
```

Run robust validation:

```bash
python -m src.main --mode validate-mt5 --strategies all --bars 30000 --mc-runs 2000
```

Build the Phase 5 portfolio:

```bash
python -m src.main --mode portfolio-mt5 \
  --strategies all \
  --bars 40000 \
  --mc-runs 2000 \
  --max-strategy-weight 0.35
```

## Paper trading commands

Synthetic paper smoke test:

```bash
python -m src.main --mode paper-demo \
  --strategies ema_trend,trend_breakout,long_term_momentum \
  --bars 5000
```

Run one MT5 paper cycle:

```bash
python -m src.main --mode paper-mt5-once
```

Run the MT5 paper daemon:

```bash
python -m src.main --mode paper-mt5-daemon
```

By default Phase 6 writes:

```text
runtime/paper_state.json
runtime/paper_events.csv
```

## Guarded live commands

### 1. Run preflight first

`live-preflight` is read-only and does not require the arming phrase:

```bash
python -m src.main --mode live-preflight
```

It checks:
- `live.enabled`
- hedging account mode
- symbol trade availability
- usable tick value / tick size
- current spread
- managed position count
- total managed lots
- positive free margin

A failed preflight is a stop condition, not something to bypass.

### 2. Keep live disabled until paper review is complete

The example config contains:

```yaml
live:
  enabled: false
```

Changing it to `true` is only one of two required gates.

### 3. Run one explicitly armed live cycle

Real-order modes require the exact arming phrase:

```bash
python -m src.main --mode live-mt5-once \
  --arm-live I_UNDERSTAND_LIVE_TRADING
```

### 4. Run a bounded daemon test

```bash
python -m src.main --mode live-mt5-daemon \
  --live-max-cycles 3 \
  --live-poll-seconds 30 \
  --arm-live I_UNDERSTAND_LIVE_TRADING
```

Use bounded cycles before considering an unbounded daemon.

### 5. Emergency flatten managed positions

```bash
python -m src.main --mode live-flatten \
  --arm-live I_UNDERSTAND_LIVE_TRADING
```

`live-flatten` closes only positions matching the configured symbol and magic number. It does not touch unrelated manual trades or other magic numbers.

By default Phase 7 reads the same frozen Phase 5 bundle:

```text
results/portfolio/portfolio_weights.csv
results/portfolio/portfolio_candidates.csv
```

and writes:

```text
runtime/live_state.json
runtime/live_events.csv
```

## Deployment discipline

Recommended sequence:

```text
Hypothesis
   ↓
Backtest
   ↓
Robust validation
   ↓
Portfolio calibration
   ↓
Untouched portfolio OOS
   ↓
Persistent MT5 paper-forward test
   ↓
Review execution / slippage / incidents
   ↓
Live preflight
   ↓
One armed live cycle at tiny caps
   ↓
Bounded live daemon
   ↓
Only then consider longer operation
```

Do not repeatedly change strategy rules, validation gates, portfolio rules or live limits after observing the same holdout/paper results and still treat those observations as independent evidence.

## Remaining production hardening

Phase 7 is intentionally small and reversible. Before treating the system as production-grade, additional work should include:
- dynamic broker spread/slippage statistics rather than only a hard spread cap
- swap / overnight financing reconciliation
- broker-side deal-history reconciliation against local event logs
- duplicate/missing position incident detection
- stale-market / stale-bar rejection
- disconnect and reconnect health monitoring
- alerting to an external channel
- deployment packaging / Windows service supervision
- account-specific margin stress tests
- secrets and machine-access hardening

## Important
This project is a research and execution framework, not a guarantee of profit. Leveraged FX/CFD trading can lose money quickly. Spread, slippage, commission, swap, gaps, broker execution, leverage, model error and regime changes can materially alter live results versus research and paper trading.
