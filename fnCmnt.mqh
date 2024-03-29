//display comments on the screen

#include "head.mqh"

void fnCmnt(stThree &MxSmb[], ushort lcOpenThree)
   {     
      int total=ArraySize(MxSmb);
      
      string line="=============================\n";
      string txt=line+MQLInfoString(MQL_PROGRAM_NAME)+": ON\n";
      txt=txt+"Total triangles: "+(string)total+"\n";
      txt=txt+"Open triangles: "+(string)lcOpenThree+"\n"+line;
      
      // maximum number of displayed triangles
      short max=5;
      max=(short)MathMin(total,max);
      
      //display 5 triangles nearest for opening
      short index[];// array of indices
      ArrayResize(index,max);
      ArrayInitialize(index,-1);// -1 - not used
      short cnt=0,num=0;
      while(cnt<max && num<total)   //use the first max of the not opened triangle indices for start
      {
         if(MxSmb[num].status!=0)  {num++;continue;}
         index[cnt]=num;
         num++;cnt++;         
      }
      
      // there is point in sorting and searching only if the number of elements exceeds the allowed value
      if (total>max) 
      for(short i=max;i<total;i++)
      {
         // open triangles are displayed below
         if(MxSmb[i].status!=0) continue;
         
         for(short j=0;j<max;j++)
         {
            if (MxSmb[i].PLBuy>MxSmb[index[j]].PLBuy)  {index[j]=i;break;}
            if (MxSmb[i].PLSell>MxSmb[index[j]].PLSell)  {index[j]=i;break;}
         }   
      }
      
      // display the triangles that are the nearest for opening
      bool flag=true;
      for(short i=0;i<max;i++)
      {
         cnt=index[i];
         if (cnt<0) continue;
         if (flag)
         {
            txt=txt+"Smb1           Smb2           Smb3         P/L Buy        P/L Sell        Spread\n";
            flag=false;
         }         
         txt=txt+MxSmb[cnt].smb1.name+" + "+MxSmb[cnt].smb2.name+" + "+MxSmb[cnt].smb3.name+":";
         txt=txt+"      "+DoubleToString(MxSmb[cnt].PLBuy,2)+"          "+DoubleToString(MxSmb[cnt].PLSell,2)+"            "+DoubleToString(MxSmb[cnt].spread,2)+"\n";      
      }            
      
      // display open triangles
      txt=txt+line+"\n";
      for(int i=total-1;i>=0;i--)
      if (MxSmb[i].status==2)
      {
         txt=txt+MxSmb[i].smb1.name+"+"+MxSmb[i].smb2.name+"+"+MxSmb[i].smb3.name+" P/L: "+DoubleToString(MxSmb[i].pl,2);
         txt=txt+"  Time open: "+TimeToString(MxSmb[i].timeopen,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
         txt=txt+"\n";
      }   
      Comment(txt);
   }