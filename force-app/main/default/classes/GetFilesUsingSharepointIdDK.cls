public class GetFilesUsingSharepointIdDK{
    
    
    @AuraEnabled(cacheable=true) 
    public static List<Map<String, String>> getSharepointId(String parentCaseId){
        List<Map<String, String>> csvInfoList = new List<Map<String, String>>();
        
        //List<id> csvSPID=new List<id>();
        List<Case_Email__c> caseEmailList=[Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                                           LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate,
                                           LastReferencedDate, Case__c, Case_Email_Number__c, Case_Number__c, EmailMessage_Id__c, 
                                           Email_Message_SharePoint_Id__c, Email_Message_Created_Date__c, Case_Id__c,Email_Message_SP_Folder_Id__c 
                                           from Case_Email__c where Case_Id__c =: parentCaseId];
        
        if(!caseEmailList.isEmpty()){
            System.debug('List<Case_Email__c> caseEmailList='+caseEmailList);
            for(Case_Email__c ce:caseEmailList){
                string sharepointid=ce.Email_Message_SharePoint_Id__c;
                System.debug('string sharepointid='+sharepointid);
                //csvSPID.add(sharepointid);
                //System.debug('List<id> csvSPID='+csvSPID);            
                
                
                try{
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
                    
                    Map<String, String> csvInfo = new Map<String, String>();
                    //csvInfo.put('IdOfCsv', mapHeadersValues.get('Id').subString(0,(MapHeadersValues.get('Id')-3));
                    csvInfo.put('IdOfCsv', String.valueOf(mapHeadersValues.get('Id')).substring(0, (String.valueOf(mapHeadersValues.get('Id')).length() - 3)));
                    // csvInfo.put('ParentId', mapHeadersValues.get('ParentId'));
                    csvInfo.put('ParentId', String.valueOf(mapHeadersValues.get('ParentId')).substring(0, (String.valueOf(mapHeadersValues.get('ParentId')).length() - 3)));
                    //csvInfo.put('CreatedDate', mapHeadersValues.get('CreatedDate'));
                    csvInfo.put('CreatedDate', String.valueOf(mapHeadersValues.get('CreatedDate')).substring(0, (String.valueOf(mapHeadersValues.get('CreatedDate')).length() - 3)));
                    //csvInfo.put('TextBody', mapHeadersValues.get('TextBody'));
                    csvInfo.put('TextBody', String.valueOf(mapHeadersValues.get('TextBody')).substring(0, (String.valueOf(mapHeadersValues.get('TextBody')).length() - 3)));
                    //csvInfo.put('Headers', mapHeadersValues.get('Headers'));
                    csvInfo.put('Headers', String.valueOf(mapHeadersValues.get('Headers')).substring(0, (String.valueOf(mapHeadersValues.get('Headers')).length() - 3)));
                    //csvInfo.put('Subject', mapHeadersValues.get('Subject'));
                    csvInfo.put('Subject', String.valueOf(mapHeadersValues.get('Subject')).substring(0, (String.valueOf(mapHeadersValues.get('Subject')).length() - 3)));
                    //csvInfo.put('FromAddress', mapHeadersValues.get('FromAddress'));
                    csvInfo.put('FromAddress', String.valueOf(mapHeadersValues.get('FromAddress')).substring(0, (String.valueOf(mapHeadersValues.get('FromAddress')).length() - 3)));
                    //csvInfo.put('ToAddress', mapHeadersValues.get('ToAddress'));
                    csvInfo.put('ToAddress', String.valueOf(mapHeadersValues.get('ToAddress')).substring(0, (String.valueOf(mapHeadersValues.get('ToAddress')).length() - 3)));
                    //csvInfo.put('CcAddress', mapHeadersValues.get('CcAddress'));
                    csvInfo.put('CcAddress', String.valueOf(mapHeadersValues.get('CcAddress')).substring(0, (String.valueOf(mapHeadersValues.get('CcAddress')).length() - 3)));
                    //csvInfo.put('BccAddress', mapHeadersValues.get('BccAddress'));
                    csvInfo.put('BccAddress', String.valueOf(mapHeadersValues.get('BccAddress')).substring(0, (String.valueOf(mapHeadersValues.get('BccAddress')).length() - 3)));
                    //csvInfo.put('MessageDate', mapHeadersValues.get('MessageDate'));
                    csvInfo.put('MessageDate', String.valueOf(mapHeadersValues.get('MessageDate')).substring(0, (String.valueOf(mapHeadersValues.get('MessageDate')).length() - 3)));
                    //csvInfo.put('HtmlBody', mapHeadersValues.get('HtmlBody'));
                    csvInfo.put('HtmlBody', String.valueOf(mapHeadersValues.get('HtmlBody')).substring(0, (String.valueOf(mapHeadersValues.get('HtmlBody')).length() - 3)));               
                    
                    csvInfoList.add(csvInfo);
                    system.debug('csvInfo.put(IdOfCsv)=>'   +csvInfo.get('IdOfCsv'));
                    system.debug('csvInfo.put(ParentId)=>'   +csvInfo.get('ParentId'));
                    system.debug('csvInfo.put(HtmlBody)=>'   +csvInfo.get('HtmlBody'));
                }catch(exception e){
                    System.debug('Catch exception'+e.getMessage());
                }
                
            }
        }
        return csvInfoList;
        
    }
    
    @AuraEnabled
    public static Map<String, String> getEmailData(String emailMessageId){
        emailMessageId = emailMessageId.right(19).left(18);
        system.debug('message id '+emailMessageId);
        Case_Email__c caseEmail = [Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                                   LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate,
                                   LastReferencedDate, Case__c, Case_Email_Number__c, Case_Number__c, EmailMessage_Id__c, 
                                   Email_Message_SharePoint_Id__c, Email_Message_Created_Date__c, Case_Id__c, Email_Message_SP_Folder_Id__c
                                   from Case_Email__c where EmailMessage_Id__c =: emailMessageId limit 1];
        string sharepointid = caseEmail.Email_Message_SharePoint_Id__c;
        System.debug('string sharepointid='+sharepointid);
        //csvSPID.add(sharepointid);
        //System.debug('List<id> csvSPID='+csvSPID);            
        
        Map<String, String> csvInfo = new Map<String, String>();    
        try{
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
            
            //Map<String, String> csvInfo = new Map<String, String>();
            //csvInfo.put('IdOfCsv', mapHeadersValues.get('Id').subString(0,(MapHeadersValues.get('Id')-3));
            csvInfo.put('IdOfCsv', String.valueOf(mapHeadersValues.get('Id')).substring(0, (String.valueOf(mapHeadersValues.get('Id')).length() - 3)));
            // csvInfo.put('ParentId', mapHeadersValues.get('ParentId'));
            csvInfo.put('ParentId', String.valueOf(mapHeadersValues.get('ParentId')).substring(0, (String.valueOf(mapHeadersValues.get('ParentId')).length() - 3)));
            //csvInfo.put('CreatedDate', mapHeadersValues.get('CreatedDate'));
            csvInfo.put('CreatedDate', String.valueOf(mapHeadersValues.get('CreatedDate')).substring(0, (String.valueOf(mapHeadersValues.get('CreatedDate')).length() - 3)));
            //csvInfo.put('TextBody', mapHeadersValues.get('TextBody'));
            csvInfo.put('TextBody', String.valueOf(mapHeadersValues.get('TextBody')).substring(0, (String.valueOf(mapHeadersValues.get('TextBody')).length() - 3)));
            //csvInfo.put('Headers', mapHeadersValues.get('Headers'));
            csvInfo.put('Headers', String.valueOf(mapHeadersValues.get('Headers')).substring(0, (String.valueOf(mapHeadersValues.get('Headers')).length() - 3)));
            //csvInfo.put('Subject', mapHeadersValues.get('Subject'));
            csvInfo.put('Subject', String.valueOf(mapHeadersValues.get('Subject')).substring(0, (String.valueOf(mapHeadersValues.get('Subject')).length() - 3)));
            //csvInfo.put('FromAddress', mapHeadersValues.get('FromAddress'));
            csvInfo.put('FromAddress', String.valueOf(mapHeadersValues.get('FromAddress')).substring(0, (String.valueOf(mapHeadersValues.get('FromAddress')).length() - 3)));
            //csvInfo.put('ToAddress', mapHeadersValues.get('ToAddress'));
            csvInfo.put('ToAddress', String.valueOf(mapHeadersValues.get('ToAddress')).substring(0, (String.valueOf(mapHeadersValues.get('ToAddress')).length() - 3)));
            //csvInfo.put('CcAddress', mapHeadersValues.get('CcAddress'));
            csvInfo.put('CcAddress', String.valueOf(mapHeadersValues.get('CcAddress')).substring(0, (String.valueOf(mapHeadersValues.get('CcAddress')).length() - 3)));
            //csvInfo.put('BccAddress', mapHeadersValues.get('BccAddress'));
            csvInfo.put('BccAddress', String.valueOf(mapHeadersValues.get('BccAddress')).substring(0, (String.valueOf(mapHeadersValues.get('BccAddress')).length() - 3)));
            //csvInfo.put('MessageDate', mapHeadersValues.get('MessageDate'));
            csvInfo.put('MessageDate', String.valueOf(mapHeadersValues.get('MessageDate')).substring(0, (String.valueOf(mapHeadersValues.get('MessageDate')).length() - 3)));
            //csvInfo.put('HtmlBody', mapHeadersValues.get('HtmlBody'));
            csvInfo.put('HtmlBody', String.valueOf(mapHeadersValues.get('HtmlBody')).substring(0, (String.valueOf(mapHeadersValues.get('HtmlBody')).length() - 3)));
            csvInfo.put('FromName', String.valueOf(mapHeadersValues.get('FromName')).substring(0, (String.valueOf(mapHeadersValues.get('FromName')).length() - 3)));
            
            
            // csvInfoList.add(csvInfo);
            system.debug('csvInfo.put(IdOfCsv)=>'   +csvInfo.get('IdOfCsv'));
            system.debug('csvInfo.put(ParentId)=>'   +csvInfo.get('ParentId'));
            system.debug('csvInfo.put(HtmlBody)=>'   +csvInfo.get('HtmlBody'));
        }catch(exception e){
            System.debug('Catch exception'+e.getMessage());
        }
        
        system.debug('csv returned '+csvInfo);
        return csvInfo;
    }
}