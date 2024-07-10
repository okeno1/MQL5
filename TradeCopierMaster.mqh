#include <Trade/PositionInfo.mqh>


int OnInit(){
   Print("Init function");

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){

}

void OnTick(){
   //string url = "https://xxx.php";
   string headers;
   char post[];
   char result[]; 
   string resultHeaders;
   string text;
   
   for(int i= PositionsTotal()-1; i >= 0; i--){
      CPositionInfo pos;
      if(pos.SelectByIndex(i)){
        // string text;
         StringConcatenate(text
                           ,text
                           ,pos.Ticket(),";"
                           ,pos.Symbol(),";"
                           ,pos.Volume(),";"
                           ,pos.PositionType(),";"
                           ,pos.PriceOpen(),";"
                           ,pos.TakeProfit(),";"
                           ,pos.StopLoss(),"|");         
      }
   }
    //string mode = (i < PositionsTotal()-1) ? "a" : "w";
    string mode = "w";
    
    string postText;
    //StringConcatenate(postText,"text=",text,"&mode=",mode);
    StringConcatenate(postText,"text=",text);
    StringToCharArray(postText,post,0,WHOLE_ARRAY,CP_UTF8);
    
    Print("Sending data: ", postText);
    
    int response = WebRequest("POST",url,NULL,headers,1000,post,500,result,resultHeaders);
    
    if(response != 200){
      Print(__FUNCTION__,"> Server response is:", response," and the error is: ",GetLastError());
      string resultText = CharArrayToString(result);
      Print(__FUNCTION__,"> ",resultText);
    }
   
}
