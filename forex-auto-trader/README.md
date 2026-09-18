# Forex Auto Trader Research Framework

Personal research framework for automated Forex trading with a focus on reproducible experiments, cost-aware backtests, robust validation, portfolio-level risk control and paper-forward verification.

## Safety defaults
- Live trading is **disabled by default**.
- The CLI does not expose live order execution.
- MT5 paper modes use MT5 **only as a market-data source**.
- Paper mode never calls `order_send`.
- Backtests include configurable spread, slippage and commission.
- Bar-close signals execute on the **next bar open** to avoid same-bar look-ahead optimism.
- Paper mode follows the same next-bar execution rule.
- Position sizing is risk-based.
- Daily loss and max drawdown kill-switches are part of the design.
- In-sample leaderboard rank is treated only as a screening result, not proof of an edge.
- A Phase 4 `PASS` is only a research gate. It is not permission to deploy meaningful capital.
- Portfolio weights are calibrated without using the untouched OOS segment.

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
│  ├─ risk.py
│  ├─ backtest.py
│  ├─ mt5_broker.py
│  └─ main.py
└─ tests/
   ├─ test_backtest_execution.py
   ├─ test_data.py
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

### Phase 4 — Robust Validation ✅
Phase 4 attempts to reject fragile backtests before paper trading.

Implemented checks:
- Chronological Train / Validation / untouched Out-of-Sample split
- Local parameter-neighborhood search instead of unrestricted optimization
- Validation-weighted parameter selection
- Rolling walk-forward re-selection and forward evaluation
- Parameter-stability analysis around the selected configuration
- Bootstrap/Monte Carlo trade-path simulation
- Approximate loss probability, ruin probability and 95th-percentile drawdown
- Sharpe decay from Train to Out-of-Sample
- Automated research verdict: `PASS`, `WATCH`, `REJECT`, or `ERROR`

The default research gate checks:

```text
OOS minimum trade count
OOS profit factor
OOS Sharpe
OOS max drawdown
Walk-forward positive-window fraction
Parameter stability fraction
Monte Carlo ruin probability
```

### Phase 5 — Portfolio Research ✅
Phase 5 combines multiple validated strategies rather than betting on one backtest winner.

Implemented:
- Phase 4 verdict gate before portfolio inclusion
- Strategy equity-curve / return correlation matrix
- Inverse-volatility allocation with absolute-correlation penalty
- Maximum strategy-weight constraint
- Portfolio risk-contribution analysis
- Portfolio diversification ratio
- Effective number of strategies (concentration metric)
- Untouched OOS portfolio evaluation with frozen weights
- Portfolio-level Sharpe, volatility and max drawdown
- Block-bootstrap Monte Carlo for portfolio path risk
- Portfolio loss probability and ruin probability
- CSV exports for weights, candidates, correlation, OOS equity and summary

The allocation is intentionally simple and transparent. It does **not** maximize historical Sharpe, because unconstrained optimizers are highly sensitive to estimation error and can create unstable weights.

### Phase 6 — MT5 Paper Trading ✅
Phase 6 forward-tests the Phase 5 portfolio without sending real orders.

Implemented:
- Persistent JSON state with atomic writes
- Restart-safe `last_bar_time` checkpointing
- Idempotent processing so already-processed bars are not traded twice
- Phase 5 `portfolio_weights.csv` + `portfolio_candidates.csv` loader
- Uses the same selected strategy parameters and frozen weights from Phase 5
- Signal-at-close → next-completed-bar-open execution
- Fixed spread/slippage/commission paper fills
- Gap stop / gap take-profit handling
- Portfolio mark-to-market equity
- Daily-loss and max-drawdown portfolio kill switch
- Hard paper halt after a risk breach
- CSV event audit trail for `SIGNAL`, `ENTRY`, `EXIT`, and `HALT`
- Simulated forward slippage field in every entry/exit event
- MT5 completed-bar filter so the currently-forming candle is not traded
- `paper-demo`, `paper-mt5-once`, and `paper-mt5-daemon` modes
- Restart/idempotence/next-bar execution tests

Paper mode deliberately does not expose a broker execution path. The existing guarded MT5 `market_order()` adapter remains separate and cannot be reached from the Phase 6 CLI.

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

## Robust validation commands

Validate one candidate on synthetic regime-changing data:

```bash
python -m src.main --mode validate-demo --strategies ema_trend --bars 8000
```

Validate a shortlist:

```bash
python -m src.main --mode validate-demo --strategies ema_trend,trend_breakout,long_term_momentum --bars 12000
```

Validate all registered strategies on MT5 history:

```bash
python -m src.main --mode validate-mt5 --strategies all --bars 30000 --mc-runs 2000
```

## Portfolio research commands

Build a portfolio from strategies that receive `PASS` or `WATCH` under Phase 4:

```bash
python -m src.main --mode portfolio-mt5 \
  --strategies all \
  --bars 40000 \
  --mc-runs 2000 \
  --max-strategy-weight 0.35
```

Portfolio reports are written by default to:

```text
results/portfolio/portfolio_summary.csv
results/portfolio/portfolio_weights.csv
results/portfolio/strategy_correlation.csv
results/portfolio/portfolio_candidates.csv
results/portfolio/portfolio_oos_equity.csv
```

## Paper trading commands

Smoke-test the paper engine on synthetic data without needing Phase 5 files:

```bash
python -m src.main --mode paper-demo \
  --strategies ema_trend,trend_breakout,long_term_momentum \
  --bars 5000
```

Run exactly one MT5 paper polling cycle using the Phase 5 portfolio files:

```bash
python -m src.main --mode paper-mt5-once
```

Run the MT5 paper daemon until Ctrl+C:

```bash
python -m src.main --mode paper-mt5-daemon
```

Run a bounded daemon test for 5 polling cycles:

```bash
python -m src.main --mode paper-mt5-daemon \
  --paper-max-cycles 5 \
  --paper-poll-seconds 10
```

By default Phase 6 reads:

```text
results/portfolio/portfolio_weights.csv
results/portfolio/portfolio_candidates.csv
```

and writes:

```text
runtime/paper_state.json
runtime/paper_events.csv
```

The state file is persistent. Starting `paper-mt5-daemon` again continues from `last_bar_time` instead of replaying already-processed bars.

If the portfolio kill switch fires, `halted=true` is persisted and the daemon stops. Treat that as an incident requiring review; do not simply edit the state file to force it back on without understanding the breach.

## Research discipline

Do **not** select a strategy for live trading because it tops the current leaderboard. Testing many hypotheses creates multiple-testing and overfitting risk. The untouched Out-of-Sample segment should not be repeatedly reused for strategy development after its result is observed.

Portfolio weights are estimated from the pre-OOS segment only. The OOS segment is then used to evaluate the frozen portfolio. If portfolio rules are changed after looking at OOS results, that OOS segment is no longer genuinely untouched and a new holdout period is required.

Recommended workflow:

```text
Hypothesis
   ↓
In-sample screening
   ↓
Train / Validation selection
   ↓
Walk-forward + stability checks
   ↓
PASS / WATCH / REJECT
   ↓
Pre-OOS portfolio calibration
   ↓
Freeze strategy set + weights
   ↓
Untouched portfolio OOS
   ↓
Portfolio Monte Carlo / risk review
   ↓
Persistent MT5 paper-forward test
   ↓
Compare expected vs simulated execution
   ↓
Only consider guarded live if paper behavior remains credible
```

## Next phase

### Phase 7 — Guarded Small Live Deployment
Before enabling any live order path, the framework still needs:
- Broker-specific symbol/tick-value position sizing instead of a generic `$10/pip` assumption
- Lot-step/min/max-volume validation from MT5 symbol metadata
- Broker-supported filling-mode selection
- Dynamic spread and swap accounting
- Live/paper reconciliation
- Portfolio-level exposure and leverage caps
- Emergency flatten / kill switch
- Explicit operator arming step
- Very small initial capital and reversible deployment

## Important
This project is a research framework, not a guarantee of profit. Leveraged FX/CFD trading can lose money quickly. Spread, slippage, commission, swap, gaps, execution quality, leverage, model error and regime changes can materially alter live results versus backtests.
