//check if the triangle is closed successfully. The closing itself is not performed here!

#include "head.mqh"

void fnCloseCheck(stThree &MxSmb[], int accounttype,int fh)
   {
      // go through the triangles array
      for(int i=ArraySize(MxSmb)-1;i>=0;i--)
      {
         // we are interested only in the ones having the status of 3, i.e. already closed or sent for closure
         if(MxSmb[i].status!=3) continue;
         
         switch(accounttype)
         {
            case  ACCOUNT_MARGIN_MODE_RETAIL_HEDGING: 
            
            // if not a single pair can be selected from the triangle, the closure has been successful. Return to the status 0
            if (!PositionSelectByTicket(MxSmb[i].smb1.tkt))
            if (!PositionSelectByTicket(MxSmb[i].smb2.tkt))
            if (!PositionSelectByTicket(MxSmb[i].smb3.tkt))
            {  // this means successful closure
               MxSmb[i].status=0;   
               
               Print("Close triangle: "+MxSmb[i].smb1.name+" + "+MxSmb[i].smb2.name+" + "+MxSmb[i].smb3.name+" magic: "+(string)MxSmb[i].magic+"  P/L: "+DoubleToString(MxSmb[i].pl,2));
               
               // enter the closure data to a log file
               if (fh!=INVALID_HANDLE)
               {
                  FileWrite(fh,"============");
                  FileWrite(fh,"Close:",MxSmb[i].smb1.name,MxSmb[i].smb2.name,MxSmb[i].smb3.name);
                  FileWrite(fh,"Lot",DoubleToString(MxSmb[i].smb1.lot,MxSmb[i].smb1.digits_lot),DoubleToString(MxSmb[i].smb2.lot,MxSmb[i].smb2.digits_lot),DoubleToString(MxSmb[i].smb3.lot,MxSmb[i].smb3.digits_lot));
                  FileWrite(fh,"Tiket",string(MxSmb[i].smb1.tkt),string(MxSmb[i].smb2.tkt),string(MxSmb[i].smb3.tkt));
                  FileWrite(fh,"Magic",string(MxSmb[i].magic));
                  FileWrite(fh,"Profit",DoubleToString(MxSmb[i].pl,3));
                  FileWrite(fh,"Time current",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
                  FileFlush(fh);               
               }                   
            }                  
            break;
         }            
      }      
   }