#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|Include Files                                                     |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//|Input Variables                                                   |
//+------------------------------------------------------------------+
input int inpFastPeriod = 14; //fast period
input int inpSlowPeriod = 21; //slow period
input int inpStopLoss = 100;  //stopLoss in pips
input int inpTakeProfit = 200;
//+------------------------------------------------------------------+
//|Global Variables                                                   |
//+------------------------------------------------------------------+
int fastHandle;
int slowHandle;
double fastBuffer[];
double slowBuffer[];
datetime openTimeBuy = 0;
datetime openTimeSell = 0;
CTrade trade;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   //Checking user input
   if(inpFastPeriod<=0){
      Alert("Fast Period <= 0");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(inpSlowPeriod<=0){
      Alert("slow Period <= 0");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(inpFastPeriod >= inpSlowPeriod){
      Alert("Fast Period >= slow period");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(inpStopLoss<=0){
      Alert("Stop Loss <= 0");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(inpTakeProfit<=0){
      Alert("Take Profit <= 0");
   }
   
   //creating Handles
   //fast handle
   fastHandle = iMA(_Symbol,PERIOD_CURRENT,inpFastPeriod,0,MODE_SMA,PRICE_CLOSE);
   if(fastHandle == INVALID_HANDLE){
      Alert("Failed to create fast Handle");
      return INIT_FAILED;
   }
   //slow handle
   slowHandle = iMA(_Symbol,PERIOD_CURRENT,inpSlowPeriod,0,MODE_SMA,PRICE_CLOSE);
   if(slowHandle == INVALID_HANDLE){
      Alert("Failed to create slow Handle");
      return INIT_FAILED;
   }   
   ArraySetAsSeries(fastBuffer,true);
   ArraySetAsSeries(slowBuffer,true);
   
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
   if(fastHandle != INVALID_HANDLE){
      IndicatorRelease(fastHandle);
   }
   if(slowHandle != INVALID_HANDLE){
      IndicatorRelease(slowHandle);
   }
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
   int values = CopyBuffer(fastHandle,0,0,2,fastBuffer);
   if(values != 2){
      Print("Not enough data for fast moving average");
   }
   values = CopyBuffer(slowHandle,0,0,2,slowBuffer);
   if(values != 2){
      Print("Not enough data for slow moving average");
   }
   Comment("fast[0]: ",fastBuffer[0],"\n",
           "fast[1]: ",fastBuffer[1],"\n",
           "slow[0]: ",slowBuffer[0],"\n",
           "slow[1]: ",slowBuffer[1]);

   //checking for CrossOver
   //Opening Buy           
   if(fastBuffer[0]>slowBuffer[0] && fastBuffer[1]<= slowBuffer[1] && openTimeBuy != iTime(_Symbol,PERIOD_CURRENT,0)){
      openTimeBuy = iTime(_Symbol,PERIOD_CURRENT,0);
      double ask  = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      double sl   = ask - inpStopLoss*SymbolInfoDouble(_Symbol,SYMBOL_POINT);
      double tp   = ask + inpTakeProfit*SymbolInfoDouble(_Symbol,SYMBOL_POINT);
      
      trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,1.0,ask,sl,tp,"Bought");
   }
   //Opening Sell
   if(fastBuffer[0]<slowBuffer[0] && fastBuffer[1]>= slowBuffer[1] && openTimeSell != iTime(_Symbol,PERIOD_CURRENT,0)){
      openTimeSell = iTime(_Symbol,PERIOD_CURRENT,0);
      double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
      
      double sl   = bid + inpStopLoss*SymbolInfoDouble(_Symbol,SYMBOL_POINT);
      double tp   = bid - inpTakeProfit*SymbolInfoDouble(_Symbol,SYMBOL_POINT);
      trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,1.0,bid,sl,tp,"Sold");
   }
}
