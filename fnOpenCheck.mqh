//check how well the triangle has opened.

#include "head.mqh"

void fnOpenCheck(stThree &MxSmb[], int accounttype, int fh)
   {
      uchar cnt=0;      //counter of open positions in the triangle
      ulong   tkt=0;     //current ticket
      string smb="";    //current symbol
      
      // check our array of triangles
      for(int i=ArraySize(MxSmb)-1;i>=0;i--)
      {
         // consider only the triangles sent for opening, i.e. their status = 1
         if(MxSmb[i].status!=1) continue;
                          
         if ((TimeCurrent()-MxSmb[i].timeopen)>MAXTIMEWAIT)
         {     
            // if the time provided for opening is exceeded, mark the triangle as ready for closure         
            MxSmb[i].status=3;
            Print("Not correct open: "+MxSmb[i].smb1.name+" + "+MxSmb[i].smb2.name+" + "+MxSmb[i].smb3.name);
            continue;
         }
         
         cnt=0;
         
         switch(accounttype)
         {
            case  ACCOUNT_MARGIN_MODE_RETAIL_HEDGING:
            
            // check all open positions. Perform this check for each triangle
            // here we have an overconsumption of resources, but there is already no need for hurry since we have already opened everything we could
            for(int j=PositionsTotal()-1;j>=0;j--)
            if (PositionSelectByTicket(PositionGetTicket(j)))
            if (PositionGetInteger(POSITION_MAGIC)==MxSmb[i].magic)
            {
               // get the symbol and the ticket of the considered position
               tkt=PositionGetInteger(POSITION_TICKET);
               smb=PositionGetString(POSITION_SYMBOL);
               
               // check if there is the current position among the ones we need in the considered triangle
               // if yes, increase the counter and remember the ticket and Open price
               if (smb==MxSmb[i].smb1.name){ cnt++;   MxSmb[i].smb1.tkt=tkt;  MxSmb[i].smb1.price=PositionGetDouble(POSITION_PRICE_OPEN);} else
               if (smb==MxSmb[i].smb2.name){ cnt++;   MxSmb[i].smb2.tkt=tkt;  MxSmb[i].smb2.price=PositionGetDouble(POSITION_PRICE_OPEN);} else
               if (smb==MxSmb[i].smb3.name){ cnt++;   MxSmb[i].smb3.tkt=tkt;  MxSmb[i].smb3.price=PositionGetDouble(POSITION_PRICE_OPEN);} 
               
               // if three necessary positions are found, our triangle has opened successfully. change its status to 2 (open)
               // and write an open data to a log file
               if (cnt==3)
               {
                  MxSmb[i].status=2;
                  fnControlFile(MxSmb,i,fh);
                  break;   
               }
            }
            break;
            default:
            break;
         }
      }
   }