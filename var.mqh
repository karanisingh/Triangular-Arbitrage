#include "head.mqh"

// macros
#define DEVIATION       3                                      // maximum possible slippage
#define FILENAME        "Three Point Arbitrage.csv"            // symbols for work are stored here
#define FILELOG         "Three Point Arbitrage Control "       // part of the log file name
#define FILEOPENWRITE(nm)  FileOpen(nm,FILE_UNICODE|FILE_WRITE|FILE_SHARE_READ|FILE_CSV)  // open file for writing
#define FILEOPENREAD(nm)   FileOpen(nm,FILE_UNICODE|FILE_READ|FILE_SHARE_READ|FILE_CSV)   // open file for reading
#define CF              1.2                                    // increase ratio for margin
#define MAGIC           200                                    // range of applied magic numbers
#define MAXTIMEWAIT     3                                      // maximum waiting time for the triangle to open, in seconds

// currency pair structure
struct stSmb
   {
      string            name;            // Currency pair
      int               digits;          // Number of decimal places in a quote
      uchar             digits_lot;      // Number of decimal places in a lot, for rounding
      int               Rpoint;          // 1/point, in order to multiply (rather than divide) by this value in the equations
      double            dev;             // Possible slippage. Converting it into points at once
      double            lot;             // Trade volume for a currency pair
      double            lot_min;         // Minimum volume
      double            lot_max;         // Maximum volume
      double            lot_step;        // Lot step
      double            contract;        // Contract size
      double            price;           // Pair open price in the triangle. Needed for netting
      ulong              tkt;            // Ticket of an order used to open a trade. Needed for convenience in hedge accounts
      MqlTick           tick;            // Current pair prices
      double            tv;              // Current tick price
      double            mrg;             // Current margin necessary for opening
      double            sppoint;         // Spread in integer point
      double            spcost;          // Spread in money per the current opened lot
      stSmb(){price=0;tkt=0;mrg=0;}   
   };

// Structure for the triangle
struct stThree
   {
      stSmb             smb1;
      stSmb             smb2;
      stSmb             smb3;
      double            lot_min;          // Minimum volume for the entire triangle
      double            lot_max;          // Maximum volume for the entire triangle     
      ulong             magic;            // Triangle magic number
      uchar             status;           // Triangle status. 0 - not used. 1 - sent for opening. 2 - successfully opened. 3 - sent for closing
      double            pl;               // Triangle profit
      datetime          timeopen;         // Time the triangle sent for opening
      double            PLBuy;            // Potential profit when buying triangle
      double            PLSell;           // Potential profit when selling triangle
      double            spread;           // Total price of all three spreads with commission
      stThree(){status=0;magic=0;}
   };

  
// EA operation modes  
enum enMode
   {
      STANDART_MODE  =  0, /*Symbols from Market Watch*/                //Standard operation mode. Market Watch symbols//
      USE_FILE       =  1, /*Symbols from file*/                        //Use symbols file
      CREATE_FILE    =  2, /*Create file with symbols*/                 //Create the file for the tester or for work
      //END_ADN_CLOSE  =  3, /*Not open, wait profit, close & exit*/      //Close all your trades and end work
      //CLOSE_ONLY     =  4  /*Not open, not wait profit, close & exit*/
   };


stThree  MxThree[];           // Main array storing working triangles and all necessary additional data

CTrade         ctrade;        // CTrade class of the standard library
CSymbolInfo    csmb;          // CSymbolInfo class of the standard library
CSupport       csup;          // auxiliary class for frequently used functions
CTerminalInfo  cterm;         // CTerminalInfo class of the standard library

int         glAccountsType=0; // account type: hedging or netting
int         glFileLog=0;      // Log file handle


// Inputs

sinput      enMode      inMode=     0;          //Job mode
input       double      inProfit=   0;          //Commission
input       double      inLot=      1;          //Trade volume
input       ushort      inMaxThree= 0;          //Together triangles open
sinput      ulong       inMagic=    300;        //EA number
sinput      string      inCmnt=     "R ";       //Comment



