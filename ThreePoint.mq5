#property copyright "A.V. Oreshkin"
#property link      "https://vk.com/tradingisfun"
#property version   "1.10"
#property description "Three Point Arbitrage. Low risk trading system."
#property description "1: EA use magic numer from input menu to +200"
#property description "2: If Trade volume=0 to use the minimal possible trade volume"
#property description "3: The whole log is written to the file: Three Point Arbitrage Control YYYY.MM.DD.csv"
#property description "4: Before testing, you must сreate file with symbols"
#property description "5: If file with symbols is not created then you use triangle by default: EURUSD+GBPUSD+EURGBP"
#property icon "\\Experts\\Arbitrage\\ThreePoint\\ThreePoint.ico"

#include "head.mqh"
#property tester_file FILENAME

int OnInit()
   {
      Print("===============================================\nStart EA: "+MQLInfoString(MQL_PROGRAM_NAME));
      
      fnWarning(glAccountsType,inLot,glFileLog);         //various checks during the robot launch
      fnSetThree(MxThree,inMode);                        //form triangles
      fnChangeThree(MxThree);                            //arrange them properly
      fnSmbLoad(inLot,MxThree);                          //load the remaining data per each symbol
      
      if(inMode==CREATE_FILE)                            //if we only need to create a symbol file for work or tester
      {
         // delete the file (if any).
         FileDelete(FILENAME);  
         int fh=FILEOPENWRITE(FILENAME);
         if (fh==INVALID_HANDLE) 
         {
            Alert("File with symbols not created");
            ExpertRemove();
         }
         // write triangles and some additional data to the file
         fnCreateFileSymbols(MxThree,fh);
         Print("File with symbols created");
         
         // close the file and complete the EA operation
         FileClose(fh);
         ExpertRemove();
      }
      
      if (glFileLog!=INVALID_HANDLE)                  //write used symbols to the log file
         fnCreateFileSymbols(MxThree,glFileLog); 

      fnRestart(MxThree,inMagic,glAccountsType);      //restore the triangles after restarting the robot
    
      ctrade.SetDeviationInPoints(DEVIATION);
      ctrade.SetTypeFilling(ORDER_FILLING_FOK);
      ctrade.SetAsyncMode(true);
      ctrade.LogLevel(LOG_LEVEL_NO);
      
      EventSetTimer(1);
      return(INIT_SUCCEEDED);
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
   {
      FileClose(glFileLog);
      Print("Stop EA: "+MQLInfoString(MQL_PROGRAM_NAME)+"\n===============================================");
      Comment("");
      EventKillTimer();
   }
void OnTick()
   {
      // first, calculate the number of open triangles. This will significantly save the PC resources,
      // since if there is a restriction, and we have reached it, then we do not have to calculate the separations, etc.      
      
      ushort OpenThree=0;  // number of open triangles
      for(int j=ArraySize(MxThree)-1;j>=0;j--)
      if (MxThree[j].status!=0) OpenThree++; //calculate not closed ones as well, since they may hang for quite a long time buy are nevertheless considered
                             
      if (inMaxThree==0 || (inMaxThree>0 && inMaxThree>OpenThree))
         fnCalcDelta(MxThree,inProfit,inCmnt,inMagic,inLot,inMaxThree,OpenThree); // calculate divergence and open at once
      fnOpenCheck(MxThree,glAccountsType,glFileLog);     // check if the opening is successful
      fnCalcPL(MxThree,glAccountsType,inProfit);         // calculate the profit of open triangles
      fnCloseCheck(MxThree,glAccountsType,glFileLog);    // check if the closure is successful
      fnCmnt(MxThree,OpenThree);                         // display comments on the screen
   }
void OnTimer()
   {
      OnTick();
   }   
   
