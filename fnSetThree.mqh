//form the working triangles

#include "head.mqh"

void fnSetThree(stThree &MxSmb[],enMode mode)
   {
      // reset our array of triangles
      ArrayFree(MxSmb);
      
      // see whether we are in the tester or not
      if((bool)MQLInfoInteger(MQL_TESTER))
      {
         // if yes, look for the symbols file and launch the uploading of triangles from the file
         if(FileIsExist(FILENAME)) fnGetThreeFromFile(MxSmb);
         
         // if the file is not found, go through all available symbols looking for the default EURUSD+GBPUSD+EURGBP triangle
         else{               
            char cnt=0;         
            for(int i=SymbolsTotal(false)-1;i>=0;i--)
            {
               string smb=SymbolName(i,false);
               if ((SymbolInfoString(smb,SYMBOL_CURRENCY_BASE)=="EUR" && SymbolInfoString(smb,SYMBOL_CURRENCY_PROFIT)=="GBP") ||
               (SymbolInfoString(smb,SYMBOL_CURRENCY_BASE)=="EUR" && SymbolInfoString(smb,SYMBOL_CURRENCY_PROFIT)=="USD") ||
               (SymbolInfoString(smb,SYMBOL_CURRENCY_BASE)=="GBP" && SymbolInfoString(smb,SYMBOL_CURRENCY_PROFIT)=="USD"))
               {
                  if (SymbolSelect(smb,true)) cnt++;
               }               
               else SymbolSelect(smb,false);
               if (cnt>=3) break;
            }  
            
            // after uploading the default triangle to the Market Watch, start forming the triangle         
            fnGetThreeFromMarketWatch(MxSmb);
         }
         return;
      }
      
      // if we are not in the tester, look at the mode selected by the user
      // take the files from the Market Watch or the file
      if(mode==STANDART_MODE || mode==CREATE_FILE) fnGetThreeFromMarketWatch(MxSmb);
      if(mode==USE_FILE) fnGetThreeFromFile(MxSmb);     
   }
//+------------------------------------------------------------------+

//received triangles from the file
void fnGetThreeFromFile(stThree &MxSmb[])
   {
      // if no symbol file is found, print them and complete the work
      int fh=FILEOPENREAD(FILENAME);
      if(fh==INVALID_HANDLE)
      {
         Print("File with symbols not read!");
         ExpertRemove();
      }
      
      // move the carriage to the file start
      FileSeek(fh,0,SEEK_SET);
      
      // skip the header, i.e. the first file line      
      while(!FileIsLineEnding(fh)) FileReadString(fh);
      
      
      while(!FileIsEnding(fh) && !IsStopped())
      {
         // get three triangle symbols. Perform the basic check for the data availability.
         // the robot is able to form the triangles file automatically, and if the user has suddenly
         // changed it independently and incorrectly, we assume this has been done deliberately
         string smb1=FileReadString(fh);
         string smb2=FileReadString(fh);
         string smb3=FileReadString(fh);
         
         // if symbol data are available, write it to our triangles array after scrolling to the end of the line
         if (!csmb.Name(smb1) || !csmb.Name(smb2) || !csmb.Name(smb3)) {while(!FileIsLineEnding(fh)) FileReadString(fh);continue;}
         
         int cnt=ArraySize(MxSmb);
         ArrayResize(MxSmb,cnt+1);
         MxSmb[cnt].smb1.name=smb1;
         MxSmb[cnt].smb2.name=smb2;
         MxSmb[cnt].smb3.name=smb3;
         while(!FileIsLineEnding(fh)) FileReadString(fh);
      }
   }

//get triangles from the Market Watch
void fnGetThreeFromMarketWatch(stThree &MxSmb[])
   {
      // get the total number of symbols
      int total=SymbolsTotal(true);
      
      // variables for comparing a contract size    
      double cs1=0,cs2=0;              
      
      // take the first symbol from the list in the first loop
      for(int i=0;i<total-2 && !IsStopped();i++)    
      {//1
         string sm1=SymbolName(i,true);
         
         // check the symbol for various limitations
         if(!fnSmbCheck(sm1)) continue;      
              
         // get the contract size and normalize it at once, since we are to compare this value later on
         if (!SymbolInfoDouble(sm1,SYMBOL_TRADE_CONTRACT_SIZE,cs1)) continue; 
         cs1=NormalizeDouble(cs1,0);
         
         // get the base currency and profit currency, since they are used for comparison rather than the pair name
         // therefore, various prefixes and suffixes set by brokers do not affect the operation
         string sm1base=SymbolInfoString(sm1,SYMBOL_CURRENCY_BASE);     
         string sm1prft=SymbolInfoString(sm1,SYMBOL_CURRENCY_PROFIT);
         
         // take the next symbol from the list in the second loop
         for(int j=i+1;j<total-1 && !IsStopped();j++)
         {//2
            string sm2=SymbolName(j,true);
            if(!fnSmbCheck(sm2)) continue;
            if (!SymbolInfoDouble(sm2,SYMBOL_TRADE_CONTRACT_SIZE,cs2)) continue;
            cs2=NormalizeDouble(cs2,0);
            string sm2base=SymbolInfoString(sm2,SYMBOL_CURRENCY_BASE);
            string sm2prft=SymbolInfoString(sm2,SYMBOL_CURRENCY_PROFIT);
            
            // the first and second pairs should have one match of any of the currencies
            // otherwise, it is impossible to form a triangle    
            // there is no point to perform a full identity check because if the pairs are, for example,
            // eurusd and eurusd.xxx, it is impossible to form a triangle of them anyway
            if(sm1base==sm2base || sm1base==sm2prft || sm1prft==sm2base || sm1prft==sm2prft); else continue;
                  
            // contract size should be the same            
            if (cs1!=cs2) continue;
            
            // search for the last triangle symbol in the third loop
            for(int k=j+1;k<total && !IsStopped();k++)
            {//3
               string sm3=SymbolName(k,true);
               if(!fnSmbCheck(sm3)) continue;
               if (!SymbolInfoDouble(sm3,SYMBOL_TRADE_CONTRACT_SIZE,cs1)) continue;
               cs1=NormalizeDouble(cs1,0);
               string sm3base=SymbolInfoString(sm3,SYMBOL_CURRENCY_BASE);
               string sm3prft=SymbolInfoString(sm3,SYMBOL_CURRENCY_PROFIT);
               
               // we know that the first and second symbols have one common currency. To form a triangle, we should find
               // the third currency pair having a currency matching any currency from the first symbol, while its second currency matches
               // any currency from the second one, if there are no matches, the pair is not suitable
               if(sm3base==sm1base || sm3base==sm1prft || sm3base==sm2base || sm3base==sm2prft);else continue;
               if(sm3prft==sm1base || sm3prft==sm1prft || sm3prft==sm2base || sm3prft==sm2prft);else continue;
               if (cs1!=cs2) continue;
               
               // reaching this stage means that all checks have already been passed and three detected pairs are suitable for forming a triangle
               // write it to our array
               int cnt=ArraySize(MxSmb);
               ArrayResize(MxSmb,cnt+1);
               MxSmb[cnt].smb1.name=sm1;
               MxSmb[cnt].smb2.name=sm2;
               MxSmb[cnt].smb3.name=sm3;
               break;
            }//3
         }//2
      }//1    
   }
