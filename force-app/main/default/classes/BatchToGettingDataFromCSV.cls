global class BatchToGettingDataFromCSV implements Database.Batchable<SObject>, Database.AllowsCallouts {
     Public String Header1;
     Public String Header2;
     Public String Header3;
     Public String Header4;
     Public String Header5;
     Public String Header6;
     Public String Header7;
     Public String Header8;
     Public String Header9;
     Public String Header10; 
     Public String Header11;
     Public String Header12;
     Public String Header13;
     Public String Header14;
     Public String Header15;
     Public String Header16;
     Public String Header17;
     Public String Header18;
     Public String Header19;
     Public String Header20;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id,	Email_Message_SharePoint_Id__c,EmailMessage_Id__c FROM Case_Email__c'); 
    }
    global void execute(Database.BatchableContext BC, List<Case_Email__c> scope) {
        List<String> spo_sitenames = new List<String>();
        spo_sitenames.add('IT');
        String spo_file = 'EmailMessageDetails_02sVE000000GrmjYAC(5).csv';
        try{
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setHeader('Accept', 'application/json;odata=verbose');
            req.setEndpoint('callout:Sharepoint/v1.0/drives/b!3RPB15XxtkSn_wJ9OGDxDwymYO9ecrFLrZXuL7fJXMpOcHHo4EI6TZMW56RJH70a/items/01SCG6PXINI7XQLMIN55EL6QGSDVIYDVDL/content');
            HTTPResponse res = new Http().send(req);
            try{
                while (res.getStatusCode() == 302) {
                    req.setEndpoint(res.getHeader('Location'));
                    res = new Http().send(req);
                }
            }catch(exception o){
                System.debug('Catch exception1'+o.getMessage());
            }
            Blob headerValue= blob.valueOf(res.getBody());
            System.debug('headerValue is'+headerValue);
            String body = EncodingUtil.base64Encode(headerValue);
            System.debug('body is'+body);
            System.debug('Status code is'+res.getStatusCode());
            System.debug('get body is'+res.getBody());
            List<String> lines = res.getBody().split('\n');
            System.debug('List<String> lines is'+lines);
            System.debug('List<String> lines is size'+lines.size());
            List<String>Headers=lines[0].split(',');
            List<String>ValuesHe=lines[1].split(',');
          List<String>lisValues=new List<String>();
            for (String line : lines) {
                System.debug('Processing line: ' + line);

                List<String> values = line.split(',');

 
 
                for (String value : values) {
                    //System.debug('Value: ' + value);
                    lisValues.add(value);
                }
            }
           // System.debug('Values are :'+lisValues);
            //System.debug('Size  is :'+lisValues.size());
            System.debug('Headers size is: '+Headers.size());
            System.debug('Headers  are: '+Headers);
            System.debug('values size is: '+ValuesHe.size());
               System.debug('values are : '+ValuesHe);
           Map<String,String>MapHeadersValues=new  Map<String,String>();
            for(integer i=0;i<Headers.size();i++){
                    MapHeadersValues.put(Headers[i],ValuesHe[i]);
            }
          //  System.debug('Map is: '+MapHeadersValues);
            for(Integer i=0;i<Headers.size();i++){
                if(Headers[i].equals('Header 1')){
                    Header1=MapHeadersValues.get(Headers[i]);
                      System.debug('Header1 is :'+Header1);
                }
                else if(Headers[i].equals('Header 2')){
                     Header2=MapHeadersValues.get(Headers[i]);
                      System.debug('Header2 is :'+Header2);
                }
                else if(Headers[i].equals('Header 3')){
                    Header3=MapHeadersValues.get(Headers[i]);
                      System.debug('Header3 is :'+Header3);
                }
                else if(Headers[i].equals('Header 4')){
                     Header4=MapHeadersValues.get(Headers[i]);
                      System.debug('Header4 is :'+Header4);
                }
                else if(Headers[i].equals('Header 5')){
                      Header5=MapHeadersValues.get(Headers[i]);
                      System.debug('Header5 is :'+Header5);
                }
                else if(Headers[i].equals('Header 6')){
                    	  Header6=MapHeadersValues.get(Headers[i]);
                      System.debug('Header6 is :'+Header6);
                }
                else if(Headers[i].equals('Header 7')){
                      Header7=MapHeadersValues.get(Headers[i]);
                      System.debug('Header7 is :'+Header7);
                }
                else if(Headers[i].equals('Header 8')){
                      Header8=MapHeadersValues.get(Headers[i]);
                      System.debug('Header8 is :'+Header8);
                }
                else if(Headers[i].equals('Header 9')){
                      Header9=MapHeadersValues.get(Headers[i]);
                      System.debug('Header9 is :'+Header9);
                }
                else if(Headers[i].equals('Header 10')){
                     Header10=MapHeadersValues.get(Headers[i]);
                      System.debug('Header10 is :'+Header10);
                }
                else if(Headers[i].equals('Header 11')){
                      Header11=MapHeadersValues.get(Headers[i]);
                      System.debug('Header11 is :'+Header11);
                }
                else if(Headers[i].equals('Header 12')){
                       Header12=MapHeadersValues.get(Headers[i]);
                      System.debug('Header12 is :'+Header12);
                }
                else if(Headers[i].equals('Header 13')){
                      Header13=MapHeadersValues.get(Headers[i]);
                      System.debug('Header13 is :'+Header13);
                }
                else if(Headers[i].equals('Header 14')){
                     Header14=MapHeadersValues.get(Headers[i]);
                      System.debug('Header14 is :'+Header14);
                }
                else if(Headers[i].equals('Header 15')){
                     Header15=MapHeadersValues.get(Headers[i]);
                      System.debug('Header15 is :'+Header15);
                }
                else if(Headers[i].equals('Header 16')){
                     Header16=MapHeadersValues.get(Headers[i]);
                      System.debug('Header16 is :'+Header16);
                }
                else if(Headers[i].equals('Header 17')) {
                     Header17=MapHeadersValues.get(Headers[i]);
                      System.debug('Header17 is :'+Header17);
                }
                else if(Headers[i].equals('Header 18')){
                     Header18=MapHeadersValues.get(Headers[i]); 
                      System.debug('Header18 is :'+Header18);
                }
                else if(Headers[i].equals('Header 19')){
                     Header19=MapHeadersValues.get(Headers[i]);
                     System.debug('Header19 is :'+Header19);
                }
                else{
                     Header20=MapHeadersValues.get(Headers[i]);
                    System.debug('Header20 is :'+Header20);
                    System.debug('test');
 
                }
 
                }

        }catch(exception e){
            System.debug('Catch exception'+e.getMessage());
        }


    }
    global void finish(Database.BatchableContext BC) {
        System.debug('Batch is completed');
    }
}