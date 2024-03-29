//write all data to the file right after opening, so that we are able to track and check everything

void fnControlFile(stThree &MxSmb[],int i, int fh)
   {
      FileWrite(fh,"============");
      FileWrite(fh,"Open:",MxSmb[i].smb1.name,MxSmb[i].smb2.name,MxSmb[i].smb3.name);
      FileWrite(fh,"Tiket:",MxSmb[i].smb1.tkt,MxSmb[i].smb2.tkt,MxSmb[i].smb3.tkt);
      FileWrite(fh,"Lot",DoubleToString(MxSmb[i].smb1.lot,MxSmb[i].smb1.digits_lot),DoubleToString(MxSmb[i].smb2.lot,MxSmb[i].smb2.digits_lot),DoubleToString(MxSmb[i].smb3.lot,MxSmb[i].smb3.digits_lot));
      FileWrite(fh,"Margin",DoubleToString(MxSmb[i].smb1.mrg,2),DoubleToString(MxSmb[i].smb2.mrg,2),DoubleToString(MxSmb[i].smb3.mrg,2));
      FileWrite(fh,"Ask",DoubleToString(MxSmb[i].smb1.tick.ask,MxSmb[i].smb1.digits),DoubleToString(MxSmb[i].smb2.tick.ask,MxSmb[i].smb2.digits),DoubleToString(MxSmb[i].smb3.tick.ask,MxSmb[i].smb3.digits));
      FileWrite(fh,"Bid",DoubleToString(MxSmb[i].smb1.tick.bid,MxSmb[i].smb1.digits),DoubleToString(MxSmb[i].smb2.tick.bid,MxSmb[i].smb2.digits),DoubleToString(MxSmb[i].smb3.tick.bid,MxSmb[i].smb3.digits));               
      FileWrite(fh,"Price open",DoubleToString(MxSmb[i].smb1.price,MxSmb[i].smb1.digits),DoubleToString(MxSmb[i].smb2.price,MxSmb[i].smb2.digits),DoubleToString(MxSmb[i].smb3.price,MxSmb[i].smb3.digits));
      FileWrite(fh,"Tick value",DoubleToString(MxSmb[i].smb1.tv,MxSmb[i].smb1.digits),DoubleToString(MxSmb[i].smb2.tv,MxSmb[i].smb2.digits),DoubleToString(MxSmb[i].smb3.tv,MxSmb[i].smb3.digits));
      FileWrite(fh,"Spread point",DoubleToString(MxSmb[i].smb1.sppoint,0),DoubleToString(MxSmb[i].smb2.sppoint,0),DoubleToString(MxSmb[i].smb3.sppoint,0));
      FileWrite(fh,"Spread $",DoubleToString(MxSmb[i].smb1.spcost,3),DoubleToString(MxSmb[i].smb2.spcost,3),DoubleToString(MxSmb[i].smb3.spcost,3));
      FileWrite(fh,"Spread all",DoubleToString(MxSmb[i].spread,3));
      FileWrite(fh,"PL Buy",DoubleToString(MxSmb[i].PLBuy,3));
      FileWrite(fh,"PL Sell",DoubleToString(MxSmb[i].PLSell,3));      
      FileWrite(fh,"Magic",string(MxSmb[i].magic));
      FileWrite(fh,"Time open",TimeToString(MxSmb[i].timeopen,TIME_DATE|TIME_SECONDS));
      FileWrite(fh,"Time current",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
      
      FileFlush(fh);       
   }
