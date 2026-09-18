from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import yaml


@dataclass(frozen=True)
class StrategyConfig:
    name: str = "ema_trend"
    params: dict[str, Any] = field(default_factory=dict)


@dataclass(frozen=True)
class LiveConfig:
    enabled: bool = False
    magic: int = 56001
    deviation_points: int = 20


@dataclass(frozen=True)
class PaperRuntimeConfig:
    state_path: str = "runtime/paper_state.json"
    events_path: str = "runtime/paper_events.csv"
    weights_path: str = "results/portfolio/portfolio_weights.csv"
    candidates_path: str = "results/portfolio/portfolio_candidates.csv"
    poll_seconds: int = 30
    history_bars: int = 5000


@dataclass(frozen=True)
class AppConfig:
    mode: str = "backtest"
    symbol: str = "EURUSD"
    timeframe: str = "H1"
    data_dir: str = "data"
    initial_equity: float = 10_000.0
    risk_per_trade: float = 0.005
    max_daily_loss_pct: float = 0.02
    max_drawdown_pct: float = 0.10
    spread_pips: float = 0.8
    slippage_pips: float = 0.2
    commission_per_lot_round_turn: float = 7.0
    strategy: StrategyConfig = field(default_factory=StrategyConfig)
    paper: PaperRuntimeConfig = field(default_factory=PaperRuntimeConfig)
    live: LiveConfig = field(default_factory=LiveConfig)


def _strategy(data: dict[str, Any]) -> StrategyConfig:
    raw = dict(data or {})
    name = str(raw.pop("name", "ema_trend"))
    explicit_params = raw.pop("params", {}) or {}
    if not isinstance(explicit_params, dict):
        raise ValueError("strategy.params must be a mapping")

    # Backward compatible with Phase-1 YAML where fast/slow/etc. lived directly
    # under `strategy:`. Explicit `params:` wins on duplicate keys.
    params = {**raw, **explicit_params}
    return StrategyConfig(name=name, params=params)


def _paper(data: dict[str, Any]) -> PaperRuntimeConfig:
    cfg = PaperRuntimeConfig(**(data or {}))
    if cfg.poll_seconds < 1:
        raise ValueError("paper.poll_seconds must be >= 1")
    if cfg.history_bars < 100:
        raise ValueError("paper.history_bars must be >= 100")
    return cfg


def _live(data: dict[str, Any]) -> LiveConfig:
    return LiveConfig(**(data or {}))


def load_config(path: str | Path = "config.yaml") -> AppConfig:
    raw = yaml.safe_load(Path(path).read_text(encoding="utf-8")) or {}
    if not isinstance(raw, dict):
        raise ValueError("top-level YAML config must be a mapping")
    raw = dict(raw)
    strategy = _strategy(raw.pop("strategy", {}))
    paper = _paper(raw.pop("paper", {}))
    live = _live(raw.pop("live", {}))
    return AppConfig(strategy=strategy, paper=paper, live=live, **raw)
