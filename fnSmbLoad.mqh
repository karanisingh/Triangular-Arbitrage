//download various symbol data including number of signs in a quote, a lot, etc.

#include "head.mqh"

void fnSmbLoad(double lot,stThree &MxSmb[])
   {
      
      // a simple macro for print   
      #define prnt(nm) {nm="";Print("NOT CORRECT LOAD: "+nm);continue;}
      
      // go through all formed triangles in a loop. Here we have an overconsumption of time for repeated data requests for the same 
      // symbols, but since this operation is performed only when loading the robot, we still can do this to reduce the code.
      // use the standard library to get the data. There is no acute need for its use, but let it be anyway
      for(int i=ArraySize(MxSmb)-1;i>=0;i--)
      {
         // by uploading a symbol to the CSymbolInfo class, we initialize the collection of all necessary data,
         // while checking it for availability, if something is wrong, the triangle is marked as non-working                  
         if (!csmb.Name(MxSmb[i].smb1.name))    prnt(MxSmb[i].smb1.name); 
         
         // get _Digits per each symbol
         MxSmb[i].smb1.digits=csmb.Digits();
         
         //Convert slippage from integer to decimal points. We need such a format for further calculations
         MxSmb[i].smb1.dev=csmb.TickSize()*DEVIATION;         
         
         // to convert quotes to the number of points, we will often need to divide the price into _Point value
         // it is better to present this value as 1/Point so that division is replaced with multiplication
         // there is no check for csmb.Point() by 0, since it cannot be equal to 0, and if the parameter is not received
         // for some reason, the triangle is sorted out by the if (!csmb.Name(MxSmb[i].smb1.name)) line	         
         MxSmb[i].smb1.Rpoint=int(NormalizeDouble(1/csmb.Point(),0));
         
         // number of decimal places we round the lot down to. Its calculation is easy = number of decimal places in the LotStep variable
         MxSmb[i].smb1.digits_lot=csup.NumberCount(csmb.LotsStep());
         
         // normalized volume limitations
         MxSmb[i].smb1.lot_min=NormalizeDouble(csmb.LotsMin(),MxSmb[i].smb1.digits_lot);
         MxSmb[i].smb1.lot_max=NormalizeDouble(csmb.LotsMax(),MxSmb[i].smb1.digits_lot);
         MxSmb[i].smb1.lot_step=NormalizeDouble(csmb.LotsStep(),MxSmb[i].smb1.digits_lot); 
         
         //contract size 
         MxSmb[i].smb1.contract=csmb.ContractSize();
         
         // the same as above but taken from the symbol 2
         if (!csmb.Name(MxSmb[i].smb2.name))    prnt(MxSmb[i].smb2.name);
         MxSmb[i].smb2.digits=csmb.Digits();
         MxSmb[i].smb2.dev=csmb.TickSize()*DEVIATION;
         MxSmb[i].smb2.Rpoint=int(NormalizeDouble(1/csmb.Point(),0));
         MxSmb[i].smb2.digits_lot=csup.NumberCount(csmb.LotsStep());
         MxSmb[i].smb2.lot_min=NormalizeDouble(csmb.LotsMin(),MxSmb[i].smb2.digits_lot);
         MxSmb[i].smb2.lot_max=NormalizeDouble(csmb.LotsMax(),MxSmb[i].smb2.digits_lot);
         MxSmb[i].smb2.lot_step=NormalizeDouble(csmb.LotsStep(),MxSmb[i].smb2.digits_lot);         
         MxSmb[i].smb2.contract=csmb.ContractSize();
         
         // the same as above but taken from the symbol 3
         if (!csmb.Name(MxSmb[i].smb3.name))    prnt(MxSmb[i].smb3.name);
         MxSmb[i].smb3.digits=csmb.Digits();
         MxSmb[i].smb3.dev=csmb.TickSize()*DEVIATION;
         MxSmb[i].smb3.Rpoint=int(NormalizeDouble(1/csmb.Point(),0));
         MxSmb[i].smb3.digits_lot=csup.NumberCount(csmb.LotsStep());
         MxSmb[i].smb3.lot_min=NormalizeDouble(csmb.LotsMin(),MxSmb[i].smb3.digits_lot);
         MxSmb[i].smb3.lot_max=NormalizeDouble(csmb.LotsMax(),MxSmb[i].smb3.digits_lot);
         MxSmb[i].smb3.lot_step=NormalizeDouble(csmb.LotsStep(),MxSmb[i].smb3.digits_lot);           
         MxSmb[i].smb3.contract=csmb.ContractSize();   
         
         // align the trade volume
         // there are limitations both for currency pair and the entire triangle
         // pair limitations are written here: MxSmb[i].smbN.lotN
         // Triangle limitations are written here: MxSmb[i].lotN
         
         // select the maximum value of all the minimum ones. Round it by the largest value
         // this whole block of code is made only for the case when the volumes are approximately as follows: 0.01+0.01+0.1
         // in this case, the minimum possible trade volume is set to 0.1 and rounded to 1 decimal place
         double lt=MathMax(MxSmb[i].smb1.lot_min,MathMax(MxSmb[i].smb2.lot_min,MxSmb[i].smb3.lot_min));
         MxSmb[i].lot_min=NormalizeDouble(lt,(int)MathMax(MxSmb[i].smb1.digits_lot,MathMax(MxSmb[i].smb2.digits_lot,MxSmb[i].smb3.digits_lot)));
         
         //take the minimum volume value out of the maximum ones and round it immediately as well
         lt=MathMin(MxSmb[i].smb1.lot_max,MathMin(MxSmb[i].smb2.lot_max,MxSmb[i].smb3.lot_max));
         MxSmb[i].lot_max=NormalizeDouble(lt,(int)MathMax(MxSmb[i].smb1.digits_lot,MathMax(MxSmb[i].smb2.digits_lot,MxSmb[i].smb3.digits_lot)));
         
         // If there is 0 in the trade volume input parameters, use the least possible volume but not the least one is taken per each pair,
         // but rather the least one for all pairs.
         if (lot==0)
         {
            MxSmb[i].smb1.lot=MxSmb[i].lot_min;
            MxSmb[i].smb2.lot=MxSmb[i].lot_min;
            MxSmb[i].smb3.lot=MxSmb[i].lot_min;
         } else
         {
            // if you need to align the volume, then you know the value for pairs 1 and 2, while the volume of the third one is calculated right before the entry
            MxSmb[i].smb1.lot=lot;  
            MxSmb[i].smb2.lot=lot;
            
            // if the input trade volume does not fall within the current limitations, the triangle is not used in work
            // use an alert to inform of that
            if (lot<MxSmb[i].smb1.lot_min || lot>MxSmb[i].smb1.lot_max || lot<MxSmb[i].smb2.lot_min || lot>MxSmb[i].smb2.lot_max) 
            {
               MxSmb[i].smb1.name="";
               Alert("Triangle: "+MxSmb[i].smb1.name+" "+MxSmb[i].smb2.name+" "+MxSmb[i].smb3.name+" - not correct the trading volume");
               continue;
            }            
         }
      }
   }


