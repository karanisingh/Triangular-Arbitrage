//+------------------------------------------------------------------+
//|                                                      Support.mqh |
//|                                                    A.V. Oreshkin |
//|                                      https://vk.com/tradingisfun |
//+------------------------------------------------------------------+
#property copyright "A.V. Oreshkin"
#property link      "https://vk.com/tradingisfun"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSupport
  {
private:

public:
                     CSupport();
                    ~CSupport();
                    
      uchar          NumberCount(double numer);    //Return the number of decimal places in the decimal number
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSupport::CSupport()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSupport::~CSupport()
  {
  }
//+------------------------------------------------------------------+
uchar CSupport::NumberCount(double numer)
   {
      uchar i=0;
      numer=MathAbs(numer);
      for(i=0;i<=8;i++) if (MathAbs(NormalizeDouble(numer,i)-numer)<=DBL_EPSILON) break;
      return(i);   
   }