global class BatchCSVtoStringComma implements Database.Batchable<SObject>,Database.AllowsCallouts {
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
            req.setEndpoint('callout:Sharepoint/v1.0/drives/b!3RPB15XxtkSn_wJ9OGDxDwymYO9ecrFLrZXuL7fJXMpOcHHo4EI6TZMW56RJH70a/items/01SCG6PXPHLOEXP5R6RZDIULQACTQY52SJ/content');
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
            
            String body = EncodingUtil.base64Encode(headerValue);
            
            String lines = res.getBody();
            List<String>allValues=lines.split(',');
            
            
            List<String> Headers1=New List<String>();
            for(Integer i=0;i<39;i++){
                if(i<=37)
                    Headers1.add(allValues[i]);
                else{
                    Headers1.add('HtmlBody');
                }
                
            }
            List<String>allValues1=lines.split('##  ');
            
            List<String> Values1=new List<String>();
            for(Integer i=1;i<40;i++){
                Values1.add(allValues1[i]);
                System.debug(allValues1[i]);
                
            }
            Map<String,String> MapHeadersValues=new Map<String,String>();
            for(Integer i=0;i<39;i++){
                MapHeadersValues.put(Headers1[i],Values1[i]);
                
            }
            
            
            IdOfCsv=MapHeadersValues.get('Id');
            integer len=IdOfCsv.length();
            IdOfCsv=IdOfCsv.subString(0,(len-3));
            System.debug('ID is :'+IdOfCsv);
            ParentId=MapHeadersValues.get('ParentId');
            integer i=ParentId.length();
            ParentId=ParentId.subString(0,(i-3));
            System.debug('ParentId is :'+ParentId);
            CreatedDate=MapHeadersValues.get('CreatedDate');
            integer j=CreatedDate.length();
            CreatedDate=CreatedDate.subString(0,(j-3));
            
            System.debug('CreatedDate is :'+CreatedDate);
            TextBody=MapHeadersValues.get('TextBody');
            integer k=TextBody.length();
            TextBody=TextBody.subString(0,(k-3));
            
            
            
            System.debug('TextBody is :'+TextBody);
            Headers=MapHeadersValues.get('Headers');
            integer l=Headers.length();
            Headers=Headers.subString(0,(l-3));
            
            System.debug('Header is :'+Headers);
            
            Subject=MapHeadersValues.get('Subject');
            integer m=Subject.length();
            Subject=Subject.subString(0,(m-3));
            
            System.debug('Subject is :'+Subject);
            FromAddress=MapHeadersValues.get('FromAddress');
            integer n=FromAddress.length();
            FromAddress=FromAddress.subString(0,(n-3));
            
            
            System.debug('FromAddress is :'+FromAddress);
            ToAddress=MapHeadersValues.get('ToAddress');
            integer o=ToAddress.length();
            ToAddress=ToAddress.subString(0,(o-3));
            
            System.debug('ToAddress is :'+ToAddress);
            CcAddress=MapHeadersValues.get('CcAddress');
            integer p=CcAddress.length();
            CcAddress=CcAddress.subString(0,(p-3));               
            
            System.debug('CcAddress is :'+CcAddress);
            
            BccAddress=MapHeadersValues.get('BccAddress');
            integer q=BccAddress.length();
            BccAddress=BccAddress.subString(0,(q-3)); 
            System.debug('BccAddress is :'+BccAddress);
            
            
            MessageDate=MapHeadersValues.get('MessageDate');
            integer r=MessageDate.length();
            MessageDate=MessageDate.subString(0,(r-3)); 
            System.debug('MessageDate is :'+MessageDate);
            
            HtmlBody=MapHeadersValues.get('HtmlBody');
            integer s=HtmlBody.length();
            HtmlBody=HtmlBody.subString(0,(s-4)); 
            System.debug('HtmlBody is :'+HtmlBody);
            
            
            
            
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