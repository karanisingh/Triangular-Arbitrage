//Various checks at the start of the robot. 
//in particular, here we inform of a contract size not being equal to standard 100 000 units

#include "head.mqh"

void fnWarning(int &accounttype, double lot, int &fh)
   {   
      // let's check if the trade volume is set correctly, we cannot trade a negative volume
      if (lot<0)
      {
         Alert("Trade volume < 0");  
         ExpertRemove();         
      }      
      
      // if trade volume is 0, warn that the robot will automatically use the minimum possible volume
      if (lot==0) Alert("Always use the same minimum trading volume");  
      
      // since the robot is written in a procedural style, we have to create several global variables
      // one of them is the log file handle. The name consists of a fixed part and the robot start date - this is made for ease of
      // control, so that you do not search where the log starts for a particular start.
      // note that the name changes at each new start rather than after a certain time
      // a previous file (if any) is deleted.
      
      // the EA uses 2 files in its work: the first one is the file with detected triangles, it is created only
      // at user's discretion and the second one is the log file the time of triangle opening and closing is written to,
      // Open prices and some additional data for ease of control
      // the logging remains active at all times           
                  
      // a log file is created only if the triangles file creation mode is not selected                                  
      if(inMode!=CREATE_FILE)
      {
         string name=FILELOG+TimeToString(TimeCurrent(),TIME_DATE)+".csv";      
         FileDelete(name);      
         fh=FILEOPENWRITE(name);
         if (fh==INVALID_HANDLE) Alert("The log file is not created");      
      }   
      
      // in most cases, the broker's contract size for currency pairs = 100 000, but sometimes, there may be exceptions
      // however, they are so rare that it is easier to check this value at startup, and if it is not 100 000, then report it,
      // to allow the user to decide on their own if this is important and resume the work without describing the cases when 
      // the triangle has pairs having different contract size
      for(int i=SymbolsTotal(true)-1;i>=0;i--)
      {
         string name=SymbolName(i,true);
         
         // the function of checking a symbol for availability, also used when forming triangles.
         // we will consider it in more detail there
         if(!fnSmbCheck(name)) continue;
         
         double cs=SymbolInfoDouble(name,SYMBOL_TRADE_CONTRACT_SIZE);
         if(cs!=100000) Alert("Attention: "+name+", contract size = "+DoubleToString(cs,0));      
      }
      
      // get the account type: hedging or netting
      accounttype=(int)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   }

