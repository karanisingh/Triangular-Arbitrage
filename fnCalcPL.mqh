//calculate profits and losses and send for closure

#include "head.mqh"

void fnCalcPL(stThree &MxSmb[], int accounttype, double prft)
   {
      // go through our array of triangles again
      // speeds of opening and closing are extremely important parts of this strategy
      // therefore as soon as we find the triangle for closing, we should close it with no delay.
      
      bool flag=cterm.IsTradeAllowed()&cterm.IsConnected();      
      
      for(int i=ArraySize(MxSmb)-1;i>=0;i--)
      {//for
         // we are interested only in the triangles with the status 2 and 3.
         // status 3 (closing a triangle) can be received if a triangle opened partially
         if(MxSmb[i].status==2 || MxSmb[i].status==3); else continue;                             
         
         // calculate how much the triangle has earned
         if (MxSmb[i].status==2)
         {
            MxSmb[i].pl=0;// reset profit
            switch(accounttype)
            {//switch
               case  ACCOUNT_MARGIN_MODE_RETAIL_HEDGING:  
                
               if (PositionSelectByTicket(MxSmb[i].smb1.tkt)) MxSmb[i].pl=PositionGetDouble(POSITION_PROFIT);
               if (PositionSelectByTicket(MxSmb[i].smb2.tkt)) MxSmb[i].pl+=PositionGetDouble(POSITION_PROFIT);
               if (PositionSelectByTicket(MxSmb[i].smb3.tkt)) MxSmb[i].pl+=PositionGetDouble(POSITION_PROFIT);                           
               break;
               default:
               break;
            }//switch
            
            // round down to 2 digits, since we count money
            MxSmb[i].pl=NormalizeDouble(MxSmb[i].pl,2);
            
            // let's have a closer look at closing. I use the following logic:
            // the case with arbitrage is not normal and should not occur. When it appears, we can expect a return 
            // to the state without an arbitrage. It is impossible to determine whether the profit will increase,
            // therefore, I prefer to close the position immediately after the spread and the commission have been covered
            // It may seem that this is not enough. The triangular arbitrage is not the statistical one, so you cannot rely on big movements here
            // we use points here.
            // if you think this is not enough, you can wait for a desired profit in the Commission variable in the inputs
            
            // if we spent more than we earned, assign the "send for closure" status.
            // but the status is changed only if there is a trading possibility, and it is not known when it appears
            if (flag && MxSmb[i].pl>prft) MxSmb[i].status=3;                    
         }
         
         // finally, close the triangle only if allowed to trade
         if (flag && MxSmb[i].status==3) fnCloseThree(MxSmb,accounttype,i); 
      }//for         
   }