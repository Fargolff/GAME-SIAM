from __future__ import annotations

from dataclasses import dataclass

import numpy as np
import pandas as pd

from .risk import RiskLimits, kill_switch_triggered, position_size_lots


@dataclass(frozen=True)
class BacktestConfig:
    initial_equity: float = 10_000.0
    risk_per_trade: float = 0.005
    max_daily_loss_pct: float = 0.02
    max_drawdown_pct: float = 0.10
    pip_size: float = 0.0001
    pip_value_per_lot: float = 10.0
    spread_pips: float = 0.8
    slippage_pips: float = 0.2
    commission_per_lot_round_turn: float = 7.0
    periods_per_year: float = 252.0 * 24.0


@dataclass
class Trade:
    entry_time: pd.Timestamp
    exit_time: pd.Timestamp
    side: int
    entry: float
    exit: float
    lots: float
    pnl: float
    reason: str


def _entry_price(close: float, side: int, cfg: BacktestConfig) -> float:
    half_spread = (cfg.spread_pips * cfg.pip_size) / 2
    slip = cfg.slippage_pips * cfg.pip_size
    return close + side * (half_spread + slip)


def _exit_price(close: float, side: int, cfg: BacktestConfig) -> float:
    half_spread = (cfg.spread_pips * cfg.pip_size) / 2
    slip = cfg.slippage_pips * cfg.pip_size
    return close - side * (half_spread + slip)


def run_backtest(df: pd.DataFrame, cfg: BacktestConfig) -> dict:
    required = {"open", "high", "low", "close", "signal", "stop_distance", "take_profit_distance"}
    missing = required.difference(df.columns)
    if missing:
        raise ValueError(f"missing columns: {sorted(missing)}")
    if cfg.periods_per_year <= 0:
        raise ValueError("periods_per_year must be positive")

    equity = cfg.initial_equity
    peak_equity = equity
    start_of_day_equity = equity
    current_day = None
    position = None
    trades: list[Trade] = []
    equity_curve: list[tuple[pd.Timestamp, float]] = []

    limits = RiskLimits(
        risk_per_trade=cfg.risk_per_trade,
        max_daily_loss_pct=cfg.max_daily_loss_pct,
        max_drawdown_pct=cfg.max_drawdown_pct,
    )

    for ts, row in df.iterrows():
        day = ts.date() if hasattr(ts, "date") else None
        if day != current_day:
            current_day = day
            start_of_day_equity = equity

        killed, _reason = kill_switch_triggered(start_of_day_equity, peak_equity, equity, limits)
        if killed:
            equity_curve.append((ts, equity))
            continue

        if position is not None:
            side = position["side"]
            stop = position["stop"]
            tp = position["tp"]
            exit_reason = None
            raw_exit = None

            # Stop is checked first when both stop and take-profit are touched inside
            # the same OHLC bar. This is intentionally conservative because intrabar
            # path is unknown without higher-frequency data.
            if side > 0:
                if row["low"] <= stop:
                    raw_exit, exit_reason = stop, "stop"
                elif row["high"] >= tp:
                    raw_exit, exit_reason = tp, "take_profit"
            else:
                if row["high"] >= stop:
                    raw_exit, exit_reason = stop, "stop"
                elif row["low"] <= tp:
                    raw_exit, exit_reason = tp, "take_profit"

            if exit_reason is None and int(row["signal"]) == -side:
                raw_exit, exit_reason = float(row["close"]), "opposite_signal"

            if exit_reason is not None:
                exit_price = _exit_price(float(raw_exit), side, cfg)
                price_delta = (exit_price - position["entry"]) * side
                pnl_pips = price_delta / cfg.pip_size
                gross = pnl_pips * cfg.pip_value_per_lot * position["lots"]
                commission = cfg.commission_per_lot_round_turn * position["lots"]
                pnl = gross - commission
                equity += pnl
                trades.append(
                    Trade(
                        entry_time=position["entry_time"],
                        exit_time=ts,
                        side=side,
                        entry=position["entry"],
                        exit=exit_price,
                        lots=position["lots"],
                        pnl=pnl,
                        reason=exit_reason,
                    )
                )
                position = None
                peak_equity = max(peak_equity, equity)

        signal = int(row["signal"])
        if position is None and signal != 0 and pd.notna(row["stop_distance"]):
            stop_distance = float(row["stop_distance"])
            tp_distance = float(row["take_profit_distance"])
            lots = position_size_lots(
                equity=equity,
                risk_per_trade=cfg.risk_per_trade,
                stop_distance_price=stop_distance,
                pip_size=cfg.pip_size,
                pip_value_per_lot=cfg.pip_value_per_lot,
            )
            if lots > 0:
                entry = _entry_price(float(row["close"]), signal, cfg)
                position = {
                    "entry_time": ts,
                    "side": signal,
                    "entry": entry,
                    "lots": lots,
                    "stop": entry - signal * stop_distance,
                    "tp": entry + signal * tp_distance,
                }

        equity_curve.append((ts, equity))

    curve = pd.Series(
        [x[1] for x in equity_curve],
        index=[x[0] for x in equity_curve],
        name="equity",
        dtype=float,
    )
    returns = curve.pct_change().fillna(0.0)
    max_dd = ((curve.cummax() - curve) / curve.cummax()).max() if len(curve) else 0.0
    annualized_sharpe = 0.0
    if returns.std(ddof=0) > 0:
        annualized_sharpe = np.sqrt(cfg.periods_per_year) * returns.mean() / returns.std(ddof=0)

    pnl_values = [t.pnl for t in trades]
    wins = [x for x in pnl_values if x > 0]
    losses = [x for x in pnl_values if x < 0]
    gross_profit = sum(wins)
    gross_loss = abs(sum(losses))

    return {
        "initial_equity": cfg.initial_equity,
        "final_equity": equity,
        "net_profit": equity - cfg.initial_equity,
        "return_pct": (equity / cfg.initial_equity - 1) if cfg.initial_equity else 0.0,
        "max_drawdown_pct": float(max_dd),
        "sharpe_approx": float(annualized_sharpe),
        "trades": len(trades),
        "win_rate": (len(wins) / len(trades)) if trades else 0.0,
        "profit_factor": (gross_profit / gross_loss) if gross_loss > 0 else float("inf") if gross_profit > 0 else 0.0,
        "trade_log": trades,
        "equity_curve": curve,
    }
