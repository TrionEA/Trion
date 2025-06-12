public class RealTimeContentDocumentUpload{
/*
public class RealTimeContentDocumentUpload implements Queueable, Database.AllowsCallouts{
    
    Public List<ContentDocumentLink> cdLinkList;
    
    public RealTimeContentDocumentUpload(List<ContentDocumentLink> cdLinkList) {
        this.cdLinkList= cdLinkList;
    }
    
    public void execute(QueueableContext context) {
        RealTimeContentDocumentUpload.immediatePushSharepoint(cdLinkList);
    }
    Public static void immediatePushSharepoint(List<ContentDocumentLink> cdLinkList){
        List<ContentDocument> cd=[select  Id, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, IsArchived, 
                                  ArchivedById, ArchivedDate, IsDeleted, OwnerId, SystemModstamp, Title, PublishStatus, 
                                  LatestPublishedVersionId, ParentId, LastViewedDate, LastReferencedDate, Description, 
                                  ContentSize, FileType, FileExtension, SharingOption, SharingPrivacy, ContentModifiedDate, 
                                  ContentAssetId from ContentDocument limit 1];       
        
        String contentDocumentId= cd[0].id;
        String contentDocumentIdfromContentdocumentlink;
       
        List<ContentDocumentLink> contentDocumentLinkList=[select Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility 
                                                           from ContentDocumentLink where ContentDocumentId =: contentDocumentId]; 
        for(ContentDocumentLink cdl:cdLinkList){
            contentDocumentIdfromContentdocumentlink=cdl.id;
            
            List<ContentVersion> contentVersionList=[select Id, ContentDocumentId, IsLatest, ContentUrl, ContentBodyId, VersionNumber, Title, Description, 
                               						 ReasonForChange, SharingOption, SharingPrivacy, PathOnClient, RatingCount, IsDeleted, ContentModifiedDate, 
                               						 ContentModifiedById, PositiveRatingCount, NegativeRatingCount, FeaturedContentBoost, FeaturedContentDate, 
                                					 OwnerId, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, SystemModstamp, TagCsv, FileType, 
                               						 PublishStatus, VersionData, ContentSize, FileExtension, FirstPublishLocationId, Origin, ContentLocation, 
                               						 TextPreview, ExternalDocumentInfo1, ExternalDocumentInfo2, ExternalDataSourceId, Checksum, IsMajorVersion, 
                               						 IsAssetEnabled, VersionDataUrl, LEXMAGICMOVER__LegacyNoteConvertedDate__c, LEXMAGICMOVER__LegacyNoteConvertedId__c, 
                               						 LEXMAGICMOVER__LegacyNoteConvertedLastModifiedDate__c, LEXMAGICMOVER__LegacyNoteConvertedOwnerId__c, 
                               						 LEXMAGICMOVER__LegacyNoteConvertedParentId__c, LEXMAGICMOVER__LegacyNoteConvertedLastModifiedDateTime__c 
                               						 from ContentVersion WHERE ContentDocumentId = :contentDocumentId ORDER BY CreatedDate DESC LIMIT 1 ];
            
            Blob fileBody;
            String fileName;
            fileBody = contentVersionList[0].VersionData;
            fileName = contentVersionList[0].Title + '.' + contentVersionList[0].FileExtension;
            try{
                
                String driveId = 'b!3RPB15XxtkSn_wJ9OGDxDwymYO9ecrFLrZXuL7fJXMpOcHHo4EI6TZMW56RJH70a';
                String encodedDriveId = EncodingUtil.urlEncode(driveId, 'UTF-8');
                String encodedFileName = EncodingUtil.urlEncode(fileName, 'UTF-8');
                
                String objectNameCase = 'Case';
                String caseFolderName='EmailMessage'; 
                String subFolderName='EmailMessageId';
                Http httpCallout = new Http();
                HttpRequest req = new HttpRequest();
                
                //req.setEndpoint('callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/'+ objectNameCase  +'/'+ caseFolderName + '/' + subFolderName +'/' + encodedFileName.replaceall('\\+', '%20') + ':/content');              
                //req.setEndpoint('callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/'+ objectName  +'/'+subFolderName+'/' + encodedFileName.replaceall('\\+', '%20') + ':/content');
                req.setEndpoint('callout:Sharepoint/v1.0/sites/d7c113dd-f195-44b6-a7ff-027d3860f10f/drives/b!3RPB15XxtkSn_wJ9OGDxDwymYO9ecrFLrZXuL7fJXMpOcHHo4EI6TZMW56RJH70a/root:/'+objectNameCase+'/'+caseFolderName+'/'+fileName+':/content');


                req.setMethod('PUT');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Accept', 'application/json');
                req.setBodyAsBlob(fileBody);
                
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
   */ 
}