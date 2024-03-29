//opening

#include "head.mqh"

bool fnOpen(stThree &MxSmb[],int i,string cmnt,bool side, ushort &opt)
   {
      // first order opening flag
      bool openflag=false;
      
      // if trading is not alllowed, do not trade
      if (!cterm.IsTradeAllowed())  return(false);
      if (!cterm.IsConnected())     return(false);
      
      switch(side)
      {
         case  true:
         
         // if 'true' is returned after sending an open order, this still does not guarantee that it will be opened
         // however, if it returns 'false', then we can be sure it will not be opened since the request has not been even sent
         // hence it makes no sense to send the remaining two pairs for opening. Instead, let's try anew at the next tick
         // also, the robot does not open a partially opened triangle. If something remains not opened, then the triangle is closed
         // after waiting a time interval set in the MAXTIMEWAIT define
         if(ctrade.Buy(MxSmb[i].smb1.lot,MxSmb[i].smb1.name,0,0,0,cmnt))
         {
            openflag=true;
            MxSmb[i].status=1;
            opt++;
            // the further logic is the same - if we are unable to open, the triangle is sent for closure
            if(ctrade.Sell(MxSmb[i].smb2.lot,MxSmb[i].smb2.name,0,0,0,cmnt))
            ctrade.Sell(MxSmb[i].smb3.lot,MxSmb[i].smb3.name,0,0,0,cmnt);               
         }            
         break;
         case  false:
         
         if(ctrade.Sell(MxSmb[i].smb1.lot,MxSmb[i].smb1.name,0,0,0,cmnt))
         {
            openflag=true;
            MxSmb[i].status=1;  
            opt++;        
            if(ctrade.Buy(MxSmb[i].smb2.lot,MxSmb[i].smb2.name,0,0,0,cmnt))
            ctrade.Buy(MxSmb[i].smb3.lot,MxSmb[i].smb3.name,0,0,0,cmnt);         
         }           
         break;
      }      
      return(openflag);
   }