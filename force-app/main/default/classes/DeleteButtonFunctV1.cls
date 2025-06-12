public class DeleteButtonFunctV1 {
    Public static void deleteSharepointId(String fileSharepointId){
        /*List<Case_Email__c> caseEmailList=[select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
                                           LastActivityDate, LastViewedDate, LastReferencedDate, Case__c, Case_Email_Number__c, Case_Number__c, EmailMessage_Id__c, 
                                           Email_Message_SharePoint_Id__c, Email_Message_Created_Date__c, Case_Id__c, Email_Message_Subject__c, EM_Sharepoint_Web_Url__c, 
                                           Email_Message_SP_Folder_Id__c, Files_SP_Id__c, Files_Share_Point_Id__c from Case_Email__c  where Files_Share_Point_Id__c =: fileSharepointIdsp limit 1];
        */
        //String fileSharepointId;
        try{
            	   //fileSharepointId=caseEmailList[0].Files_Share_Point_Id__c;
            	   //fileSharepointId='01SCG6PXPNIAXL3OCS5RALIQIBCLEKFFOD';
            //System.debug('Each files sharepointID==> ' +fileSharepointId);
            String driveId = 'b!3RPB15XxtkSn_wJ9OGDxDwymYO9ecrFLrZXuL7fJXMpOcHHo4EI6TZMW56RJH70a';
            string siteId='d7c113dd-f195-44b6-a7ff-027d3860f10f';

            
            Http httpCallout = new Http();
            HttpRequest req = new HttpRequest();
            
            
            req.setEndpoint('callout:Sharepoint/v1.0/sites/' + siteId + '/drives/' + driveId + '/items/' + fileSharepointId); 
            
            req.setMethod('DELETE');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            //req.setBodyAsBlob(fileBody);
            
            HTTPResponse res = httpCallout.send(req);
            System.debug('HTTPResponse respomse status code==> '+res.getStatusCode());
            if(res.getStatusCode() == 204){
                System.debug('File is deleted');
            }else{
                System.debug('There is a problem in calss.');
            }           
            
        }catch(Exception e){
                System.debug('Catch Exception==> '+e.getMessage());
            }
        
    }
    
}