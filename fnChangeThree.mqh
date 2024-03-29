//change positions of pairs in triangles for more convenient subsequent use   

#include "head.mqh"

void fnChangeThree(stThree &MxSmb[])
   {
      int count=0;
      for(int i=ArraySize(MxSmb)-1;i>=0;i--)
      {//for         
         // first, determine what is in the third place
         // it is occupied by the pair having the base currency not matching with two other base currencies
         string sm1base="",sm2base="",sm3base="";
         
         // if we fail to get the base currency, do not use this triangle in work
         if(!SymbolInfoString(MxSmb[i].smb1.name,SYMBOL_CURRENCY_BASE,sm1base) ||
         !SymbolInfoString(MxSmb[i].smb2.name,SYMBOL_CURRENCY_BASE,sm2base) ||
         !SymbolInfoString(MxSmb[i].smb3.name,SYMBOL_CURRENCY_BASE,sm3base)) {MxSmb[i].smb1.name="";continue;}
                  
         // if the base currency of the symbol 1 and 2 match each other, we skip this step. Otherwise, swap the pairs
         if(sm1base!=sm2base)
         {         
            if(sm1base==sm3base)
            {
               string temp=MxSmb[i].smb2.name;
               MxSmb[i].smb2.name=MxSmb[i].smb3.name;
               MxSmb[i].smb3.name=temp;
            }
            
            if(sm2base==sm3base)
            {
               string temp=MxSmb[i].smb1.name;
               MxSmb[i].smb1.name=MxSmb[i].smb3.name;
               MxSmb[i].smb3.name=temp;
            }
         }
         
         //now, let's define the first and second places
         //the second place takes the pair with the profit currency matching the base currency of the third one. 
         //in this case we always use multiplication
         sm3base=SymbolInfoString(MxSmb[i].smb3.name,SYMBOL_CURRENCY_BASE);
         string sm2prft=SymbolInfoString(MxSmb[i].smb2.name,SYMBOL_CURRENCY_PROFIT);
         
         // swap the first and second pairs
         if(sm3base!=sm2prft)
         {
            string temp=MxSmb[i].smb1.name;
            MxSmb[i].smb1.name=MxSmb[i].smb2.name;
            MxSmb[i].smb2.name=temp;
         }
         
         // print the processed triangle
         Print("Use triangle: "+MxSmb[i].smb1.name+" + "+MxSmb[i].smb2.name+" + "+MxSmb[i].smb3.name);
         count++;
      }//for
      // notify of the total number of triangles in work
      Print("All used triangles: "+(string)count);
   }
