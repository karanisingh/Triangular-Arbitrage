//search for the unoccupied magic number

#include "head.mqh"

ulong fnMagicGet(stThree &MxSmb[],ulong magic)
   {
      int mxsize=ArraySize(MxSmb);
      bool find;
      
      // we can go through all open triangles in our array
      // but I have selected another option - go through the range of magic numbers, I believe, this is faster,
      // then move the selected magic number along the array
      for(ulong i=magic;i<magic+MAGIC;i++)
      {
         find=false;
         
         // magic number in i. check if it is assigned to some open triangle
         for(int j=0;j<mxsize;j++)
         if (MxSmb[j].status>0 && MxSmb[j].magic==i)
         {
            find=true;
            break;   
         }   
         
         // if no magic number is used, then exit the loop without waiting for it to end   
         if (!find) return(i);            
      }  
      return(0);  
   }