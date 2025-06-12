global class BatchCSvStr implements Database.Batchable<SObject>,Database.AllowsCallouts {
     Public String IdOfCsv;
     Public String ParentId;
     Public String CreatedDate;
     Public String TextBody;
     Public String Headers;
     Public String Subject;
     Public String FromAddress;
     Public String ToAddress;
     Public String CcAddress;
     Public String BccAddress; 
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
            req.setEndpoint('callout:Sharepoint/v1.0/drives/b!3RPB15XxtkSn_wJ9OGDxDwymYO9ecrFLrZXuL7fJXMpOcHHo4EI6TZMW56RJH70a/items/01SCG6PXLFQ425UVBNGRC2YRGPEI75HJHY/content');
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
          //  System.debug('body is'+body);
           // System.debug('Status code is'+res.getStatusCode());
           // System.debug('get body is'+res.getBody());
            String lines = res.getBody();
            List<String>allValues=lines.split(',');
          //  system.debug('List<String>allValues='+allValues);
            for(INTEGER I=0;I<allValues.SIZE();I++){
                 system.debug('allValues='+allValues[i]);
            }
            List<String>Headers1=New List<String>();
            for(Integer i=0;i<39;i++){
                Headers1.add(allValues[i]);
                System.debug(allValues[i]);
                
            }
            List<String> Values1=new List<String>();
            for(Integer i=39;i<78;i++){
                Values1.add(allValues[i]);
              system.debug(allValues[i]);
            }
            Map<String,String> MapHeadersValues=new Map<String,String>();
            for(Integer i=0;i<39;i++){
			MapHeadersValues.put(Headers1[i],Values1[i]);                
            }
             for(Integer i=0;i<Headers1.size();i++){
            	if(Headers1[i].equals('Id')){
                   IdOfCsv=MapHeadersValues.get(Headers1[i]);
                      System.debug('ID is :'+IdOfCsv);
             	 }
           	    if(Headers1[i].equals('ParentId')){
                    ParentId=MapHeadersValues.get(Headers1[i]);
                      System.debug('ParentId is :'+ParentId);
             	 }
              
             	if(Headers1[i].equals('CreatedDate')){
                    CreatedDate=MapHeadersValues.get(Headers1[i]);
                      System.debug('CreatedDate is :'+CreatedDate);
                 }
                if(Headers1[i].equals('TextBody')){
                     TextBody=MapHeadersValues.get(Headers1[i]);
                      System.debug('TextBody is :'+TextBody);
                 }
                if(Headers1[i].equals('Headers')){
                      Headers=MapHeadersValues.get(Headers1[i]);
                      System.debug('Header is :'+Headers);
                 }
                if(Headers1[i].equals('Subject')){
                    	  Subject=MapHeadersValues.get(Headers1[i]);
                      System.debug('Subject is :'+Subject);
                 }
                if(Headers1[i].equals('FromAddress')){
                      FromAddress=MapHeadersValues.get(Headers1[i]);
                      System.debug('FromAddress is :'+FromAddress);
                 }
                if(Headers1[i].equals('ToAddress')){
                      ToAddress=MapHeadersValues.get(Headers1[i]);
                      System.debug('ToAddress is :'+ToAddress);
                 }
                if(Headers1[i].equals('CcAddress')){
                      CcAddress=MapHeadersValues.get(Headers1[i]);
                      System.debug('CcAddress is :'+CcAddress);
                }
                if(Headers1[i].equals('BccAddress')){
                     BccAddress=MapHeadersValues.get(Headers1[i]);
                      System.debug('BccAddress is :'+BccAddress);
                 }
                if(Headers1[i].equals('MessageDate')){
                      MessageDate=MapHeadersValues.get(Headers1[i]);
                      System.debug('MessageDate is :'+MessageDate);
                 }
                if(Headers1[i].equals('HtmlBody')) {
                       HtmlBody=MapHeadersValues.get(Headers1[i]);
                      System.debug('HtmlBody is :'+HtmlBody);
                 }
             }
            System.debug('Size of values are: '+Values1.size());
           System.debug('Size is: '+Headers1.size());
       // System.debug('size of all valiuses is: '+allValues.size());
          //	System.debug(lines);
        }catch(exception e){
            System.debug('Catch exception'+e.getMessage());
        }
        
        Contact con=[select id,Description,Id__c,ParentId__c,Created_Date__c,Text_Body__c,Headers__c,Subject__c,From_Address__c,To_Address__c,CC_Address__c,BCC_Address__c,HTML_Body__c,Message_date__c from Contact where id='003VE000002xkP3YAI'];
       
          con.Id__c=IdOfCsv;
         con.description='';
          con.ParentId__c=ParentId;
          con.Created_Date__c= CreatedDate;
          con.Text_Body__c=TextBody;
          con.Headers__c=Headers;
          con.Subject__c=Subject;
          con.From_Address__c=FromAddress;
          con.To_Address__c=ToAddress;
          con.CC_Address__c=CcAddress;
          con.BCC_Address__c=BccAddress;
          con.Message_date__c=MessageDate;
          con.HTML_Body__c=HtmlBody;
          
        Update con;


    }
    global void finish(Database.BatchableContext BC) {
        System.debug('Batch is completed');
    }
}