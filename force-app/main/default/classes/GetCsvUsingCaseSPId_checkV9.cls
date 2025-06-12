/*
With 2 Future Methods
*/


public class GetCsvUsingCaseSPId_checkV9 {
    private static EmailMessageInfoUtil emailMessageInfoUtil = new EmailMessageInfoUtil();
    
    public static String getSharepointId(String caseParentId){
        List<String> sharepointEmailIdList = getEmailMessageSharePointIds(caseParentId);
        String jobId;
        
        if (!sharepointEmailIdList.isEmpty()) {
            jobId = System.enqueueJob(new FetchEmailMessagesQueueable(sharepointEmailIdList, caseParentId, emailMessageInfoUtil));
        }
        System.debug('FetchEmailMessagesQueueable(sharepointEmailIdList===> '+sharepointEmailIdList);   
        System.debug('FetchEmailMessagesQueueable(caseParentId===> '+caseParentId);   
        System.debug('FetchEmailMessagesQueueable(emailMessageInfoUtil===> '+emailMessageInfoUtil);   
        System.debug('getSharepointId return csvInfoList;===> ' + emailMessageInfoUtil.csvInfoList);
        System.debug('getSharepointId return csvInfoList;===> ' + emailMessageInfoUtil.csvInfoList.size());
        
        return jobId;        
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
        System.debug('getEmailMessageSharePointIds return emailIdFromSp;===> ' + emailIdFromSp);
        System.debug('getEmailMessageSharePointIds return emailIdFromSp;===> ' + emailIdFromSp.size());
        return emailIdFromSp;
    }
    
    public class FetchEmailMessagesQueueable implements Queueable, Database.AllowsCallouts {
        private List<String> emailIdFromSp;
        private String caseParentId;
        private EmailMessageInfoUtil emailMessageInfoUtil;
        
        public FetchEmailMessagesQueueable(List<String> emailIdFromSp, String caseParentId, EmailMessageInfoUtil emailMessageInfoUtil) {
            this.emailIdFromSp = emailIdFromSp;
            this.caseParentId = caseParentId;
            this.emailMessageInfoUtil = emailMessageInfoUtil;
        }
        
        public void execute(QueueableContext context) {
            List<Map<String, String>> csvInfoList = EmailCsvBatchProcessor_V2.triggerProcessSharepointEmailIds(emailIdFromSp, caseParentId);
            emailMessageInfoUtil.csvInfoList.addAll(csvInfoList);
            
            System.debug('FetchEmailMessagesQueueable List<Map<String, String>> csvInfoList ===> ' + csvInfoList);
            System.debug('FetchEmailMessagesQueueable List<Map<String, String>> csvInfoList ===> ' + csvInfoList.size());
            System.debug('FetchEmailMessagesQueueable emailMessageInfoUtil.csvInfoList.addAll(csvInfoList) ===> ' + emailMessageInfoUtil.csvInfoList);
            System.debug('FetchEmailMessagesQueueable emailMessageInfoUtil.csvInfoList.addAll(csvInfoList) ===> ' + emailMessageInfoUtil.csvInfoList.size());
        }
    }
    
    
    
   /* private static List<Map<String, String>> fetchEmailMessages(List<String> emailIdFromSp, String caseParentId) {
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
                                System.debug('sharepointid ===>'+sharepointEmailIdList.size());    
                            }
                        }
                    }
                }
            }
            //sharepointEmailIdList.add(fileid)
            //System.debug('sharepointid ===>'+sharepointEmailIdList.size());  
            csvInfoList = EmailCsvBatchProcessor_V2.triggerProcessSharepointEmailIds(sharepointEmailIdList);
            //csvInfoList = system.enquejob(EmailCsvProcessor.EmailCsvProcessor(sharepointEmailIdList));

        } catch (Exception e) {
            System.debug('Error processing email messages: ' + e.getMessage());
        }
        System.debug('csvInfoList ===>'+csvInfoList);  
        System.debug('csvInfoList size ===>'+csvInfoList.size());  
        return csvInfoList;
    }
*/  
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