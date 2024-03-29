//calculate all separations and costs, search for a triangle for entry and enter the market immediately

#include "head.mqh"

void fnCalcDelta(stThree &MxSmb[],double prft, string cmnt, ulong magic,double lot, ushort lcMaxThree, ushort &lcOpenThree)
   {     
      double   temp=0;
      string   cmnt_pos="";
      
      for(int i=ArraySize(MxSmb)-1;i>=0;i--)
      {//for i
         // if triangles are in work, skip it
         if(MxSmb[i].status!=0) continue; 
         
         // check the availability of all three pairs again. If at least one of them is unavailable,
         // there is no point in calculating the entire triangle
         if (!fnSmbCheck(MxSmb[i].smb1.name)) continue;  
         if (!fnSmbCheck(MxSmb[i].smb2.name)) continue;  //trading is suddenly stopped at one of the pairs
         if (!fnSmbCheck(MxSmb[i].smb3.name)) continue;     
         
         // calculate the number of open triangles at the beginning of each tick,
         // however, we can open them within the tick, therefore, we constantly track their number
         if (lcMaxThree>0) {if (lcMaxThree>lcOpenThree); else continue;}// whether we can open more or not
         
         // get all necessary calculation data
         
         // get tick price per each pair
         if(!SymbolInfoDouble(MxSmb[i].smb1.name,SYMBOL_TRADE_TICK_VALUE,MxSmb[i].smb1.tv)) continue;
         if(!SymbolInfoDouble(MxSmb[i].smb2.name,SYMBOL_TRADE_TICK_VALUE,MxSmb[i].smb2.tv)) continue;
         if(!SymbolInfoDouble(MxSmb[i].smb3.name,SYMBOL_TRADE_TICK_VALUE,MxSmb[i].smb3.tv)) continue;
         
         // get the current prices
         if(!SymbolInfoTick(MxSmb[i].smb1.name,MxSmb[i].smb1.tick)) continue;
         if(!SymbolInfoTick(MxSmb[i].smb2.name,MxSmb[i].smb2.tick)) continue;
         if(!SymbolInfoTick(MxSmb[i].smb3.name,MxSmb[i].smb3.tick)) continue;
         
         // as mentioned earlier, it sometimes happens that the ask or bid = 0 when getting the prices successfully
         // we have to spend time for checking the prices
         if(MxSmb[i].smb1.tick.ask<=0 || MxSmb[i].smb1.tick.bid<=0 || MxSmb[i].smb2.tick.ask<=0 || MxSmb[i].smb2.tick.bid<=0 || MxSmb[i].smb3.tick.ask<=0 || MxSmb[i].smb3.tick.bid<=0) continue;
         
         // calculate the third pair volume. Do it here since we know the volume of the first two pairs — it is the same and fixed
         // volume of the third pair always changes. Also, do not forget that we calculate the volume only if the lot value is not 0 in the initial variables
         // a single minimum volume is used in this case everywhere - it is difficult to say why this mode is needed but it is always better
         // to have more options
         // the volume calculation logic is simple. let's return to our triangle: EURUSD=EURGBP*GBPUSD. number of bought or sold GBPs
         // directly depends on the EURGBP quote, while in the third pair, this third currency comes first, in other words, we avoid some calculations
         // by simply using the price of the second pair as a volume. this is another advantage of this triangle forming option
         // also, mind the direction (buy/sell), however, considering that a spread affects only the 4 th decimal place, while the number of lots is rounded
         // down to the second decimal place, the direction can be safely ignored. I have taken an average between ask and bid.
         // also, do not forget about the correction for the input trade volume.
         
         if (lot>0)
         MxSmb[i].smb3.lot=NormalizeDouble((MxSmb[i].smb2.tick.ask+MxSmb[i].smb2.tick.bid)/2*MxSmb[i].smb1.lot,MxSmb[i].smb3.digits_lot);
         
         // if the calculated volume goes beyond the allowed limits, we notify the user of that
         // without doing anything. This triangle is marked as non-working
         if (MxSmb[i].smb3.lot<MxSmb[i].smb3.lot_min || MxSmb[i].smb3.lot>MxSmb[i].smb3.lot_max)
         {
            Alert("The calculated lot for ",MxSmb[i].smb3.name," is out of range. Min/Max/Calc: ",
            DoubleToString(MxSmb[i].smb3.lot_min,MxSmb[i].smb3.digits_lot),"/",
            DoubleToString(MxSmb[i].smb3.lot_max,MxSmb[i].smb3.digits_lot),"/",
            DoubleToString(MxSmb[i].smb3.lot,MxSmb[i].smb3.digits_lot)); 
            Alert("Triangle: "+MxSmb[i].smb1.name+" "+MxSmb[i].smb2.name+" "+MxSmb[i].smb3.name+" - DISABLED");
            MxSmb[i].smb1.name="";   
            continue;  
         }
         
         // calculate our costs, i.e. spread+commissions. pr = spread in integer points
         // the spread prevents us from earning using this strategy, therefore, it should be taken into account at all times
         // instead of the price difference multiplied by a reverse point, we may use the spread in points
         // SymbolInfoInteger(Symbol(),SYMBOL_SPREAD) - now, it is hard to say why I did not choose this option
         // may be because I had already got the prices and in order not to refer to the environment again
         // perhaps, the previous tests were faster. I do not remember, since the robot was developed a long time ago.
         
         MxSmb[i].smb1.sppoint=NormalizeDouble(MxSmb[i].smb1.tick.ask-MxSmb[i].smb1.tick.bid,MxSmb[i].smb1.digits)*MxSmb[i].smb1.Rpoint;
         MxSmb[i].smb2.sppoint=NormalizeDouble(MxSmb[i].smb2.tick.ask-MxSmb[i].smb2.tick.bid,MxSmb[i].smb2.digits)*MxSmb[i].smb2.Rpoint;
         MxSmb[i].smb3.sppoint=NormalizeDouble(MxSmb[i].smb3.tick.ask-MxSmb[i].smb3.tick.bid,MxSmb[i].smb3.digits)*MxSmb[i].smb3.Rpoint;
         
         // It sounds strange but we check if the spread is positive - this often happens in the tester. I have not encountered that in real time though
         if (MxSmb[i].smb1.sppoint<=0 || MxSmb[i].smb2.sppoint<=0 || MxSmb[i].smb3.sppoint<=0) continue;
         
         // we have a spread in points, now let's calculate it in money (deposit currency)
         // in currency, the price of 1 tick is always equal to SYMBOL_TRADE_TICK_VALUE
         // also, do not forget about trade volumes
         MxSmb[i].smb1.spcost=MxSmb[i].smb1.sppoint*MxSmb[i].smb1.tv*MxSmb[i].smb1.lot;
         MxSmb[i].smb2.spcost=MxSmb[i].smb2.sppoint*MxSmb[i].smb2.tv*MxSmb[i].smb2.lot;
         MxSmb[i].smb3.spcost=MxSmb[i].smb3.sppoint*MxSmb[i].smb3.tv*MxSmb[i].smb3.lot;
         
         // so here are our costs for the specified volume with the added commission specified by the user
         MxSmb[i].spread=MxSmb[i].smb1.spcost+MxSmb[i].smb2.spcost+MxSmb[i].smb3.spcost+prft;
         
         // as mentioned earlier, in the introduction, we are able to track the situation when the portfolio's ask < bid, although this is 
         // an extremely rare occasion, and there is no point in considering such cases separately. By the way,
         // arbitrage spaced in time is able to handle such a situation as well.
         // I previously argued that being in a position is without risks, and here is why:
         // for example, we bought eurusd and sold it immediately via eurgbp and gbpusd
         // in other words, we saw that ask eurusd< bid eurgbp * bid gbpusd - such cases are numerous but this is not sufficient for a successful entry
         // we also need to calculate the cost of the spread and we should enter not just when ask < bid, but when the difference between
         // them exceeds our spread costs. This is the only case we may try to earn.          
         
         // let's agree on that buy means buying the first symbol and selling the two remaining ones,
         // while sell means selling the first pair and buying the two remaining ones
         
         temp=MxSmb[i].smb1.tv*MxSmb[i].smb1.Rpoint*MxSmb[i].smb1.lot;
         
         // let's take a closer look at the calculation formula
         // 1. in the brackets, each price is adjusted for slippage in the worse direction: MxSmb[i].smb2.tick.bid-MxSmb[i].smb2.dev
         // 2. as displayed in the above equation, bid eurgbp * bid gbpusd - multiply the second and third symbol prices:
         //    (MxSmb[i].smb2.tick.bid-MxSmb[i].smb2.dev)*(MxSmb[i].smb3.tick.bid-MxSmb[i].smb3.dev)
         // 3. Next, consider the difference between ask and bid simply by subtracting one from the other
         // 4. we have received a difference in points that should now be converted to money, i.e. convert points to integer and multiply 
         // a point price and a trade volume. To do that, we take the values of the first pair since we have the same to the left and to the right
         // if we were building a triangle by placing all pairs to one side and comparing with 1, there would be more calculations in this situation
         // therefore, we selected this approach to forming, rather than the "classic" one
         MxSmb[i].PLBuy=((MxSmb[i].smb2.tick.bid-MxSmb[i].smb2.dev)*(MxSmb[i].smb3.tick.bid-MxSmb[i].smb3.dev)-(MxSmb[i].smb1.tick.ask+MxSmb[i].smb1.dev))*temp;
         MxSmb[i].PLSell=((MxSmb[i].smb1.tick.bid-MxSmb[i].smb1.dev)-(MxSmb[i].smb2.tick.ask+MxSmb[i].smb2.dev)*(MxSmb[i].smb3.tick.ask+MxSmb[i].smb3.dev))*temp;
         
         // We received the money we can earn or lose by buying or selling the triangle
         // now, we only have to compare with costs. If we receive more than we spend, we can enter
         // the advantage of this approach is that we determine our potential profit instantly
         // normalize everything to 2 digits, since it is money already
         MxSmb[i].PLBuy=   NormalizeDouble(MxSmb[i].PLBuy,2);
         MxSmb[i].PLSell=  NormalizeDouble(MxSmb[i].PLSell,2);
         MxSmb[i].spread=  NormalizeDouble(MxSmb[i].spread,2);                  
         
         // if we have a potential profit, we need to additionally check whether the funds are sufficient for opening         
         if (MxSmb[i].PLBuy>MxSmb[i].spread || MxSmb[i].PLSell>MxSmb[i].spread)
         {
            // instead of considering a trade direction, I simply calculated the entire buy margin since it exceeds the sell one
            // also, pay attention to the increase factor
            // we should not open a triangle if the margin is barely sufficient. Take the increase factor, the default is 20%
            // strange as it may seem, this check may sometimes fail, I still do not understand why
            if(OrderCalcMargin(ORDER_TYPE_BUY,MxSmb[i].smb1.name,MxSmb[i].smb1.lot,MxSmb[i].smb1.tick.ask,MxSmb[i].smb1.mrg))
            if(OrderCalcMargin(ORDER_TYPE_BUY,MxSmb[i].smb2.name,MxSmb[i].smb2.lot,MxSmb[i].smb2.tick.ask,MxSmb[i].smb2.mrg))
            if(OrderCalcMargin(ORDER_TYPE_BUY,MxSmb[i].smb3.name,MxSmb[i].smb3.lot,MxSmb[i].smb3.tick.ask,MxSmb[i].smb3.mrg))
            if(AccountInfoDouble(ACCOUNT_MARGIN_FREE)>((MxSmb[i].smb1.mrg+MxSmb[i].smb2.mrg+MxSmb[i].smb3.mrg)*CF))  //check the free margin
            {
               // if we are here, then we are ready for opening, we only have to find an unoccupied magic number from our range
               // initial magic number is specified in the inputs (inMagic) and is equal to 300 by default
               // the range of magic numbers is specified in the MAGIC define, the default value is 200, this is more than enough for all triangles
               MxSmb[i].magic=fnMagicGet(MxSmb,magic);   
               if (MxSmb[i].magic<=0)
               { // 0 means all magic numbers are occupied, print and exit.
                  Print("Free magic ended\nNew triangles will not open");
                  break;
               }  
               
               // set the detected magic number to the robot
               ctrade.SetExpertMagicNumber(MxSmb[i].magic); 
               
               // write a comment for a triangle
               cmnt_pos=cmnt+(string)MxSmb[i].magic+" Open";               
               
               // open, while remembering the time the triangle was sent for opening
               // this is necessary to avoid waiting forever
               // by default, the waiting time till the full opening in the MAXTIMEWAIT define is set to 3 seconds
               // if we did not fully open within that time, send everything that did open for closing
               
               MxSmb[i].timeopen=TimeCurrent();
               
               if (MxSmb[i].PLBuy>MxSmb[i].spread)    fnOpen(MxSmb,i,cmnt_pos,true,lcOpenThree);
               if (MxSmb[i].PLSell>MxSmb[i].spread)   fnOpen(MxSmb,i,cmnt_pos,false,lcOpenThree);               
               
               // print opening the triangle
               if (MxSmb[i].status==1) Print("Open triangle: "+MxSmb[i].smb1.name+" + "+MxSmb[i].smb2.name+" + "+MxSmb[i].smb3.name+" magic: "+(string)MxSmb[i].magic);
            }
         }         
      }//for i
   }
