# Forex Auto Trader Research Framework

Personal research framework for automated Forex trading with reproducible experiments, cost-aware backtests, robust validation, portfolio-level risk control, paper-forward verification, explicitly guarded live execution and production operations monitoring.

## Safety defaults
- Live trading is **disabled by default**.
- Paper mode never calls `order_send`.
- Real-order modes require **both** `live.enabled: true` and the exact operator arming phrase.
- Live mode supports **MT5 hedging accounts only** so individual strategy positions remain separable.
- Live mode applies per-order lot caps, total managed-lot caps, open-position caps and a maximum-spread gate.
- Live sizing uses broker-reported tick size, tick value and volume constraints.
- Emergency flatten affects only positions for the configured symbol and magic number.
- Bar-close signals execute on the next bar open in research/paper models.
- Live mode evaluates only the newest completed bar and never replays missed historical bars into broker orders.
- Phase 8 rejects stale market data, detects managed-position anomalies and writes a runtime heartbeat before new live risk is accepted.
- Operational ambiguity fails closed for **new orders**. Integrity incidents halt the live engine without guessing which broker positions should be flattened.
- Daily-loss and max-drawdown breaches retain the explicit risk-kill-switch flatten behavior.
- A Phase 4 `PASS`, portfolio OOS result, paper result or clean operational health report does not guarantee profitability.

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
│  ├─ ops.py
│  ├─ risk.py
│  ├─ backtest.py
│  ├─ mt5_broker.py
│  └─ main.py
└─ tests/
   ├─ test_backtest_execution.py
   ├─ test_data.py
   ├─ test_live_guards.py
   ├─ test_ops.py
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
- Broker-native tick size/value, contract size, volume min/step/max and pip-size derivation
- Risk sizing from broker tick value rather than a generic `$10/pip` assumption
- MT5 `order_check()` before every real order
- Filling-mode fallback checks before `order_send`
- Hedging-account requirement for strategy-level position separation
- Strategy tagging via magic number + `fat:<strategy>` comment
- Per-order lot cap, total managed-lot cap and managed open-position cap
- Maximum spread gate
- Daily-loss and max-drawdown hard halt
- Emergency flatten for managed positions
- Persistent live state and CSV audit log
- No historical-order replay after restart
- Read-only `live-preflight`
- Explicit operator arming requirement
- `live-mt5-once`, `live-mt5-daemon`, and `live-flatten`

### Phase 8 — Production Hardening & Reconciliation ✅
Phase 8 adds an operations layer around the live engine so the process does not equate “Python is still running” with “the broker state is healthy.”

Implemented:
- Read-only `live-health` operational command
- MT5 terminal `connected` and `trade_allowed` health checks
- Fresh-tick gate using broker `time_msc`
- Fresh completed-bar gate with a default threshold of 2.5 configured timeframes
- Retryable `DEGRADED` behavior for stale tick/bar data; the completed bar is **not** marked processed while stale
- Managed-position integrity checks for:
  - duplicate positions for one strategy
  - unknown managed comments
  - unknown strategy tags
  - missing stop-loss or take-profit
- Critical operational anomalies persist `halted=true` and reject new orders
- Critical integrity anomalies do **not** implicitly flatten positions because broker state is ambiguous and requires operator review
- Atomic `runtime/live_heartbeat.json` with account, margin, managed positions, data ages and incident state
- `runtime/live_incidents.csv` incident audit trail with de-duplication
- MT5 broker deal-history reconciliation using a persistent `last_deal_time_msc` cursor
- Broker-side profit, commission and swap imported into `RECONCILE_DEAL` audit events
- Restart-safe deal reconciliation lookback
- Bounded MT5 reconnect attempts after runtime failures
- `RUNTIME_ERROR` and `RECONNECT` events recorded in the live audit log
- After reconnect, the next cycle re-reads broker/account/position state before considering any new order
- Tests for freshness, position integrity, terminal health, deal cursor behavior and atomic heartbeat writes

The default example live configuration remains intentionally small:

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

## Guarded live / production operations commands

### 1. Run preflight

`live-preflight` is read-only and does not require the arming phrase:

```bash
python -m src.main --mode live-preflight
```

It checks configuration enablement, terminal connectivity/trading permission, hedging mode, symbol trade availability, tick value, spread, managed exposure and free margin.

### 2. Run operational health

`live-health` is also read-only and does not submit orders:

```bash
python -m src.main --mode live-health
```

It reports terminal status, current spread, tick age, completed-bar age, account equity, managed positions and Phase 8 incidents. Use this before an armed live cycle and when investigating a persisted halt.

### 3. Keep live disabled until paper and operational review are complete

The example config contains:

```yaml
live:
  enabled: false
```

Changing it to `true` is only one of two required gates.

### 4. Run one explicitly armed live cycle

Real-order modes require the exact arming phrase:

```bash
python -m src.main --mode live-mt5-once \
  --arm-live I_UNDERSTAND_LIVE_TRADING
```

### 5. Run a bounded daemon test

```bash
python -m src.main --mode live-mt5-daemon \
  --live-max-cycles 3 \
  --live-poll-seconds 30 \
  --arm-live I_UNDERSTAND_LIVE_TRADING
```

Use bounded cycles before considering an unbounded daemon. Runtime MT5 failures trigger only the configured bounded reconnect attempts; exhaustion stops the daemon.

### 6. Emergency flatten managed positions

```bash
python -m src.main --mode live-flatten \
  --arm-live I_UNDERSTAND_LIVE_TRADING
```

`live-flatten` closes only positions matching the configured symbol and magic number. It does not touch unrelated manual trades or other magic numbers.

By default live mode reads the frozen Phase 5 bundle:

```text
results/portfolio/portfolio_weights.csv
results/portfolio/portfolio_candidates.csv
```

and Phase 8 writes:

```text
runtime/live_state.json
runtime/live_events.csv
runtime/live_heartbeat.json
runtime/live_incidents.csv
```

`live_state.json` now also persists the broker-deal reconciliation cursor. Do not manually clear a Phase 8 operational halt without first reconciling the actual MT5 positions and reviewing the incident log.

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
Live preflight + live-health
   ↓
Review heartbeat / incidents / broker reconciliation
   ↓
One armed live cycle at tiny caps
   ↓
Bounded supervised live daemon
   ↓
Only then consider longer operation
```

Do not repeatedly change strategy rules, validation gates, portfolio rules or live limits after observing the same holdout/paper results and still treat those observations as independent evidence.

## Next production phase

Useful Phase 9 work before unattended operation:
- external alerts for HALT / CRITICAL / reconnect exhaustion
- log rotation and archival
- Windows service / process supervision and startup recovery
- dynamic spread and realized-slippage baselines with anomaly thresholds
- deeper local-order versus broker-deal semantic reconciliation
- account-specific margin stress testing before order submission
- clock-drift / machine-time monitoring
- secrets, terminal profile and machine-access hardening

## Important
This project is a research and execution framework, not a guarantee of profit. Leveraged FX/CFD trading can lose money quickly. Spread, slippage, commission, swap, gaps, broker execution, leverage, model error and regime changes can materially alter live results versus research and paper trading.
