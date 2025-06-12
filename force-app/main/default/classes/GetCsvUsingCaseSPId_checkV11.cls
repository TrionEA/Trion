public class GetCsvUsingCaseSPId_checkV11 {
    
    public static void getSharepointId(String caseParentId){
        List<String> sharepointEmailIdList = getEmailMessageSharePointIds(caseParentId);
        
        
        System.debug('FetchEmailMessagesQueueable(sharepointEmailIdList===> '+sharepointEmailIdList);   
        System.debug('FetchEmailMessagesQueueable(caseParentId===> '+caseParentId);   
        
        
    }
    
    private static List<String> getEmailMessageSharePointIds(String caseParentId) {
        List<String> emailIdFromSp = new List<String>();
        List<Case> caseList = [Select id from case where id = :caseParentId limit 1];
        String caseFolderName = caseList[0].id;
        String objectNameCase2 = GetFolderUsingCustomMetadata.getData(caseFolderName); 
        String driveId = Label.SharepointDriveId;
        
        Http httpCallout = new Http();
        HttpRequest req1 = new HttpRequest();
        req1.setMethod('GET');
        req1.setHeader('Content-Type', 'application/json');
        req1.setHeader('Accept', 'application/json');
        req1.setTimeout(120000);
        req1.setEndpoint('callout:Sharepoint/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId+'/items/root:/'+ objectNameCase2  +'/'+ caseFolderName + ':/children');             
        
        HTTPResponse res1 = httpCallout.send(req1);
        
        if (res1.getStatusCode() == 200) {
            if (res1.getBody() != null) {
                String jsonString = res1.getBody();
                Response result = (Response) JSON.deserialize(jsonString, Response.class);
                for (Item eachItem : result.value) {
                    emailIdFromSp.add(eachItem.name);
                }
            }
        }
        List<Map<String, String>> csvInfoList = GetCsvUsingCaseSPId_checkV11.fetchEmailMessages(emailIdFromSp, caseParentId);
        //List<Map<String, String>> csvInfoList = EmailCsvBatchProcessor_V2.triggerProcessSharepointEmailIds(emailIdFromSp, caseParentId);
        System.debug('getEmailMessageSharePointIds return emailIdFromSp;===> ' + emailIdFromSp);
        System.debug('getEmailMessageSharePointIds return emailIdFromSp; SIZE===> ' + emailIdFromSp.size());
        System.debug('getEmailMessageSharePointIds csvInfoList===> ' + csvInfoList);
        System.debug('getEmailMessageSharePointIds csvInfoList===> SIZE' + csvInfoList.size());
        return emailIdFromSp;
    }
    
    private static List<Map<String, String>> fetchEmailMessages(List<String> emailIdFromSp, String caseParentId) {
        List<Map<String, String>> spInfoList = new List<Map<String, String>>();
        List<Map<String, String>> csvInfoList = new List<Map<String, String>>();
        List<String> sharepointEmailIdList= new List<String>();
        String fileid;
        String sharepointid;
        try {
            Case caseRecord = getCaseRecordbyId(caseParentId);
            String caseFolderName = caseRecord.Id;
            String objectNameCase2 = GetFolderUsingCustomMetadata.getData(caseFolderName);
            
            for (String eachEmailMessageIdFromSp : emailIdFromSp) {
                String driveId = Label.SharepointDriveId;
                
                Http httpCallout2 = new Http();
                HttpRequest req2 = new HttpRequest();
                req2.setMethod('GET');
                req2.setHeader('Content-Type', 'application/json');
                req2.setHeader('Accept', 'application/json');
                req2.setTimeout(120000);
                req2.setEndpoint('callout:Sharepoint/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/' + driveId + '/items/root:/' + objectNameCase2 + '/' + caseFolderName + '/' + eachEmailMessageIdFromSp + ':/children');
                
                HTTPResponse res2 = httpCallout2.send(req2);
                
                if (res2.getStatusCode() == 200) {
                    if (res2.getBody() != null) {
                        String jsonString2 = res2.getBody();
                        Response result2 = (Response) JSON.deserialize(jsonString2, Response.class);
                        
                        for (Item eachItem2 : result2.value) {
                            if (eachItem2.name.contains('EmailMessageDetails')) {
                                Map<String, String> spInfo = new Map<String, String>();
                                spInfo.put('fileid', eachItem2.id);
                                spInfo.put('fileName', eachItem2.name);
                                spInfo.put('fileSize', eachItem2.size);
                                spInfo.put('fileType', eachItem2.File.mimeType);
                                spInfo.put('fileCreatedDateTime', eachItem2.createdDateTime);
                                spInfo.put('fileSPWebUrl', eachItem2.webUrl);
                                spInfo.put('fileSPEtag', eachItem2.eTag.substring(2, eachItem2.eTag.length() - 4));
                                
                                spInfoList.add(spInfo);
                                fileid = spInfo.get('fileid');
                                sharepointEmailIdList.add(fileid);
                                System.debug('sharepointid ===>'+sharepointEmailIdList);  
                                System.debug('sharepointid size ===>'+sharepointEmailIdList.size());    
                            }
                        }
                    }
                }
            }
            //sharepointEmailIdList.add(fileid)
            //System.debug('sharepointid ===>'+sharepointEmailIdList.size());  
            //csvInfoList = EmailCsvBatchProcessor_V1.triggerProcessSharepointEmailIds(sharepointEmailIdList);
            //csvInfoList = EmailCsvBatchProcessor_V3.triggerProcessSharepointEmailIds(sharepointEmailIdList);
            //csvInfoList = system.enquejob(EmailCsvProcessor.EmailCsvProcessor(sharepointEmailIdList));
            
            //============Platform Events===========
            Integer chunkDataSize = 50;
            Integer totalRecords = sharepointEmailIdList.size();
            List<String> chunkDataList = new List<String>();
            List<GetDataFromSharepoint__e> eventList = new List<GetDataFromSharepoint__e>();
            
            for (Integer initialval = 0; initialval < totalRecords; initialval += chunkDataSize) {
                System.debug('Integer initialval----> ' + initialval);
                Integer finalval = Math.min(initialval + chunkDataSize, totalRecords);
                System.debug('Integer finalval----> ' + finalval);
                
                
                for (Integer i = initialval; i < finalval; i++) {
                    chunkDataList.add(sharepointEmailIdList[i]);                   
                }    
            }
            
            for (String spIdList : chunkDataList) {
                GetDataFromSharepoint__e event = new GetDataFromSharepoint__e();
                event.Emailid__c = String.valueOf(spIdList);
                eventList.add(event);
                System.debug('event.Emailid__c ==>' + event.Emailid__c);
                System.debug('event.Emailid__c length ==>' + event.Emailid__c.length());
                System.debug('EventUuid: ' + event.EventUuid);                    
            }   
            
            List<Id> successIds = new List<Id>();            
            if (!chunkDataList.isEmpty()) {
                List<Database.SaveResult> result = EventBus.publish(eventList);
                System.debug('Database.SaveResult results==>' + result); 
                for (Database.SaveResult resultnew : result) {
                    if (resultnew.isSuccess()) {
                        successIds.add(resultnew.getId());
                        System.debug('List<Id> successIds==>' + successIds);
                        System.debug('List<Id> successIds SIZE==>' + successIds.size());
                        System.debug('successIds.add(resultnew.getId())==>' + resultnew.getId());
                    } else {
                        for (Database.Error error : resultnew.getErrors()) {
                            System.debug('Error message: ' + error.getMessage());
                            System.debug('Status code: ' + error.getStatusCode());
                        }
                    }
                }
            }
            
        } catch (Exception e) {
            System.debug('Error processing email messages: ' + e.getMessage());
        }
        System.debug('csvInfoList ===>'+csvInfoList);  
        System.debug('csvInfoList size ===>'+csvInfoList.size());  
        return csvInfoList;
    }
    
    @AuraEnabled
    public static Case getCaseRecordbyId(String caseId) {
        Case caseRecord;
        try {
            caseRecord = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseId LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving case record: ' + e.getMessage());
        }      
        return caseRecord;
    }
    
    public static String getUserNameRecordbyId(String userId){
        return (String)[Select Id, Name from User where id = :userId limit 1].Name;
    }
    
    
    public class EmailMessageInfoUtil {
        public List<Map<String, String>> csvInfoList = new List<Map<String, String>>();
    }
    
    
    public class Item {
        public String createdDateTime;
        public String eTag;
        public String id;
        public String lastModifiedDateTime;
        public String name;
        public String webUrl;
        public String cTag;
        public String size;
        public Decorator decorator;
        public CreatedBy createdBy;
        public LastModifiedBy lastModifiedBy;
        public ParentReference parentReference;
        public FileSystemInfo fileSystemInfo;
        public Folder folder;
        public Shared shared;
        public File File;
    }
    
    public class Decorator {
        public String iconColor;
    }
    
    public class CreatedBy {
        public User user;
    }
    
    public class LastModifiedBy {
        public User user;
    }
    
    public class User {
        public String email;
        public String id;
        public String displayName;
    }
    
    public class ParentReference {
        public String driveType;
        public String driveId;
        public String id;
        public String name;
        public String path;
        public String siteId;
    }
    
    public class File {
        public string mimeType;
    }
    
    public class FileSystemInfo {
        public String createdDateTime;
        public String lastModifiedDateTime;
    }
    
    public class Folder {
        public Integer childCount;
    }
    
    public class Shared {
        public String scope;
    }
    
    public class Response {
        public List<Item> value;
    }
    
    public static String statusCodeToText(Integer code) {
        switch on code {
            when 0 {
                return 'New';
            }
            when 1 {
                return 'Read';
            }
            when 2 {
                return 'Replied';
            }
            when 3 {
                return 'Sent';
            }
            when 5 {
                return 'Draft';
            }
            when else {
                return 'N/A';
            }
        }
    }
}