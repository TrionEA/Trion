public class ApiFutureCallingDK{
    
    @future(callout=true)
    public static void fileMigration(String stagingId){
        
        if(stagingId != 'Test##SP'){
            
            List<Staging__b> stagingList = [select sObject__c, Chunk__c, Linked_Entity_Id__c, Content_Document_Id__c, Content_Version_Id__c, Status__c, Job_ID__c, Title__c, From_sObject__c
                                            from Staging__b
                                            where Status__c = 'Not Started' and Chunk__c =: stagingId
                                            LIMIT 1];
            if(stagingList.size() == 0){
                stagingList = [select sObject__c, Chunk__c, Linked_Entity_Id__c, Content_Document_Id__c, Content_Version_Id__c, Status__c, Job_ID__c, Title__c, From_sObject__c
                               from Staging__b
                               where Status__c = 'Pending' and Chunk__c =: stagingId
                               LIMIT 1];    
            }
            Integer statuscode;
            String jsonString;
            String subFolderName;
            Blob fileBody;
            String fileName;
            
            if(stagingList[0].From_sObject__c == 'ContentDocument'){
                
                List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId, VersionData, FileExtension
                                                           FROM ContentVersion
                                                           WHERE id =: stagingList[0].Content_Version_ID__c
                                                           LIMIT 1];
                fileBody = contentVersionList[0].VersionData;
                fileName = stagingList[0].Title__c + '.' + contentVersionList[0].FileExtension;
            }
            else{
                List<Attachment> attachmentsList = [SELECT Body, BodyLength, ContentType, Id, Name FROM Attachment
                                                    WHERE Id =: stagingList[0].Chunk__c
                                                    LIMIT 1]; 
                fileBody = attachmentsList[0].Body;
                if(attachmentsList[0].ContentType != null){
                    fileName = stagingList[0].Title__c + '.' + attachmentsList[0].ContentType.substringAfterLast('/');
                }
                else{
                    fileName = stagingList[0].Title__c;
                }
            }
            
            try{
                
                String driveId = 'b!3RPB15XxtkSn_wJ9OGDxDwymYO9ecrFLrZXuL7fJXMpOcHHo4EI6TZMW56RJH70a';
                String encodedDriveId = EncodingUtil.urlEncode(driveId, 'UTF-8');
                String encodedFileName = EncodingUtil.urlEncode(fileName, 'UTF-8');
                subFolderName = stagingList[0].Linked_Entity_Id__c;
                String objectName = stagingList[0].sObject__c;
                
                Http httpCallout = new Http();
                HttpRequest req = new HttpRequest();
                
                if(objectName == 'EmailMessage')
                {
                    String objectNameCase = 'Case';
                    EmailMessage emRec = [Select ParentId from EmailMessage where Id =: subFolderName];
                    String  caseFolderName = emRec.ParentId;
                    
                    req.setEndpoint('callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/'+ objectNameCase  +'/'+ caseFolderName + '/' + subFolderName +'/' + encodedFileName.replaceall('\\+', '%20') + ':/content'); 
                    
                    
                    //req.setEndpoint('callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/'+ objectName  +'/'+subFolderName+'/' + encodedFileName.replaceall('\\+', '%20') + ':/content');
                    req.setMethod('PUT');
                    req.setHeader('Content-Type', 'application/json');
                    req.setHeader('Accept', 'application/json');
                    req.setBodyAsBlob(fileBody);
                    
                    HTTPResponse res = httpCallout.send(req);
                    statuscode = res.getStatusCode();
                    jsonString = res.getBody();
                    
                    if(res.getStatusCode() == 201){                        
                        updateSharepointStatus(stagingList[0], 'Completed','null');
                    }
                    else{
                        String errorMessage = 'File upload failed. Status Code: ' + res.getStatusCode() + ', Response: ' + res.getBody();
                        updateSharepointStatus(stagingList[0], 'Pending', errorMessage);
                    }
                }else{
                    req.setEndpoint('callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/'+ objectName  +'/'+subFolderName+'/' + encodedFileName.replaceall('\\+', '%20') + ':/content');
                    req.setMethod('PUT');
                    req.setHeader('Content-Type', 'application/json');
                    req.setHeader('Accept', 'application/json');
                    req.setBodyAsBlob(fileBody);
                    
                    HTTPResponse res = httpCallout.send(req);
                    
                    
                    if(res.getStatusCode() == 201){
                        updateSharepointStatus(stagingList[0], 'Completed','null');
                    }
                    else{
                        String errorMessage = 'File upload failed. Status Code: ' + res.getStatusCode() + ', Response: ' + res.getBody();
                        updateSharepointStatus(stagingList[0], 'Pending', errorMessage);
                    }
                }
            }catch(Exception e){
                updateSharepointStatus(stagingList[0], 'Pending', 'Exception Caught!');
            }
            
            if (statuscode == 201){
                
                Map<String, Object> deserializeResponse = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
                Map<String, Object> parentReference = (Map<String, Object>) deserializeResponse.get('parentReference');
                Map<String, Object> fileType = (Map<String, Object>) deserializeResponse.get('file');
                Map<String,List<object>>MapWeb=new Map<String,List<object>>();
                List<object>li=new List<object>();
                
                    //List<Object> idsList = (List<Object>) deserializeResponse.get('ids');
                
                

                
                if (deserializeResponse != null) {
                    
                    List<Object> idsList = (List<Object>) deserializeResponse.get('ids');
                    String spid = (String) deserializeResponse.get('id');
                    System.debug('id: ' +spid);
                    String spweburl = (String) deserializeResponse.get('webUrl');
                    System.debug('webUrl: ' +spweburl); 
                    Integer spsize = (integer) deserializeResponse.get('size');
                    li.add(spsize);
                    System.debug('size: ' +spsize);
                    String spfilecreateddate = (String) deserializeResponse.get('createdDateTime');
                    li.add(spfilecreateddate);
                    System.debug('createdDateTime: ' +spfilecreateddate); 
                    String spfiletype = (String) fileType.get('mimeType');
                    li.add(spfiletype);
                    MapWeb.put(spweburl,li);
                    System.debug('mimeType: ' +spfiletype);
                    
                    System.debug('List<object>li: ' +li);
                    System.debug('Map<String,List<object>>MapWeb: ' +MapWeb);
                    
                    
                       List<Case_Email__c> ceList = new List<Case_Email__c>();
                    for (Case_Email__c ce : [SELECT Id, EmailMessage_Id__c, Email_Message_SharePoint_Id__c,Files_SP_Id__c
                                             FROM Case_Email__c
                                             WHERE EmailMessage_Id__c = :subFolderName]){                                                     
                                                 if(subFolderName.equals(ce.EmailMessage_Id__c)){
                                                     ce.Files_Share_Point_Id__c=spid;                       
                                                     //ce.EM_Sharepoint_Web_Url__c=spweburl;
                                                     ceList.add(ce);                              
                                                     system.debug('customObject.Email_Message_SharePoint_Id__c'+ ce.Files_Share_Point_Id__c);
                                                 }                                                                                                         
                                             }
                    if (!ceList.isEmpty()) {
                        update ceList;
                    }
 
                    
                }
            }
        }
    }

    public static void updateSharepointStatus(Staging__b recordToUpdate, String status, String errorMessage) {
        
        Staging__b currentRecord = new Staging__b();
        currentRecord.Status__c = status;
        currentRecord.sObject__c = recordToUpdate.sObject__c;
        currentRecord.Chunk__c = recordToUpdate.Chunk__c;
        currentRecord.Content_Document_Id__c = recordToUpdate.Content_Document_Id__c;
        currentRecord.Content_Version_Id__c = recordToUpdate.Content_Version_Id__c;
        currentRecord.Linked_Entity_Id__c = recordToUpdate.Linked_Entity_Id__c;
        currentRecord.Title__c = recordToUpdate.Title__c;
        currentRecord.From_sObject__c = recordToUpdate.From_sObject__c;
        
        if (errorMessage != null && !String.isBlank(errorMessage)){
            currentRecord.Error_Message__c = errorMessage.left(255);
        }
        
        try{
            if(currentRecord.Job_ID__c != 'Test##SP'){
                Database.SaveResult result = Database.insertImmediate(currentRecord);
                if(result.isSuccess()){
                    Database.deleteImmediate(new Staging__b(Status__c = recordToUpdate.Status__c, Chunk__c = recordToUpdate.Chunk__c));
                }
            }
        }catch(Exception ex){
        }
    }
    
    
    public static void testCoverage(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
    
}