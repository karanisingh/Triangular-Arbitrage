//close everything without waiting for profit

bool fnModeCloseOnly(ulong lcMagic, uint delta, int accounttype)
   {   
      bool find=false;//order detected
      switch(accounttype)
      {
         case  ACCOUNT_MARGIN_MODE_RETAIL_HEDGING://simply close all orders by the magic number
            for(int i=PositionsTotal()-1;i>=0;i--)
            {
               ulong mg=PositionGetInteger(POSITION_MAGIC);
               if (mg>=lcMagic && mg<(lcMagic+delta))
               {
                  find=true;
                  ctrade.PositionClose(PositionGetTicket(i));
               }
            }
            if (!find) return(true);//if there are no more orders, the robot can be unloaded
         break;
         default:
         break;
      }      
      return(false);
   }