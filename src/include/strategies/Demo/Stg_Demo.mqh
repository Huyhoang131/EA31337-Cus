/**
 * @file
 * Implements Demo strategy based on the Demo indicator.
 */

// User input params.
INPUT_GROUP("Demo strategy: strategy params");
INPUT float Demo_LotSize = 0;                // Lot size
INPUT int Demo_SignalOpenMethod = 0;         // Signal open method
INPUT float Demo_SignalOpenLevel = 0;        // Signal open level
INPUT int Demo_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT int Demo_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT int Demo_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT int Demo_SignalCloseMethod = 0;        // Signal close method
INPUT int Demo_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT float Demo_SignalCloseLevel = 0;       // Signal close level
INPUT int Demo_PriceStopMethod = 0;          // Price limit method
INPUT float Demo_PriceStopLevel = 2;         // Price limit level
INPUT int Demo_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT float Demo_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT short Demo_Shift = 0;                  // Shift
INPUT float Demo_OrderCloseLoss = 80;        // Order close loss
INPUT float Demo_OrderCloseProfit = 80;      // Order close profit
INPUT int Demo_OrderCloseTime = -30;         // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("Demo strategy: Demo indicator params");
INPUT int Demo_Indi_Demo_Shift = 0;                                        // Shift
INPUT ENUM_IDATA_SOURCE_TYPE Demo_Indi_Demo_SourceType = IDATA_INDICATOR;  // Source type

// Structs.

// Defines struct with default user strategy values.
struct Stg_Demo_Params_Defaults : StgParams {
  Stg_Demo_Params_Defaults()
      : StgParams(::Demo_SignalOpenMethod, ::Demo_SignalOpenFilterMethod, ::Demo_SignalOpenLevel,
                  ::Demo_SignalOpenBoostMethod, ::Demo_SignalCloseMethod, ::Demo_SignalCloseFilter,
                  ::Demo_SignalCloseLevel, ::Demo_PriceStopMethod, ::Demo_PriceStopLevel, ::Demo_TickFilterMethod,
                  ::Demo_MaxSpread, ::Demo_Shift) {
    Set(STRAT_PARAM_LS, Demo_LotSize);
    Set(STRAT_PARAM_OCL, Demo_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, Demo_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, Demo_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, Demo_SignalOpenFilterTime);
  }
};

class Stg_Demo : public Strategy {
 public:
  Stg_Demo(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Demo *Init(ENUM_TIMEFRAMES _tf = NULL, EA* _ea = NULL) {
    // Initialize strategy initial values.
    Stg_Demo_Params_Defaults stg_demo_defaults;
    StgParams _stg_params(stg_demo_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Demo(_stg_params, _tparams, _cparams, "Demo");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    // Initialize indicators.
    IndiDemoParams _indi_params(::Demo_Indi_Demo_Shift);
    _indi_params.SetTf(Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF));
    SetIndicator(new Indi_Demo(_indi_params));
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    Indi_Demo *_indi = GetIndicator();
    bool _result =
        _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift) && _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift + 1);
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    IndicatorSignal _signals = _indi.GetSignals(4, _shift);
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        // Buy signal.
        _result &= _indi.IsIncreasing(1, 0, _shift);
        _result &= _indi.IsIncByPct(_level / 10, 0, _shift, 2);
        _result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
        break;
      case ORDER_TYPE_SELL:
        // Sell signal.
        _result &= _indi.IsDecreasing(1, 0, _shift);
        _result &= _indi.IsDecByPct(_level / 10, 0, _shift, 2);
        _result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
        break;
    }
    return _result;
  }
};
