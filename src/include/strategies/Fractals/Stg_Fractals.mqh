/**
 * @file
 * Implements Fractals strategy.
 */

// User input params.
INPUT_GROUP("Fractals strategy: strategy params");
INPUT float Fractals_LotSize = 0;                // Lot size
int Fractals_SignalOpenMethod = 0;               // Signal open method (-127-127)
float Fractals_SignalOpenLevel = 0.0f;           // Signal open level
INPUT int Fractals_SignalOpenFilterMethod = 43;  // Signal open filter method
INPUT int Fractals_SignalOpenFilterTime = 3;     // Signal open filter time
INPUT int Fractals_SignalOpenBoostMethod = 0;    // Signal open boost method
int Fractals_SignalCloseMethod = 0;              // Signal close method (-127-127)
INPUT int Fractals_SignalCloseFilter = 16;       // Signal close filter (-127-127)
float Fractals_SignalCloseLevel = 0.0f;          // Signal close level
INPUT int Fractals_PriceStopMethod = 16;         // Price stop method (0-127)
INPUT float Fractals_PriceStopLevel = 2;         // Price stop level
INPUT int Fractals_TickFilterMethod = 32;        // Tick filter method
INPUT float Fractals_MaxSpread = 4.0;            // Max spread to trade (pips)
INPUT short Fractals_Shift = 0;                  // Shift
INPUT float Fractals_OrderCloseLoss = 80;        // Order close loss
INPUT float Fractals_OrderCloseProfit = 80;      // Order close profit
INPUT int Fractals_OrderCloseTime = -30;         // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("Fractals strategy: Fractals indicator params");
INPUT int Fractals_Indi_Fractals_Shift = 0;  // Shift

// Structs.

// Defines struct with default user strategy values.
struct Stg_Fractals_Params_Defaults : StgParams {
  Stg_Fractals_Params_Defaults()
      : StgParams(::Fractals_SignalOpenMethod, ::Fractals_SignalOpenFilterMethod, ::Fractals_SignalOpenLevel,
                  ::Fractals_SignalOpenBoostMethod, ::Fractals_SignalCloseMethod, ::Fractals_SignalCloseFilter,
                  ::Fractals_SignalCloseLevel, ::Fractals_PriceStopMethod, ::Fractals_PriceStopLevel,
                  ::Fractals_TickFilterMethod, ::Fractals_MaxSpread, ::Fractals_Shift) {
    Set(STRAT_PARAM_LS, Fractals_LotSize);
    Set(STRAT_PARAM_OCL, Fractals_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, Fractals_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, Fractals_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, Fractals_SignalOpenFilterTime);
  }
};

#ifdef __config__
// Loads pair specific param values.
#include "config/H1.h"
#include "config/H4.h"
#include "config/H8.h"
#include "config/M1.h"
#include "config/M15.h"
#include "config/M30.h"
#include "config/M5.h"
#endif

class Stg_Fractals : public Strategy {
 public:
  Stg_Fractals(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Fractals *Init(ENUM_TIMEFRAMES _tf = NULL, EA* _ea = NULL) {
    // Initialize strategy initial values.
    Stg_Fractals_Params_Defaults stg_fractals_defaults;
    StgParams _stg_params(stg_fractals_defaults);
#ifdef __config__
    SetParamsByTf<StgParams>(_stg_params, _tf, stg_fractals_m1, stg_fractals_m5, stg_fractals_m15, stg_fractals_m30,
                             stg_fractals_h1, stg_fractals_h4, stg_fractals_h8);
#endif
    // Initialize indicator.
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Fractals(_stg_params, _tparams, _cparams, "Fractals");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    IndiFractalsParams _indi_params(::Fractals_Indi_Fractals_Shift);
    _indi_params.SetTf(Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF));
    SetIndicator(new Indi_Fractals(_indi_params));
  }

  /**
   * Check if Fractals indicator is on buy or sell.
   *
   * @param
   *   _cmd (int) - type of trade order command
   *   period (int) - period to check for
   *   _method (int) - signal method to use by using bitwise AND operation
   *   _level (double) - signal level to consider the signal
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indi_Fractals *_indi = GetIndicator();
    Chart *_chart = (Chart *)_indi;
    bool _result = _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift);
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    IndicatorSignal _signals = _indi.GetSignals(4, _shift);
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result = _indi[_shift][(int)LINE_LOWER] != 0.0;
        _result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
        break;
      case ORDER_TYPE_SELL:
        _result = _indi[_shift][(int)LINE_UPPER] != 0.0;
        _result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
        break;
    }
    return _result;
  }
};
