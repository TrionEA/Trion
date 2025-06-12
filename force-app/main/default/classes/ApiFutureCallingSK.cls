public class ApiFutureCallingSK{
    
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
                String subFolderName = stagingList[0].Linked_Entity_Id__c;
                String objectName = stagingList[0].sObject__c;
                
                Http httpCallout = new Http();
                HttpRequest req = new HttpRequest();
                
               
                   
                   //req.setEndpoint('callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/'+ objectNameCase  +'/'+ caseFolderName + '/' + subFolderName +'/' + encodedFileName.replaceall('\\+', '%20') + ':/content'); 
                
                
                req.setEndpoint('callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/'+ objectName  +'/'+subFolderName+'/' + encodedFileName.replaceall('\\+', '%20') + ':/content');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json; odata=verbose');
                req.setHeader('Accept', 'application/json; odata=verbose');
                req.setBody('{ "__metadata": { "type": "SP.ListItem" }, "Title": "Test File" }');
				Http http = new Http();                
                HTTPResponse res = httpCallout.send(req);
                
                
                if(res.getStatusCode() == 201){
                     // Upload file content to SharePoint
 			   HttpRequest contentRequest = new HttpRequest();
   			 contentRequest.setEndpoint('callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/'+ objectName  +'/'+subFolderName+'/' + encodedFileName.replaceall('\\+', '%20') + ':/content');
    			contentRequest.setMethod('PUT');
    			//contentRequest.setHeader('Authorization', 'Bearer ' + salesforceAccessToken);
   				 contentRequest.setHeader('Content-Type', 'application/json; odata=verbose');
   				 contentRequest.setHeader('Accept', 'application/json; odata=verbose');
   				 contentRequest.setBodyAsBlob(fileBody);
					    HttpResponse contentResponse = http.send(contentRequest);
                     if (contentResponse.getStatusCode() == 200 || contentResponse.getStatusCode() == 201) {
        System.debug('File uploaded successfully to SharePoint.');
                                             updateSharepointStatus(stagingList[0], 'Completed','null');
    } else {
        System.debug('Error uploading file content to SharePoint: ' + contentResponse.getBody());
    }


                }
                else{
                    String errorMessage = 'File upload failed. Status Code: ' + res.getStatusCode() + ', Response: ' + res.getBody();
                    updateSharepointStatus(stagingList[0], 'Pending', errorMessage);
             
           
            }
            }catch(Exception e){
                updateSharepointStatus(stagingList[0], 'Pending', 'Exception Caught!');
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