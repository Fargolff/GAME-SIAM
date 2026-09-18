# Forex Auto Trader Research Framework

Personal research framework for automated Forex trading with a focus on reproducible experiments, cost-aware backtests, robust validation and portfolio-level risk control.

## Safety defaults
- Live trading is **disabled by default**.
- The CLI does not expose live order execution.
- Backtests include configurable spread, slippage and commission.
- Bar-close signals execute on the **next bar open** to avoid same-bar look-ahead optimism.
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
│  ├─ risk.py
│  ├─ backtest.py
│  ├─ mt5_broker.py
│  └─ main.py
└─ tests/
   ├─ test_backtest_execution.py
   ├─ test_data.py
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

Tune the robustness workload:

```bash
python -m src.main --mode validate-mt5 \
  --strategies ema_trend,donchian_breakout \
  --bars 30000 \
  --wf-train-bars 6000 \
  --wf-test-bars 1500 \
  --wf-step-bars 1500 \
  --param-perturbation 0.20 \
  --mc-runs 3000
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

Run the same pipeline on synthetic data:

```bash
python -m src.main --mode portfolio-demo \
  --strategies all \
  --bars 15000
```

For a pure pipeline smoke test, including rejected hypotheses is possible but should not be used as evidence of a deployable portfolio:

```bash
python -m src.main --mode portfolio-demo \
  --strategies all \
  --bars 15000 \
  --portfolio-verdicts PASS,WATCH,REJECT
```

Portfolio reports are written by default to:

```text
results/portfolio/portfolio_summary.csv
results/portfolio/portfolio_weights.csv
results/portfolio/strategy_correlation.csv
results/portfolio/portfolio_candidates.csv
results/portfolio/portfolio_oos_equity.csv
```

Phase 3 batch results:

```text
results/strategy_leaderboard.csv
```

Phase 4 validation results:

```text
results/robust_validation.csv
```

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
Paper trading only if still credible
```

## Next phases

### Phase 6 — Paper Trading
- MT5 paper-trading daemon
- Persistent position/order state
- Broker execution logging
- Backtest-vs-forward slippage comparison
- Health monitoring and alerts
- Restart/recovery handling
- Paper-trading portfolio risk controls

### Phase 7 — Guarded Small Live Deployment
Only after robust out-of-sample and paper validation. Live trading should remain small, capped and reversible with hard kill switches.

## Important
This project is a research framework, not a guarantee of profit. Leveraged FX/CFD trading can lose money quickly. Spread, slippage, commission, swap, gaps, execution quality, leverage, model error and regime changes can materially alter live results versus backtests.
