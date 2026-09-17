from __future__ import annotations

from dataclasses import dataclass

import numpy as np
import pandas as pd


@dataclass(frozen=True)
class Signal:
    side: int  # -1 short, 0 flat, +1 long
    stop_distance: float
    take_profit_distance: float


def atr(df: pd.DataFrame, period: int = 14) -> pd.Series:
    prev_close = df["close"].shift(1)
    tr = pd.concat(
        [
            df["high"] - df["low"],
            (df["high"] - prev_close).abs(),
            (df["low"] - prev_close).abs(),
        ],
        axis=1,
    ).max(axis=1)
    return tr.ewm(alpha=1 / period, adjust=False, min_periods=period).mean()


def ema_trend_signals(
    df: pd.DataFrame,
    fast: int = 20,
    slow: int = 50,
    atr_period: int = 14,
    stop_atr: float = 2.0,
    take_profit_atr: float = 3.0,
) -> pd.DataFrame:
    if fast >= slow:
        raise ValueError("fast EMA must be smaller than slow EMA")
    if len(df) < max(slow, atr_period) + 2:
        raise ValueError("not enough bars for requested indicators")

    out = df.copy()
    out["ema_fast"] = out["close"].ewm(span=fast, adjust=False).mean()
    out["ema_slow"] = out["close"].ewm(span=slow, adjust=False).mean()
    out["atr"] = atr(out, atr_period)

    trend = np.sign(out["ema_fast"] - out["ema_slow"])
    prev_trend = trend.shift(1).fillna(0)
    out["signal"] = 0
    out.loc[(trend > 0) & (prev_trend <= 0), "signal"] = 1
    out.loc[(trend < 0) & (prev_trend >= 0), "signal"] = -1

    out["stop_distance"] = out["atr"] * stop_atr
    out["take_profit_distance"] = out["atr"] * take_profit_atr
    return out
