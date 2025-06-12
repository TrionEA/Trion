public class FileSharepointTestDk1{
    //@AuraEnabled
    public STRING getEmailFileData(String emailMessageId){
        //emailMessageId = emailMessageId.right(19).left(18);
        //system.debug('message id '+emailMessageId);
        Case_Email__c caseEmail = [Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                                   LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, 
                                   LastReferencedDate, Case__c, Case_Email_Number__c, Case_Number__c, EmailMessage_Id__c, 
                                   Email_Message_SharePoint_Id__c, Email_Message_Created_Date__c, Case_Id__c, Email_Message_SP_Folder_Id__c
                                   from Case_Email__c where EmailMessage_Id__c =: emailMessageId limit 1];
        String sharepointfileid = caseEmail.Files_SP_Id__c;
        System.debug('string sharepointfileid='+sharepointfileid);
        
        List<Account> accList=[Select id,name,Description,File_Test__c from account where id='001VE000007msGcYAI'];

        //csvSPID.add(sharepointid);
        //System.debug('List<id> csvSPID='+csvSPID);            
        Blob headerValue;
        String body;
        String lines;
        Map<String, String> fileInfo = new Map<String, String>();    
        try{
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setHeader('Accept', 'application/json;odata=verbose');
            req.setEndpoint('callout:Sharepoint/v1.0/drives/b!3RPB15XxtkSn_wJ9OGDxDwymYO9ecrFLrZXuL7fJXMpOcHHo4EI6TZMW56RJH70a/items/'+sharepointfileid+'/content');
            HTTPResponse res = new Http().send(req);
            try{
                while (res.getStatusCode() == 302) {
                    req.setEndpoint(res.getHeader('Location'));
                    res = new Http().send(req);
                }
            }catch(exception o){
                System.debug('Catch exception1'+o.getMessage());
            }
            
             headerValue= blob.valueOf(res.getBody());
            
             body = EncodingUtil.base64Encode(headerValue);
            
             lines = res.getBody();
            System.debug('headerValue'+headerValue);
            System.debug('body'+body);
            System.debug('lines'+lines);
            
            //system.debug('csv returned '+csvInfo);
            //return csvInfo;
            
            for(Account acc:accList){
                acc.Description=body;
                acc.File_Test__c=body;
            }
            update accList;
        }catch(exception p){
            System.debug('Catch exception1'+p.getMessage());
        }
        //return headerValue;
        return body;
        //return lines;

        
     }
}