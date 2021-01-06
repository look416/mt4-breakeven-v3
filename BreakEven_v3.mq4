//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2010, VIKRAV"
#property link      "http://www.vikrav.com"

string gs76 = "BreakEven";
extern int LockInPipsAt = 15;
extern int LockInPips = 2;
extern int Trades = 3;
extern bool ModifyTrades = TRUE;
extern bool ModifyTrade3 = False;
extern int FontSize = 10;
extern color FontColour = White;
double gdunused112;
double gd120;
double gd128;
string gs144 = "expert.wav";
string gsdummy152;
int gi160 = 3;
int gslippage164 = 0;
int gi168 = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   if(Trades > 3)
      Trades = 3;
   if(Trades < 1)
      Trades = 1;
   ObjectCreate("EA_Version", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("EA_Version", gs76 + " - Lock in " + LockInPips + " pips after " + LockInPipsAt + " pips profit", FontSize, "Arial", FontColour);
   ObjectSet("EA_Version", OBJPROP_XDISTANCE, 500);
   ObjectSet("EA_Version", OBJPROP_YDISTANCE, 0);
   if(Trades > 1)
     {
      ObjectCreate("Monitor1", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("Monitor1", "Monitoring Targets: TP1 = " + LockInPipsAt + " Pips", FontSize, "Arial", FontColour);
      ObjectSet("Monitor1", OBJPROP_CORNER, 0);
      ObjectSet("Monitor1", OBJPROP_XDISTANCE, 500);
      ObjectSet("Monitor1", OBJPROP_YDISTANCE, FontSize + 10);
     }
   if(Trades > 1)
     {
      ObjectCreate("Monitor2", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("Monitor2", "|| TP2 = " + (LockInPipsAt * 2) + " Pips", FontSize, "Arial", FontColour);
      ObjectSet("Monitor2", OBJPROP_CORNER, 0);
      ObjectSet("Monitor2", OBJPROP_XDISTANCE, 710);
      ObjectSet("Monitor2", OBJPROP_YDISTANCE, FontSize + 10);
     }
   if(Trades == 3)
     {
      ObjectCreate("Monitor3", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("Monitor3", "|| TP3 = " + (3 * LockInPipsAt) + " Pips", FontSize, "Arial", FontColour);
      ObjectSet("Monitor3", OBJPROP_CORNER, 0);
      ObjectSet("Monitor3", OBJPROP_XDISTANCE, 815);
      ObjectSet("Monitor3", OBJPROP_YDISTANCE, FontSize + 10);
     }
   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete("EA_Version");
   ObjectDelete("Monitor1");
   ObjectDelete("Monitor2");
   ObjectDelete("Monitor3");
   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string checkBE()
  {
   string retStr = "";
   int digits = MarketInfo(OrderSymbol(), MODE_DIGITS);
   double point = MarketInfo(OrderSymbol(), MODE_POINT);
   double mBid = MarketInfo(OrderSymbol(), MODE_BID);
   double mAsk = MarketInfo(OrderSymbol(), MODE_ASK);
   if(digits == 5 || digits == 3)
      gd128 = MarketInfo(OrderSymbol(), MODE_SPREAD) / 10.0;
   else
      gd128 = MarketInfo(OrderSymbol(), MODE_SPREAD);
      
   gd120 = point;
   gdunused112 = digits;
   gslippage164 = gi160;
   if(digits == 5 || digits == 3)
     {
      gdunused112 = digits - 1;
      gd120 = 10.0 * point;
      gslippage164 = 10 * gi160;
     }

   if(LockInPipsAt > 0)
     {
      switch(OrderType())
        {
         case OP_BUY:
            retStr = "\n[" + IntegerToString(OrderTicket())
                     + "] "+OrderSymbol()+": BUY Open@ " + DoubleToStr(OrderOpenPrice(), digits)
                     + " | P/L: $" + DoubleToStr(OrderProfit(), 2)
                     + " / " + DoubleToStr((mBid - OrderOpenPrice()) / gd120, 1) + "pips.";
            if(mBid - OrderOpenPrice() >= LockInPipsAt * gd120)
              {
               if(OrderStopLoss() < OrderOpenPrice())
                 {
                  OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + LockInPips * gd120, OrderTakeProfit(), 0, CLR_NONE);
                  Print("Stop Loss adjusted to ", LockInPips, " pips");
                  PlaySound(gs144);
                  if(Trades > 1)
                    {
                     OrderClose(OrderTicket(), NormalizeDouble(OrderLots() / Trades, gi168), mBid, gslippage164, CLR_NONE);
                     Print("Partial order closed to lock in profits by Breakeven EA");
                    }
                 }
              }
            if(Trades == 3 && ModifyTrades && mBid - OrderOpenPrice() >= LockInPipsAt * 2 * gd120)
              {
               OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + LockInPipsAt * gd120, OrderTakeProfit(), 0, CLR_NONE);
               Print("Stop Loss adjusted to ", LockInPipsAt, " pips");
               Sleep(500);
               OrderClose(OrderTicket(), NormalizeDouble(OrderLots() / 2.0, gi168), mBid, gslippage164, CLR_NONE);
               Print("Partial order closed to lock in profits");
               ModifyTrades = FALSE;
               PlaySound(gs144);
              }
            if(Trades == 3 && ModifyTrade3 && mBid - OrderOpenPrice() >= 3 * LockInPipsAt * gd120)
              {
               OrderClose(OrderTicket(), OrderLots(), mBid, gslippage164, CLR_NONE);
               Print("Final Order closed by Breakeven EA");
               ModifyTrade3 = FALSE;
               PlaySound(gs144);
              }
            break;
         case OP_SELL:
            retStr = "\n[" + IntegerToString(OrderTicket())
                     + "] "+OrderSymbol()+": SELL Open@ " + DoubleToStr(OrderOpenPrice(), digits)
                     + " | P/L: $" + DoubleToStr(OrderProfit(), 2)
                     + " / " + DoubleToStr((OrderOpenPrice() - mAsk) / gd120, 1) + "pips.";
            if(OrderOpenPrice() - mAsk >= LockInPipsAt * gd120)
              {
               if(OrderStopLoss() > OrderOpenPrice())
                 {
                  OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - LockInPips * gd120, OrderTakeProfit(), 0, Yellow);
                  Print("Stop Loss adjusted to ", LockInPips, " pips");
                  PlaySound(gs144);
                  if(Trades > 1)
                    {
                     OrderClose(OrderTicket(), NormalizeDouble(OrderLots() / Trades, gi168), mAsk, gslippage164, CLR_NONE);
                     Print("Partial order closed to lock in profits by Breakeven EA");
                    }
                 }
              }
            if(Trades == 3 && ModifyTrades && OrderOpenPrice() - mAsk >= LockInPipsAt * 2 * gd120)
              {
               OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - LockInPipsAt * gd120, OrderTakeProfit(), 0, CLR_NONE);
               Print("Stop Loss adjusted to ", LockInPipsAt, " pips");
               Sleep(500);
               OrderClose(OrderTicket(), NormalizeDouble(OrderLots() / 2.0, gi168), mAsk, gslippage164, CLR_NONE);
               Print("Partial order closed to lock in profits by Breakeven EA");
               ModifyTrades = FALSE;
               PlaySound(gs144);
              }
            if(Trades == 3 && ModifyTrade3 && OrderOpenPrice() - mAsk >= 3 * LockInPipsAt * gd120)
              {
               OrderClose(OrderTicket(), OrderLots(), mAsk, gslippage164, CLR_NONE);
               Print("Final Order closed by Breakeven EA");
               ModifyTrade3 = FALSE;
               PlaySound(gs144);
              }
        }
     }
   return retStr;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   string vsDisplay = "";
   for(int lpos0 = 0; lpos0 < OrdersTotal(); lpos0++)
     {
      OrderSelect(lpos0, SELECT_BY_POS, MODE_TRADES);
      int vdigits = MarketInfo(OrderSymbol(), MODE_DIGITS);

      if(NormalizeDouble(MarketInfo(OrderSymbol(), MODE_LOTSTEP), 2) == 0.01)
         gi168 = 2;
      else
         gi168 = 1;
      vsDisplay   =   vsDisplay + checkBE();

     }
   Comment(vsDisplay);
   return (0);
  }
//+------------------------------------------------------------------+
