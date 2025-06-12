public class SendcsvTest2{
    
    @future(callout=true)
    public static void fileMigration(String stagingId) {
        if (stagingId != 'Test##SP') {  
            List<EmailMessage_Html__b> emailStagingList = [SELECT Title__c, Status__c, sObject__c, Is_Large_File__c, File_Size__c, 
                                                           Error_Message__c, Emailmessage_Id__c,Parent_Case_Id__c,File_Body__c
                                                           FROM EmailMessage_Html__b
                                                           WHERE Status__c = 'Not Started' AND Emailmessage_Id__c=:stagingId
                                                           LIMIT 1];
            system.debug('emailStagingList' + emailStagingList);
            
            if (emailStagingList.isEmpty()) {
                emailStagingList = [SELECT Title__c, Status__c, sObject__c, Is_Large_File__c, File_Size__c, 
                                    Error_Message__c, Emailmessage_Id__c,Parent_Case_Id__c,File_Body__c
                                    FROM EmailMessage_Html__b
                                    WHERE Status__c = 'Pending' AND Emailmessage_Id__c=:stagingId
                                    LIMIT 1]; 
                
            }
            
            Blob fileBody;
            String fileName='';
            String csvId='';
            String emailMessagebody='';
            String objectName='';
            string parentCaseId='';
            integer listSize=emailStagingList.size();
            
            
            for (EmailMessage_Html__b emhbl : emailStagingList) {
                if(listSize > 0){
                    
                    fileName = emailStagingList[0].Title__c;
                    system.debug('fileName: ' +fileName);
                    csvId = fileName.substring(20, 38);
                    system.debug('String csvId: ' +csvId);
                    emailMessagebody = emailStagingList[0].File_Body__c;
                    fileBody = Blob.valueOf(emailMessagebody);  
                    objectName = emailStagingList[0].sObject__c;
                    parentCaseId=emailStagingList[0].Parent_Case_Id__c;
                    system.debug('String parentCaseId: ' +parentCaseId);
                }
            }
            
            
            
            try {
                String driveId = 'b!3RPB15XxtkSn_wJ9OGDxDwymYO9ecrFLrZXuL7fJXMpOcHHo4EI6TZMW56RJH70a';
                String encodedDriveId = EncodingUtil.urlEncode(driveId, 'UTF-8');
                String encodedFileName = emailStagingList[0].Title__c;
                String encodedObjectName = emailStagingList[0].Emailmessage_Id__c;
                String encodedParentCaseId = emailStagingList[0].Parent_Case_Id__c;
                String endpoint = 'callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/' + 'Case/' + encodedParentCaseId + '/' + encodedObjectName + '/' + encodedFileName.replaceAll('\\+', '%20') + ':/content';
                
                
                Http httpCallout = new Http();
                HttpRequest req = new HttpRequest();
                
                req.setEndpoint(endpoint);
                req.setMethod('PUT');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Accept', 'application/json');
                
                req.setBodyAsBlob(fileBody);
                system.debug('fileBody--->' + fileBody);
                HTTPResponse res = httpCallout.send(req);
                List<Case_Email__c> caseEmailList=new List<Case_Email__c>();
                
                //Get web Url
                
                if (res.getStatusCode() == 201){
                    String jsonString = res.getBody();
                    Map<String, Object> deserializeResponse = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
                    //Map<String, List<Map<String, Object>>> deserializeResponse2 = (Map<String, List<Map<String, Object>>>) JSON.deserializeUntyped(jsonString);
                    Map<String, Object> parentReference = (Map<String, Object>) deserializeResponse.get('parentReference');

                    if (deserializeResponse != null && parentReference != null) {
                        String spid = (String) deserializeResponse.get('id');
                        System.debug('id: ' +spid);
                        String spweburl = (String) deserializeResponse.get('webUrl');
                        System.debug('webUrl: ' +spweburl);                        
                        String spFolName = (String) parentReference.get('name');
                        System.debug('webUrl: ' +spFolName);
                        List<Case_Email__c> ceList = new List<Case_Email__c>();
                  /*      for (Case_Email__c ce : [SELECT Id, EmailMessage_Id__c, Email_Message_SharePoint_Id__c,Email_Message_SP_Folder_Id__c,Files_SP_Id__c
                                                 FROM Case_Email__c
                                                 WHERE EmailMessage_Id__c = :csvId]) {
                                                     if(csvId.equals(ce.EmailMessage_Id__c)){
                                                         ce.Email_Message_SharePoint_Id__c=spid;                       
                                                         ce.EM_Sharepoint_Web_Url__c=spweburl;
                                                         ceList.add(ce);                              
                                                         system.debug('customObject.Email_Message_SharePoint_Id__c'+ce.Email_Message_SharePoint_Id__c);
                                                     }
                                                 }                        
                        if (!ceList.isEmpty()) {
                            update ceList;
                        } 
*/
                    }  
                    //}
                    
                    //if(res.getStatusCode() == 201){    
                    updateSharepointStatus(emailStagingList[0], 'Completed', 'null');
                    System.debug('res.getStatusCode()=>' + res.getStatusCode());
                } else{
                    String errorMessage = 'File upload failed. Status Code: ' + res.getStatusCode() + ', Response: ' + res.getBody();
                    updateSharepointStatus(emailStagingList[0], 'Pending', errorMessage);
                    System.debug('res.getStatusCode()=>' + res.getStatusCode());
                }
            }
            catch(Exception e){
                updateSharepointStatus(emailStagingList[0], ' ', 'Exception Caught!');
                System.debug('Catch Exception=>' + e.getMessage());
            }
            //} else {
            // Handle the case where emailStagingList is empty
            //}
            //}
        }
    }
    public static void updateSharepointStatus(EmailMessage_Html__b recordToUpdate, String status, String errorMessage) {
        EmailMessage_Html__b currentRecord = new EmailMessage_Html__b();
        currentRecord.Status__c = status;
        currentRecord.EmailMessage_Id__c=recordToUpdate.EmailMessage_Id__c;
        currentRecord.sObject__c = recordToUpdate.sObject__c;
        currentRecord.File_Size__c = recordToUpdate.File_Size__c;
        currentRecord.Title__c = recordToUpdate.Title__c;
        currentRecord.Parent_Case_Id__c=recordToUpdate.Parent_Case_Id__c;
        if (errorMessage != null && !String.isBlank(errorMessage)) {
            currentRecord.Error_Message__c = errorMessage.left(255);
        }
       try{
            if(currentRecord.Job_ID__c != 'Test##SP'){
                Database.SaveResult result = Database.insertImmediate(currentRecord);
                system.debug(result);
                if(result.isSuccess()){
                    Database.deleteImmediate(new EmailMessage_Html__b(Status__c = recordToUpdate.Status__c, EmailMessage_Id__c = recordToUpdate.EmailMessage_Id__c, sObject__c=recordToUpdate.sObject__c));
                }
            }
        }catch(Exception ex){
        }  
    }
}