//closing the triangle

#include "head.mqh"

void fnCloseThree(stThree &MxSmb[], int accounttype, int i)
   {
      // before closing, make sure to check the availability of all pairs in the triangle
      // it is wrong and extremely dangerous to disrupt the triangle, when working on a netting account,
      // this may cause a mess in positions later on
      
      if(fnSmbCheck(MxSmb[i].smb1.name))
      if(fnSmbCheck(MxSmb[i].smb2.name))
      if(fnSmbCheck(MxSmb[i].smb3.name))          
      
      // if all is available, close all 3 positions using the standard library
      // after closing, check if the action is successful
      switch(accounttype)
      {
         case  ACCOUNT_MARGIN_MODE_RETAIL_HEDGING:     
         
         ctrade.PositionClose(MxSmb[i].smb1.tkt);
         ctrade.PositionClose(MxSmb[i].smb2.tkt);
         ctrade.PositionClose(MxSmb[i].smb3.tkt);              
         break;
         default:
         break;
      }       
   }   