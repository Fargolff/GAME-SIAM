from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
import pandas as pd

from .backtest import BacktestConfig, run_backtest
from .config import load_config
from .data import MarketDataStore, normalize_ohlc
from .mt5_broker import MT5Broker
from .research import run_strategy_batch, save_research_results
from .strategy import available_strategies, build_signals, strategy_spec


def _synthetic_data(rows: int = 3000, seed: int = 42) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    idx = pd.date_range("2024-01-01", periods=rows, freq="h", tz="UTC")

    # Regime-changing toy series: alternating drift and volatility make it harder
    # for a single strategy family to dominate every segment.
    segment = np.arange(rows) // max(rows // 6, 1)
    drift = np.where(segment % 3 == 0, 0.000015, np.where(segment % 3 == 1, -0.000010, 0.0))
    volatility = np.where(segment % 2 == 0, 0.00045, 0.00080)
    noise = rng.normal(0.0, volatility, rows)
    close = 1.10 + np.cumsum(drift + noise)
    open_ = np.r_[close[0], close[:-1]]
    upper_wick = rng.uniform(0.0001, 0.0007, rows)
    lower_wick = rng.uniform(0.0001, 0.0007, rows)
    high = np.maximum(open_, close) + upper_wick
    low = np.minimum(open_, close) - lower_wick
    return normalize_ohlc(pd.DataFrame({"open": open_, "high": high, "low": low, "close": close}, index=idx))


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


def _mt5_data(cfg, bars: int) -> pd.DataFrame:
    broker = MT5Broker()
    broker.connect()
    try:
        return normalize_ohlc(broker.rates(cfg.symbol, cfg.timeframe, bars=bars))
    finally:
        broker.close()


def _selected_strategy_names(value: str) -> list[str]:
    if value.strip().lower() == "all":
        return available_strategies()
    names = [x.strip() for x in value.split(",") if x.strip()]
    unknown = sorted(set(names).difference(available_strategies()))
    if unknown:
        raise ValueError(f"unknown strategies: {unknown}; available={available_strategies()}")
    return names


def print_report(result: dict, strategy_name: str) -> None:
    print(f"\n=== BACKTEST SUMMARY: {strategy_name} ===")
    print(f"Initial equity : {result['initial_equity']:.2f}")
    print(f"Final equity   : {result['final_equity']:.2f}")
    print(f"Net profit     : {result['net_profit']:.2f}")
    print(f"Return         : {result['return_pct'] * 100:.2f}%")
    print(f"Max drawdown   : {result['max_drawdown_pct'] * 100:.2f}%")
    print(f"Sharpe approx. : {result['sharpe_approx']:.2f}")
    print(f"Trades         : {result['trades']}")
    print(f"Win rate       : {result['win_rate'] * 100:.2f}%")
    print(f"Profit factor  : {result['profit_factor']:.2f}")


def print_catalog() -> None:
    print("\n=== STRATEGY CATALOG ===")
    for name in available_strategies():
        spec = strategy_spec(name)
        print(f"{name:24s} [{spec.family:15s}] {spec.description}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Personal Forex auto-trading research framework")
    parser.add_argument("--config", default="config.yaml")
    parser.add_argument(
        "--mode",
        choices=[
            "demo-backtest",
            "mt5-backtest",
            "batch-demo",
            "batch-mt5",
            "cache-mt5",
            "list-strategies",
        ],
        default="demo-backtest",
        help="Live order execution remains intentionally unavailable from this CLI.",
    )
    parser.add_argument("--bars", type=int, default=5000)
    parser.add_argument("--strategy", default=None, help="Override config strategy for a single backtest.")
    parser.add_argument("--strategies", default="all", help="Comma-separated names or 'all' for batch modes.")
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--save-data", action="store_true", help="Cache loaded bars under data_dir.")
    parser.add_argument("--output", default="results/strategy_leaderboard.csv")
    args = parser.parse_args()

    if args.mode == "list-strategies":
        print_catalog()
        return

    config_path = Path(args.config)
    if not config_path.exists():
        fallback = Path("config.example.yaml")
        if not fallback.exists():
            raise FileNotFoundError("config.yaml or config.example.yaml is required")
        config_path = fallback

    cfg = load_config(config_path)
    store = MarketDataStore(cfg.data_dir)

    if args.mode in {"demo-backtest", "batch-demo"}:
        raw = _synthetic_data(args.bars, seed=args.seed)
    else:
        raw = _mt5_data(cfg, args.bars)

    if args.save_data or args.mode == "cache-mt5":
        path = store.upsert(cfg.symbol, cfg.timeframe, raw)
        print(f"Cached {len(raw)} bars -> {path}")
        if args.mode == "cache-mt5":
            print(store.coverage(cfg.symbol, cfg.timeframe))
            return

    bt_cfg = _backtest_config(cfg)

    if args.mode in {"batch-demo", "batch-mt5"}:
        names = _selected_strategy_names(args.strategies)
        results = run_strategy_batch(raw, bt_cfg, names)
        path = save_research_results(results, args.output)
        display = results.copy()
        for col in ("return_pct", "max_drawdown_pct", "win_rate"):
            if col in display:
                display[col] = display[col] * 100.0
        print("\n=== RESEARCH LEADERBOARD ===")
        print(display.to_string(index=False))
        print(f"\nSaved leaderboard -> {path}")
        print("NOTE: in-sample rank is only a screening tool, not evidence of a durable edge.")
        return

    strategy_name = args.strategy or cfg.strategy.name
    params = cfg.strategy.params if args.strategy is None else {}
    signals = build_signals(raw, strategy_name, params)
    result = run_backtest(signals, bt_cfg)
    print_report(result, strategy_name)


if __name__ == "__main__":
    main()
