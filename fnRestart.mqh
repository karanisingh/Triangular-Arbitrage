//the robot can cope with unstable Internet connection since the variables remain. in case of a re-launch, we need to find open orders and 
//put them in the current robot environment

#include "head.mqh"

void fnRestart(stThree &MxSmb[],ulong magic,int accounttype)
   {
      string   smb1,smb2,smb3;
      long     tkt1,tkt2,tkt3;
      ulong    mg;
      uchar    count=0;    //counter of restored triangles
      
      switch(accounttype)
      {
         // it is simple to restore positions with a hedge account - go through all open positions, use the magic number to find the necessary ones and 
         // arrange them into triangles
         // in case of a netting, all is more complicated - we need to refer to our custom database storing positions opened by the robot
         
         // The algorithm of searching the necessary positions and restoring them into a triangle has been implemented in a rather blunt way with no frills and 
         // optimization. However, since this stage is not needed frequently, we may neglect performance
         // in order to shorten the code
         
         case  ACCOUNT_MARGIN_MODE_RETAIL_HEDGING:
            // go through all the open positions and detect the magic number matches
            // we also need to remember the magic number of the first detected position, since the remaining two ones
            // are searched for using this same magic number
            
            for(int i=PositionsTotal()-1;i>=2;i--)
            {//for i
               smb1=PositionGetSymbol(i);
               mg=PositionGetInteger(POSITION_MAGIC);
               if (mg<magic || mg>(magic+MAGIC)) continue;
               
               // remember the ticket, so that it is easier to access this position
               tkt1=PositionGetInteger(POSITION_TICKET);
               
               // look for the second position having the same magic number 
               for(int j=i-1;j>=1;j--)
               {//for j
                  smb2=PositionGetSymbol(j);
                  if (mg!=PositionGetInteger(POSITION_MAGIC)) continue;  
                  tkt2=PositionGetInteger(POSITION_TICKET);          
                    
                  // now, we only have to find the last position
                  for(int k=j-1;k>=0;k--)
                  {//for k
                     smb3=PositionGetSymbol(k);
                     if (mg!=PositionGetInteger(POSITION_MAGIC)) continue;
                     tkt3=PositionGetInteger(POSITION_TICKET);
                     
                     // if we reached this stage, then the open triangle is detected. Data on it have already been downloaded, we only have to  
                     // inform the robot that the triangle is already open. The robot counts the rest on the next tick
                     
                     for(int m=ArraySize(MxSmb)-1;m>=0;m--)
                     {//for m
                        // go through the triangles array ignoring the already open ones
                        if (MxSmb[m].status!=0) continue; 
                        
                        // the enumeration is rough but fast
                        // in this comparison, it may at first seem that we are able to refer to 
                        // the same currency pair for several times. However, this is not the case, since we continue the search from the next pair (rather than the very beginning) 
                        // after detecting another currency pair in the enumeration loops 
                        // above.
                        if (  (MxSmb[m].smb1.name==smb1 || MxSmb[m].smb1.name==smb2 || MxSmb[m].smb1.name==smb3) &&
                              (MxSmb[m].smb2.name==smb1 || MxSmb[m].smb2.name==smb2 || MxSmb[m].smb2.name==smb3) &&
                              (MxSmb[m].smb3.name==smb1 || MxSmb[m].smb3.name==smb2 || MxSmb[m].smb3.name==smb3)); else continue;
                        
                        //this means we detected this triangle and assign an appropriate status to it
                        MxSmb[m].status=2;
                        MxSmb[m].magic=magic;
                        MxSmb[m].pl=0;
                        
                        // arrange the tickets in the right sequence and the triangle is back in action.
                        if (MxSmb[m].smb1.name==smb1) MxSmb[m].smb1.tkt=tkt1;
                        if (MxSmb[m].smb1.name==smb2) MxSmb[m].smb1.tkt=tkt2;
                        if (MxSmb[m].smb1.name==smb3) MxSmb[m].smb1.tkt=tkt3;
      
                        if (MxSmb[m].smb2.name==smb1) MxSmb[m].smb2.tkt=tkt1;
                        if (MxSmb[m].smb2.name==smb2) MxSmb[m].smb2.tkt=tkt2;
                        if (MxSmb[m].smb2.name==smb3) MxSmb[m].smb2.tkt=tkt3;   
      
                        if (MxSmb[m].smb3.name==smb1) MxSmb[m].smb3.tkt=tkt1;
                        if (MxSmb[m].smb3.name==smb2) MxSmb[m].smb3.tkt=tkt2;
                        if (MxSmb[m].smb3.name==smb3) MxSmb[m].smb3.tkt=tkt3;   
                        
                        count++;                        
                        break;   
                     }//for m              
                  }//for k              
               }//for j         
            }//for i         
         break;
         default:
         break;
      }
      

      if (count>0) Print("Restore "+(string)count+" triangles");            
   }