from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

import yaml


@dataclass(frozen=True)
class StrategyConfig:
    name: str = "ema_trend"
    fast: int = 20
    slow: int = 50
    atr_period: int = 14
    stop_atr: float = 2.0
    take_profit_atr: float = 3.0


@dataclass(frozen=True)
class LiveConfig:
    enabled: bool = False
    magic: int = 56001
    deviation_points: int = 20


@dataclass(frozen=True)
class AppConfig:
    mode: str = "backtest"
    symbol: str = "EURUSD"
    timeframe: str = "H1"
    initial_equity: float = 10_000.0
    risk_per_trade: float = 0.005
    max_daily_loss_pct: float = 0.02
    max_drawdown_pct: float = 0.10
    spread_pips: float = 0.8
    slippage_pips: float = 0.2
    commission_per_lot_round_turn: float = 7.0
    strategy: StrategyConfig = StrategyConfig()
    live: LiveConfig = LiveConfig()


def _strategy(data: dict[str, Any]) -> StrategyConfig:
    return StrategyConfig(**data)


def _live(data: dict[str, Any]) -> LiveConfig:
    return LiveConfig(**data)


def load_config(path: str | Path = "config.yaml") -> AppConfig:
    raw = yaml.safe_load(Path(path).read_text(encoding="utf-8")) or {}
    strategy = _strategy(raw.pop("strategy", {}))
    live = _live(raw.pop("live", {}))
    return AppConfig(strategy=strategy, live=live, **raw)
