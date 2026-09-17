from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
import pandas as pd

from .backtest import BacktestConfig, run_backtest
from .config import load_config
from .mt5_broker import MT5Broker
from .strategy import ema_trend_signals


def _synthetic_data(rows: int = 3000, seed: int = 42) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    idx = pd.date_range("2024-01-01", periods=rows, freq="h", tz="UTC")
    drift = 0.000002
    noise = rng.normal(0, 0.0006, rows)
    close = 1.10 + np.cumsum(drift + noise)
    high = close + rng.uniform(0.0001, 0.0008, rows)
    low = close - rng.uniform(0.0001, 0.0008, rows)
    open_ = np.r_[close[0], close[:-1]]
    return pd.DataFrame({"open": open_, "high": high, "low": low, "close": close}, index=idx)


def _prepare_signals(df: pd.DataFrame, cfg):
    s = cfg.strategy
    if s.name != "ema_trend":
        raise ValueError(f"unsupported strategy: {s.name}")
    return ema_trend_signals(
        df,
        fast=s.fast,
        slow=s.slow,
        atr_period=s.atr_period,
        stop_atr=s.stop_atr,
        take_profit_atr=s.take_profit_atr,
    )


def _backtest_config(cfg) -> BacktestConfig:
    return BacktestConfig(
        initial_equity=cfg.initial_equity,
        risk_per_trade=cfg.risk_per_trade,
        max_daily_loss_pct=cfg.max_daily_loss_pct,
        max_drawdown_pct=cfg.max_drawdown_pct,
        spread_pips=cfg.spread_pips,
        slippage_pips=cfg.slippage_pips,
        commission_per_lot_round_turn=cfg.commission_per_lot_round_turn,
    )


def print_report(result: dict) -> None:
    print("\n=== BACKTEST SUMMARY ===")
    print(f"Initial equity : {result['initial_equity']:.2f}")
    print(f"Final equity   : {result['final_equity']:.2f}")
    print(f"Net profit     : {result['net_profit']:.2f}")
    print(f"Return         : {result['return_pct'] * 100:.2f}%")
    print(f"Max drawdown   : {result['max_drawdown_pct'] * 100:.2f}%")
    print(f"Sharpe approx. : {result['sharpe_approx']:.2f}")
    print(f"Trades         : {result['trades']}")
    print(f"Win rate       : {result['win_rate'] * 100:.2f}%")
    print(f"Profit factor  : {result['profit_factor']:.2f}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Personal Forex auto-trading research framework")
    parser.add_argument("--config", default="config.yaml")
    parser.add_argument(
        "--mode",
        choices=["demo-backtest", "mt5-backtest"],
        default="demo-backtest",
        help="Live order execution is intentionally not exposed by this CLI in MVP.",
    )
    parser.add_argument("--bars", type=int, default=5000)
    args = parser.parse_args()

    config_path = Path(args.config)
    if not config_path.exists():
        fallback = Path("config.example.yaml")
        if not fallback.exists():
            raise FileNotFoundError("config.yaml or config.example.yaml is required")
        config_path = fallback

    cfg = load_config(config_path)

    if args.mode == "demo-backtest":
        raw = _synthetic_data(args.bars)
    else:
        broker = MT5Broker()
        broker.connect()
        try:
            raw = broker.rates(cfg.symbol, cfg.timeframe, bars=args.bars)
        finally:
            broker.close()

    signals = _prepare_signals(raw, cfg)
    result = run_backtest(signals, _backtest_config(cfg))
    print_report(result)


if __name__ == "__main__":
    main()
