/**
 * @file
 * Implements TMAT SVEBB strategy.
 *
 * @see: https://www.forexstrategiesresources.com/trading-system-metatrader-4-iii/397-tma-band-true/
 */

// Includes conditional compilation directives.
#include "config/define.h"

// Includes EA31337 framework.
#include <EA31337-classes/EA.mqh>
#include <EA31337-classes/Indicator.mqh>
#include <EA31337-classes/Indicators/Indi_MA.mqh>
#include <EA31337-classes/Strategy.mqh>

// Inputs.
input int Active_Tfs = M15B + M30B + H1B + H2B + H3B + H4B + H6B +
                       H8B;               // Timeframes (M1=1,M2=2,M5=16,M15=256,M30=1024,H1=2048,H2=4096,H3,H4,H6,H8)
input ENUM_LOG_LEVEL Log_Level = V_INFO;  // Log level.
input bool Info_On_Chart = true;          // Display info on chart.

// Includes main strategy class.
#include "Stg_TMAT_SVEBB.mqh"

// Defines.
#define ea_name "Strategy TMA SVEBB"
#define ea_version "2.000"
#define ea_desc "Strategy based on EA31337 framework."
#define ea_link "https://github.com/EA31337/Strategy-TMAT_SVEBB"
#define ea_author "EA31337 Ltd"

// Properties.
#property version ea_version
#ifdef __MQL4__
#property description ea_name
#property description ea_desc
#endif
#property link ea_link
#ifdef __resource__
#ifdef __MQL5__
#property tester_indicator "::" + INDI_SVEBB_PATH + "\\SVE_Bollinger_Bands.ex5"
#property tester_indicator "::" + INDI_TMA_TRUE_PATH + "\\TMA_True.ex5"
#endif
#endif

// Load external resources.
#ifdef __resource__
#ifdef __MQL5__
#resource INDI_SVEBB_PATH + "\\SVE_Bollinger_Bands.ex5"
#resource INDI_TMA_TRUE_PATH + "\\TMA_True.ex5"
#endif
#endif

// Class variables.
EA *ea;

/* EA event handler functions */

/**
 * Implements "Init" event handler function.
 *
 * Invoked once on EA startup.
 */
int OnInit() {
  bool _result = true;
  EAParams ea_params(__FILE__, Log_Level);
  ea = new EA(ea_params);
  _result &= ea.StrategyAdd<Stg_TMAT_SVEBB>(Active_Tfs);
  return (_result ? INIT_SUCCEEDED : INIT_FAILED);
}

/**
 * Implements "Tick" event handler function (EA only).
 *
 * Invoked when a new tick for a symbol is received, to the chart of which the
 * Expert Advisor is attached.
 */
void OnTick() {
  ea.ProcessTick();
  if (!ea.GetTerminal().IsOptimization()) {
    ea.UpdateInfoOnChart();
  }
}

/**
 * Implements "Deinit" event handler function.
 *
 * Invoked once on EA exit.
 */
void OnDeinit(const int reason) { Object::Delete(ea); }
