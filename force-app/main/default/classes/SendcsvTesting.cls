public class SendcsvTesting{
    
    // @future(callout=true)
    public static void fileMigration() {
        List<EmailMessage_Html__b> emailStagingList = [SELECT Title__c, Status__c, sObject__c, Is_Large_File__c, File_Size__c, Error_Message__c, Emailmessage_Id__c, File_Body__c
                                                       FROM EmailMessage_Html__b
                                                       WHERE Status__c = 'Not Started' AND Emailmessage_Id__c in ('02sVE000000GrmjYAC','02sVE000000FhuIYAS','02sVE000000Fin7YAC')];
        system.debug('emailStagingList' + emailStagingList);
        //   Blob fileBody;
        //   String fileName='';
        //   String csvId='';
        //   String emailMessagebody='';
        //   String objectName='';
        //   integer listSize=emailStagingList.size();
        
        for (EmailMessage_Html__b emhbl : emailStagingList) {
            try {   
                
                String fileName = emhbl.Title__c;
                system.debug('fileName: ' + fileName);
                String  csvId = emhbl.Title__c.substring(20, 38);
                system.debug('String csvId: ' + csvId);
                String emailMessagebody = emhbl.File_Body__c;
                blob fileBody = Blob.valueOf(emailMessagebody);  
                String  objectName = emhbl.sObject__c;
                
                String driveId = 'b!3RPB15XxtkSn_wJ9OGDxDwymYO9ecrFLrZXuL7fJXMojFk7xuwxkTanxrnqT1Fs6';
                String encodedDriveId = EncodingUtil.urlEncode(driveId, 'UTF-8');
                String encodedFileName = emailStagingList[0].Title__c;
                String encodedObjectName = 'EmailMessage';   //EncodingUtil.urlEncode(objectName, 'UTF-8');
                
                String endpoint = 'callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/' + encodedObjectName + '/' + encodedFileName.replaceAll('\\+', '%20') + ':/content';
                
                Http httpCallout = new Http();
                HttpRequest req = new HttpRequest();
                
                req.setEndpoint(endpoint);
                req.setMethod('PUT');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Accept', 'application/json');
                
                req.setBodyAsBlob(fileBody);
                
                HTTPResponse res = httpCallout.send(req);
                
                System.debug('>>> Response Headers: ' + res.getHeaderKeys());
                System.debug('>>> Content-Type Header: ' + res.getHeader('Content-Type'));
                System.debug('>>> Full Response: ' + res.getBody());
                System.debug('>>> Status Code: ' + res.getStatusCode());
                
                if (res.getStatusCode() == 201) {
                    String jsonString = res.getBody();
                    Map<String, Object> deserializeResponse = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
                    
                    if (deserializeResponse != null) {
                        String spid = (String) deserializeResponse.get('id');
                        System.debug('id: ' + spid);
                        
                        List<Case_Email__c> ceList = new List<Case_Email__c>();
                        for (Case_Email__c ce : [SELECT Id, EmailMessage_Id__c, Email_Message_SharePoint_Id__c
                                                 FROM Case_Email__c
                                                 WHERE EmailMessage_Id__c = :csvId]) {
                                                     if(csvId.equals(ce.EmailMessage_Id__c)){
                                                         ce.Email_Message_SharePoint_Id__c=spid;                       
                                                         
                                                         ceList.add(ce);                              
                                                         system.debug('customObject.Email_Message_SharePoint_Id__c'+ce.Email_Message_SharePoint_Id__c);
                                                     }
                                                 }
                        
                        if (!ceList.isEmpty()) {
                            update ceList;
                        }
                        
                    }
                }
            } catch (Exception e) {
                System.debug(e.getMessage());    
                    }
        }
    }
}