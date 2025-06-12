global class BatchCSVtoString implements Database.Batchable<SObject>,Database.AllowsCallouts {
     Public String IdOfCsv;
     Public String ParentId;
     Public String CreatedDate;
     Public String TextBody;
     Public String Header;
     Public String Subject;
     Public String FromAddress;
     Public String ToAddress;
     Public String CcAddress;
     Public String BccAddess; 
     Public String MessageDate;
     Public String HtmlBody;
   
   
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
            req.setEndpoint('callout:Sharepoint/v1.0/drives/b!3RPB15XxtkSn_wJ9OGDxDwymYO9ecrFLrZXuL7fJXMpOcHHo4EI6TZMW56RJH70a/items/01SCG6PXOB6WBQUDVSBNCY73GHL5SBARYC/content');
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
            for(integer i=0;i<ValuesHe.size();i++){
                    MapHeadersValues.put(Headers[i],ValuesHe[i++]);
            }
          //  System.debug('Map is: '+MapHeadersValues);
            for(Integer i=0;i<ValuesHe.size();i++){
                if(Headers[i].equals('Id')){
                   IdOfCsv=MapHeadersValues.get(Headers[i]);
                      System.debug('ID is :'+IdOfCsv);
                }
                if(Headers[i].equals('ParentId')){
                    ParentId=MapHeadersValues.get(Headers[i]);
                      System.debug('ParentId is :'+ParentId);
                }
              
                 if(Headers[i].equals('CreatedDate')){
                    CreatedDate=MapHeadersValues.get(Headers[i]);
                      System.debug('CreatedDate is :'+CreatedDate);
                }
                 if(Headers[i].equals('TextBody')){
                     TextBody=MapHeadersValues.get(Headers[i]);
                      System.debug('TextBody is :'+TextBody);
                }
                 if(Headers[i].equals('Header')){
                      Header=MapHeadersValues.get(Headers[i]);
                      System.debug('Header is :'+Header);
                }
                 if(Headers[i].equals('Subject')){
                    	  Subject=MapHeadersValues.get(Headers[i]);
                      System.debug('Subject is :'+Subject);
                }
                 if(Headers[i].equals('FromAddress')){
                      FromAddress=MapHeadersValues.get(Headers[i]);
                      System.debug('FromAddress is :'+FromAddress);
                }
                 if(Headers[i].equals('ToAddress')){
                      ToAddress=MapHeadersValues.get(Headers[i]);
                      System.debug('ToAddress is :'+ToAddress);
                }
                if(Headers[i].equals('CcAddress')){
                      CcAddress=MapHeadersValues.get(Headers[i]);
                      System.debug('CcAddress is :'+CcAddress);
                }
                 if(Headers[i].equals('BccAddess')){
                     BccAddess=MapHeadersValues.get(Headers[i]);
                      System.debug('BccAddess is :'+BccAddess);
                }
                 if(Headers[i].equals('MessageDate')){
                      MessageDate=MapHeadersValues.get(Headers[i]);
                      System.debug('MessageDate is :'+MessageDate);
                }
                 if(Headers[i].equals('HtmlBody')) {
                       HtmlBody=MapHeadersValues.get(Headers[i]);
                      System.debug('HtmlBody is :'+HtmlBody);
                }
            /*  else if(Headers[i].equals('Header 13')){
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
 
                }*/
 
                }

        }catch(exception e){
            System.debug('Catch exception'+e.getMessage());
        }


    }
    global void finish(Database.BatchableContext BC) {
        System.debug('Batch is completed');
    }
}