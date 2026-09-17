# Forex Auto Trader MVP

Personal research framework for automated Forex trading.

## Safety defaults
- Live trading is **disabled by default**.
- Backtests include configurable spread, slippage and commission.
- Position sizing is risk-based.
- Daily loss and max drawdown kill-switches are part of the design.

## Architecture

```text
forex-auto-trader/
├─ config.example.yaml
├─ requirements.txt
├─ src/
│  ├─ config.py
│  ├─ strategy.py
│  ├─ risk.py
│  ├─ backtest.py
│  ├─ mt5_broker.py
│  └─ main.py
└─ tests/
   └─ test_risk.py
```

## Phase roadmap
1. Data + reproducible backtest engine
2. Strategy hypothesis library
3. Walk-forward / out-of-sample validation
4. Monte Carlo + robustness tests
5. MT5 paper execution
6. Small-size live deployment
7. Monitoring, kill-switches and experiment tracking

## Quick start

```bash
cd forex-auto-trader
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
copy config.example.yaml config.yaml
python -m src.main --mode demo-backtest
```

## Important
This project is a research framework, not a guarantee of profit. Leveraged FX/CFD trading can produce losses greater than expected if risk controls, broker execution, slippage, swap and gap risk are ignored.
