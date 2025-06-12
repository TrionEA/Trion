public class GetFilesUsingSharepointId {
    
    
    @AuraEnabled(cacheable=true) 
    public static List<Map<String, String>> getSharepointId(String parentCaseId){
               List<Map<String, String>> csvInfoList = new List<Map<String, String>>();

        //List<id> csvSPID=new List<id>();
        List<Case_Email__c> caseEmailList=[Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                                           LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, 
                                           LastReferencedDate, Case__c, Case_Email_Number__c, Case_Number__c, EmailMessage_Id__c, 
                                           Email_Message_SharePoint_Id__c,Files_SP_Id__c, Email_Message_Created_Date__c, Case_Id__c 
                                           from Case_Email__c where Case_Id__c =: parentCaseId];
        
        if(!caseEmailList.isEmpty()){
        System.debug('List<Case_Email__c> caseEmailList='+caseEmailList);
        for(Case_Email__c ce:caseEmailList){
            string sharepointid=ce.Files_SP_Id__c;
            System.debug('string sharepointid='+sharepointid);
            //csvSPID.add(sharepointid);
            //System.debug('List<id> csvSPID='+csvSPID);            
            
            
     
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setHeader('Accept', 'application/json;odata=verbose');
                req.setEndpoint('callout:Sharepoint/v1.0/drives/b!3RPB15XxtkSn_wJ9OGDxDwymYO9ecrFLrZXuL7fJXMpOcHHo4EI6TZMW56RJH70a/items/' + sharepointid + '/content');
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
            System.debug('Content after printing body:'+lines);
           
        }
        }
                return csvInfoList;
        
    }
    
    @AuraEnabled
    public static void getEmailData(String emailMessageId){
        emailMessageId = emailMessageId.right(19).left(18);
        system.debug('message id '+emailMessageId);
        Case_Email__c caseEmail = [Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                                           LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, 
                                           LastReferencedDate, Case__c, Case_Email_Number__c, Case_Number__c, EmailMessage_Id__c, 
                                           Email_Message_SharePoint_Id__c, Email_Message_Created_Date__c, Case_Id__c 
                                           from Case_Email__c where EmailMessage_Id__c =: emailMessageId limit 1];
        string sharepointid = caseEmail.Email_Message_SharePoint_Id__c;
            System.debug('string sharepointid='+sharepointid);
            //csvSPID.add(sharepointid);
            //System.debug('List<id> csvSPID='+csvSPID);            
            
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setHeader('Accept', 'application/json;odata=verbose');
                req.setEndpoint('callout:Sharepoint/v1.0/drives/b!3RPB15XxtkSn_wJ9OGDxDwymYO9ecrFLrZXuL7fJXMpOcHHo4EI6TZMW56RJH70a/items/' + sharepointid + '/content');
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
           
       
    }
}