/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_MACD_Params_M5 : IndiMACDParams {
  Indi_MACD_Params_M5() : IndiMACDParams(indi_macd_defaults, PERIOD_M5) {
    applied_price = (ENUM_APPLIED_PRICE)0;
    ema_fast_period = 12;
    ema_slow_period = 26;
    shift = 0;
    signal_period = 9;
  }
} indi_macd_m5;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_MACD_Params_M5 : StgParams {
  // Struct constructor.
  Stg_MACD_Params_M5() : StgParams(stg_macd_defaults) {
    lot_size = 0;
    signal_open_method = 2;
    signal_open_level = (float)0;
    signal_open_boost = 0;
    signal_close_method = 2;
    signal_close_level = (float)0;
    price_profit_method = 60;
    price_profit_level = (float)6;
    price_stop_method = 60;
    price_stop_level = (float)6;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_macd_m5;
