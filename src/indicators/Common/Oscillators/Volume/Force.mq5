//+------------------------------------------------------------------+
//|                                               EA31337 indicators |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

/**
 * @file
 * Implements Force Index (FI) indicator.
 */

// Defines.
#define INDI_FULL_NAME "Force Index"
#define INDI_SHORT_NAME "Force"

// Indicator properties.
#ifdef __MQL__
#property copyright "2016-2023, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description INDI_FULL_NAME
//--
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots 1
#property indicator_type1 DRAW_LINE
#property indicator_color1 DodgerBlue
#property indicator_label1 INDI_SHORT_NAME
#property version "1.000"
#endif

// Resource files.
#ifdef __MQL5__
#property tester_indicator "::Indicators\\Examples\\Force_Index.ex5"
#resource "\\Indicators\\Examples\\Force_Index.ex5"
#endif

// Includes.
#include <EA31337-classes/Indicators/Indi_Force.mqh>

// Input parameters.
input int InpForcePeriod = 13;                              // Period
input ENUM_MA_METHOD InpMAMethod = MODE_SMA;                // MA method
input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_CLOSE;     // Applied price
input ENUM_APPLIED_VOLUME InpAppliedVolume = VOLUME_TICK;   // Volumes
input ENUM_APPLIED_PRICE InpMAAppliedPrice = PRICE_OPEN;    // Applied price
input int InpShift = 0;                                     // Indicator shift
input ENUM_IDATA_SOURCE_TYPE InpSourceType = IDATA_BUILTIN; // Source type

// Global indicator buffers.
double ExtMABuffer[];

// Global variables.
Indi_Force *indi;

/**
 * Init event handler function.
 */
void OnInit() {
  // Initialize indicator buffers.
  SetIndexBuffer(0, ExtMABuffer, INDICATOR_DATA);
  // Initialize indicator.
  IndiForceParams _indi_params(::InpForcePeriod, ::InpMAMethod,
                               ::InpMAAppliedPrice, ::InpShift);
  indi = new Indi_Force(_indi_params /* , InpSourceType */);
  // Name for labels.
  // @todo: Use serialized string of _indi_params.
  string short_name = StringFormat("%s(%d)", indi.GetName(), ::InpForcePeriod);
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, DBL_MAX);
  // Sets first bar from what index will be drawn
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, ::InpForcePeriod - 1);
  // Sets indicator shift.
  PlotIndexSetInteger(0, PLOT_SHIFT, InpShift);
}

/**
 * Calculate event handler function.
 */
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
  int i, start;
  if (rates_total < InpForcePeriod) {
    return (0);
  }
  // Initialize calculations.
  start = prev_calculated == 0 ? InpForcePeriod - 1 : prev_calculated - 1;
  if (prev_calculated == 0) {
    for (i = 0; i <= start; i++) {
      ExtMABuffer[i] = close[i];
    }
  }
  // Main calculations.
  for (i = start; i < rates_total && !IsStopped(); i++) {
    IndicatorDataEntry _entry = indi[rates_total - i];
    if (!indi.Get<bool>(
            STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
      return prev_calculated + 1;
    }
    ExtMABuffer[i] = _entry[0];
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete indi; }
