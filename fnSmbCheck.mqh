//check the correctness of a separate symbol

#include "head.mqh"

bool fnSmbCheck(string smb)
   {
      // a triangle can be made only of currency pairs
      if(SymbolInfoInteger(smb,SYMBOL_TRADE_CALC_MODE)!=SYMBOL_CALC_MODE_FOREX) return(false);
      
      // if there are trade limitations, skip the symbol
      if(SymbolInfoInteger(smb,SYMBOL_TRADE_MODE)!=SYMBOL_TRADE_MODE_FULL) return(false);   
      
      // if there are dates of contract start and end, we should skip them as well, since this parameter is not applied for currencies
      // some brokers specify the forex calculation method for short-term instruments. this is how we sort it out
      if(SymbolInfoInteger(smb,SYMBOL_START_TIME)!=0)return(false);
      if(SymbolInfoInteger(smb,SYMBOL_EXPIRATION_TIME)!=0) return(false);
      
      // availability for order types. although the robot trades only markets, there should be no limitations
      int som=(int)SymbolInfoInteger(smb,SYMBOL_ORDER_MODE);
      if((SYMBOL_ORDER_MARKET&som)==SYMBOL_ORDER_MARKET); else return(false);
      if((SYMBOL_ORDER_LIMIT&som)==SYMBOL_ORDER_LIMIT); else return(false);
      if((SYMBOL_ORDER_STOP&som)==SYMBOL_ORDER_STOP); else return(false);
      if((SYMBOL_ORDER_STOP_LIMIT&som)==SYMBOL_ORDER_STOP_LIMIT); else return(false);
      if((SYMBOL_ORDER_SL&som)==SYMBOL_ORDER_SL); else return(false);
      if((SYMBOL_ORDER_TP&som)==SYMBOL_ORDER_TP); else return(false);
       
      // check the standard library for data availability         
      if(!csmb.Name(smb)) return(false);
      
      // the check below is needed only for a real work because sometimes SymbolInfoTick works and the prices 
      // are received, while ask and bid are actually 0.
      // disable in the tester since prices may appear later there
      if(!(bool)MQLInfoInteger(MQL_TESTER))
      {
         MqlTick tk;      
         if(!SymbolInfoTick(smb,tk)) return(false);
         if(tk.ask<=0 ||  tk.bid<=0) return(false);      
      }

      return(true);
   }
