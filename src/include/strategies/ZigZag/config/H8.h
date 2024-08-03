/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_ZigZag_Params_H8 : IndiZigZagParams {
  Indi_ZigZag_Params_H8() : IndiZigZagParams(indi_zigzag_defaults, PERIOD_H8) {
    backstep = 3;
    depth = 12;
    deviation = 5;
    shift = 0;
  }
} indi_zigzag_h8;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_ZigZag_Params_H8 : StgParams {
  // Struct constructor.
  Stg_ZigZag_Params_H8() : StgParams(stg_zigzag_defaults) {
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
} stg_zigzag_h8;
