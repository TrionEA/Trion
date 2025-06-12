public class RealTimeFileUploadV1 {
    Public static void immediatePushSharepoint(List<Attachment> attList){
        blob attachmentbody;
        String attachmentname;
        String attachmentId;
        for(Attachment att:attList){
            attachmentId=att.id;
            attachmentbody=att.Body;
            attachmentname=att.Name;
           
        }
        try{
                
                String driveId = 'b!3RPB15XxtkSn_wJ9OGDxDwymYO9ecrFLrZXuL7fJXMpOcHHo4EI6TZMW56RJH70a';
                String encodedDriveId = EncodingUtil.urlEncode(driveId, 'UTF-8');
                String encodedFileName = EncodingUtil.urlEncode(attachmentname, 'UTF-8');
                
                String objectNameCase = 'Case';
                String caseFolderName='Submission_Requirement__c'; 
                String subFolderName='EmailMessageId';
                Http httpCallout = new Http();
                HttpRequest req = new HttpRequest();
                
                //req.setEndpoint('callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/'+ objectNameCase  +'/'+ caseFolderName + '/' + subFolderName +'/' + encodedFileName.replaceall('\\+', '%20') + ':/content');              
                //req.setEndpoint('callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/'+ objectName  +'/'+subFolderName+'/' + encodedFileName.replaceall('\\+', '%20') + ':/content');
                req.setEndpoint('callout:Sharepoint/v1.0/sites/d7c113dd-f195-44b6-a7ff-027d3860f10f/drives/b!3RPB15XxtkSn_wJ9OGDxDwymYO9ecrFLrZXuL7fJXMpOcHHo4EI6TZMW56RJH70a/root:/'+objectNameCase+'/'+caseFolderName+'/'+encodedFileName.replaceall('\\+', '%20')+':/content');

                req.setMethod('PUT');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Accept', 'application/json');
                req.setBodyAsBlob(attachmentbody);
                
                HTTPResponse res = httpCallout.send(req);
                
                 if(res.getStatusCode() == 201){
                        System.debug('Successfully Uploaded to Sharepoint.');
                    }
                    else{
                        String errorMessage = 'File upload failed. Status Code: ' + res.getStatusCode() + ', Response: ' + res.getBody();
                        System.debug('Not Uploaded to sharepoint. Error is---> '+errorMessage);                        
                    }
                
                
                
            }catch(Exception e){
                System.debug('Catch Exception==>'+e.getmessage());
            }
        
    }   
			
}