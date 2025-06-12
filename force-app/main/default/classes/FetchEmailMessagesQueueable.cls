public class FetchEmailMessagesQueueable implements Queueable, Database.AllowsCallouts {
    public List<String> emailIdFromSp;
    public String accessToken;
    public String caseParentId;
    public EmailMessageInfoUtil emailMessageInfoUtil { get; private set; }
    //private static EmailMessageInfoUtil emailMessageInfoUtil = new EmailMessageInfoUtil();
    public FetchEmailMessagesQueueable(List<String> emailIdFromSp, String accessToken, String caseParentId, EmailMessageInfoUtil emailMessageInfoUtil) {
        this.emailIdFromSp = emailIdFromSp;
        this.accessToken = accessToken;
        this.caseParentId = caseParentId;
        this.emailMessageInfoUtil = emailMessageInfoUtil;
    }
    
    public void execute(QueueableContext context) {
        Case caseRecord = GetCsvUsingCaseSPId_checkv2.getCaseRecordbyId(caseParentId);
        String caseFolderName = caseRecord.Id;    
        String objectNameCase2 = GetFolderUsingCustomMetadata.getData(caseFolderName); 
        for (String eachEmailMessageIdFromSp : emailIdFromSp) {
            try {
                String driveId = Label.SharepointDriveId;
                Http httpCallout2 = new Http();
                HttpRequest req2 = new HttpRequest();
                req2.setMethod('GET');
                req2.setHeader('Authorization', 'Bearer ' + accessToken);
                req2.setHeader('Content-Type', 'application/json');
                req2.setHeader('Accept', 'application/json');
                req2.setTimeout(120000);
                req2.setEndpoint('https://graph.microsoft.com/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId+'/items/root:/'+objectNameCase2 +'/' +caseFolderName +'/'+ eachEmailMessageIdFromSp +':/children');
                
                HTTPResponse res2 = httpCallout2.send(req2);
                
                if (res2.getStatusCode() == 200) {
                    if (res2.getBody() != null) {
                        String jsonString2 = res2.getBody();
                        System.debug('String jsonString2; ' + jsonString2);
                        Response result2 = (Response) JSON.deserialize(jsonString2, Response.class);
                        for (Item eachItem2 : result2.value) {
                            if (eachItem2.name.contains('EmailMessageDetails')) {
                                Map<String, String> csvInfo = new Map<String, String>();
                                System.debug('Map<String, String> csvInfo ' + csvInfo);
                                csvInfo.put('fileName', eachItem2.name);
                                csvInfo.put('fileSize', eachItem2.size);
                                csvInfo.put('fileType', eachItem2.File.mimeType);
                                csvInfo.put('fileCreatedDateTime', eachItem2.createdDateTime);
                                csvInfo.put('fileSPWebUrl', eachItem2.webUrl);
                                csvInfo.put('fileSPEtag', eachItem2.eTag.substring(2, eachItem2.eTag.length() - 4));
                                //emailMessageInfoUtil.csvInfoList.add(csvInfo);
                            }
                        }
                    }
                }
            } catch (Exception e) {
                System.debug('Error processing email message: ' + e.getMessage());
            }
        }
        //System.debug('return csvInfoList; ' + emailMessageInfoUtil.csvInfoList);
    }
    
        @AuraEnabled
    public static Case getCaseRecordbyId(String caseId) {
        Case caseRecord;
        try {
            caseRecord = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseId LIMIT 1];
            System.debug('Case Record Retrieved: ' + caseRecord);
        } catch (Exception e) {
            System.debug('Catch Exception: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving case record: ' + e.getMessage());
        }      
        return caseRecord;
    }
    
    public static String getUserNameRecordbyId(String userId){
        return (String)[Select Id, Name from User where id = :userId limit 1].Name;
    }
    
    public class FileDataResult {
        public Map<String, List<Object>> resultMap { get; set; }
    }
    
    public class TokenResponse {
        public String access_token { get; set; }
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
    
}