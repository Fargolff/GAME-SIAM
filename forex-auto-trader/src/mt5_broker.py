from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone

import pandas as pd

try:
    import MetaTrader5 as mt5
except ImportError:  # pragma: no cover
    mt5 = None


_TIMEFRAMES = {
    "M1": "TIMEFRAME_M1",
    "M5": "TIMEFRAME_M5",
    "M15": "TIMEFRAME_M15",
    "M30": "TIMEFRAME_M30",
    "H1": "TIMEFRAME_H1",
    "H4": "TIMEFRAME_H4",
    "D1": "TIMEFRAME_D1",
}


@dataclass(frozen=True)
class BrokerOrder:
    symbol: str
    side: int
    lots: float
    stop_loss: float
    take_profit: float
    magic: int
    deviation_points: int = 20


class MT5Broker:
    def __init__(self) -> None:
        if mt5 is None:
            raise RuntimeError("MetaTrader5 package is not installed")
        self.connected = False

    def connect(self) -> None:
        if not mt5.initialize():
            raise RuntimeError(f"MT5 initialize failed: {mt5.last_error()}")
        self.connected = True

    def close(self) -> None:
        if self.connected:
            mt5.shutdown()
            self.connected = False

    def rates(self, symbol: str, timeframe: str, bars: int = 2000) -> pd.DataFrame:
        if timeframe not in _TIMEFRAMES:
            raise ValueError(f"unsupported timeframe: {timeframe}")
        tf = getattr(mt5, _TIMEFRAMES[timeframe])
        data = mt5.copy_rates_from_pos(symbol, tf, 0, bars)
        if data is None or len(data) == 0:
            raise RuntimeError(f"no MT5 rates for {symbol}: {mt5.last_error()}")

        df = pd.DataFrame(data)
        df["time"] = pd.to_datetime(df["time"], unit="s", utc=True)
        df = df.set_index("time")
        return df[["open", "high", "low", "close", "tick_volume", "spread"]]

    def account_equity(self) -> float:
        info = mt5.account_info()
        if info is None:
            raise RuntimeError(f"MT5 account_info failed: {mt5.last_error()}")
        return float(info.equity)

    def market_order(self, order: BrokerOrder, live_enabled: bool = False):
        if not live_enabled:
            raise RuntimeError("live trading is disabled in config")
        if order.side not in (-1, 1):
            raise ValueError("side must be -1 or 1")

        symbol_info = mt5.symbol_info(order.symbol)
        if symbol_info is None:
            raise RuntimeError(f"symbol not found: {order.symbol}")
        if not symbol_info.visible and not mt5.symbol_select(order.symbol, True):
            raise RuntimeError(f"unable to select symbol: {order.symbol}")

        tick = mt5.symbol_info_tick(order.symbol)
        if tick is None:
            raise RuntimeError(f"missing tick for {order.symbol}")

        is_buy = order.side == 1
        price = float(tick.ask if is_buy else tick.bid)
        order_type = mt5.ORDER_TYPE_BUY if is_buy else mt5.ORDER_TYPE_SELL
        request = {
            "action": mt5.TRADE_ACTION_DEAL,
            "symbol": order.symbol,
            "volume": float(order.lots),
            "type": order_type,
            "price": price,
            "sl": float(order.stop_loss),
            "tp": float(order.take_profit),
            "deviation": int(order.deviation_points),
            "magic": int(order.magic),
            "comment": "forex-auto-trader",
            "type_time": mt5.ORDER_TIME_GTC,
            "type_filling": mt5.ORDER_FILLING_IOC,
        }
        result = mt5.order_send(request)
        if result is None:
            raise RuntimeError(f"MT5 order_send returned None: {mt5.last_error()}")
        return result


def utc_now() -> datetime:
    return datetime.now(timezone.utc)
