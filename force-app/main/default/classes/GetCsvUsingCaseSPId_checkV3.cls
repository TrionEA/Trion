public class GetCsvUsingCaseSPId_checkV3{
    
    
    private static EmailMessageInfoUtil emailMessageInfoUtil = new EmailMessageInfoUtil();
    
    public static List<Map<String, String>> getSharepointId(String caseParentId) {
      String accessToken = getAccessToken();
        if (accessToken == null) {
            return null;
        }
        List<String> sharepointEmailIdList = getEmailMessageSharePointIds(caseParentId, accessToken);
      /*  
        if (!sharepointEmailIdList.isEmpty()) {
            String jobId = System.enqueueJob(new FetchEmailMessagesQueueable(sharepointEmailIdList, accessToken, caseParentId, emailMessageInfoUtil));
        }
      */  
        return emailMessageInfoUtil.csvInfoList;
    }
    
    public static List<Map<String, String>> getCsvInfoList() {
        System.debug('Code is inside List<Map<String, String>> getCsvInfoList() method');
        System.debug('return emailMessageInfoUtil.csvInfoList;===>'+emailMessageInfoUtil.csvInfoList);
        return emailMessageInfoUtil.csvInfoList;
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
        public String token_type { get; set; }
        public Integer expires_in { get; set; }
        public String scope { get; set; }
        public String soap_instance_url { get; set; }
        public String rest_instance_url { get; set; }
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
    
    private static String getAccessToken() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://login.microsoftonline.com/c487bfd5-493f-43f0-b382-8da34b7b213b/oauth2/v2.0/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setTimeout(120000);
        
        String requestBody = 'grant_type=client_credentials&client_id=c6534941-5272-4d13-a86d-58a8ae871a72&client_secret=8ln8Q~vuDll8VoUHV~cXJzU6qweMa9WcV1lzBaq4&scope=https://graph.microsoft.com/.default';
        req.setBody(requestBody);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            TokenResponse tokenResponse = (TokenResponse) JSON.deserialize(res.getBody(), TokenResponse.class);
            return tokenResponse.access_token;
        } else {
            System.debug('Error getting access token: ' + res.getBody());
            return null;
        }
    }
    
    public class EmailMessageInfoUtil {
        public List<Map<String, String>> csvInfoList = new List<Map<String, String>>();
    }
    
    private static List<String> getEmailMessageSharePointIds(String caseParentId, String accessToken) {
        List<String> emailIdFromSp = new List<String>();
        List<Case> caseList = [Select id from case where id = :caseParentId limit 1];
        String caseFolderName = caseList[0].id;
        String objectNameCase2 = GetFolderUsingCustomMetadata.getData(caseFolderName); 
        String driveId = Label.SharepointDriveId;
        
        Http httpCallout = new Http();
        HttpRequest req1 = new HttpRequest();
        req1.setMethod('GET');
        req1.setHeader('Authorization', 'Bearer ' + accessToken);
        req1.setHeader('Content-Type', 'application/json');
        req1.setHeader('Accept', 'application/json');
        req1.setTimeout(120000);
        req1.setEndpoint('https://graph.microsoft.com/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId+'/items/root:/'+ objectNameCase2  +'/'+ caseFolderName + ':/children');             
        
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
        System.debug('return emailIdFromSp; ' + emailIdFromSp);
        System.debug('return emailIdFromSp; ' + emailIdFromSp.size());
        return emailIdFromSp;
    }
    /*
    public class FetchEmailMessagesQueueable implements Queueable, Database.AllowsCallouts {
        private List<String> emailIdFromSp;
        private String accessToken;
        private String caseParentId;
        private EmailMessageInfoUtil emailMessageInfoUtil;
        
        public FetchEmailMessagesQueueable(List<String> emailIdFromSp, String accessToken, String caseParentId, EmailMessageInfoUtil emailMessageInfoUtil) {
            this.emailIdFromSp = emailIdFromSp;
            this.accessToken = accessToken;
            this.caseParentId = caseParentId;
            this.emailMessageInfoUtil = emailMessageInfoUtil;
        }
        
        public void execute(QueueableContext context) {
            try {
                Case caseRecord = GetCsvUsingCaseSPId_checkv2.getCaseRecordbyId(caseParentId);
                String caseFolderName = caseRecord.Id;
                String objectNameCase2 = GetFolderUsingCustomMetadata.getData(caseFolderName);
                
                for (String eachEmailMessageIdFromSp : emailIdFromSp) {
                    String driveId = Label.SharepointDriveId;
                    
                    Http httpCallout2 = new Http();
                    HttpRequest req2 = new HttpRequest();
                    req2.setMethod('GET');
                    req2.setHeader('Authorization', 'Bearer ' + accessToken);
                    req2.setHeader('Content-Type', 'application/json');
                    req2.setHeader('Accept', 'application/json');
                    req2.setTimeout(120000);
                    req2.setEndpoint('https://graph.microsoft.com/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/' + driveId + '/items/root:/' + objectNameCase2 + '/' + caseFolderName + '/' + eachEmailMessageIdFromSp + ':/children');
                    
                    HTTPResponse res2 = httpCallout2.send(req2);
                    
                    if (res2.getStatusCode() == 200) {
                        if (res2.getBody() != null) {
                            String jsonString2 = res2.getBody();
                            Response result2 = (Response) JSON.deserialize(jsonString2, Response.class);
                            
                            for (Item eachItem2 : result2.value) {
                                if (eachItem2.name.contains('EmailMessageDetails')) {
                                    Map<String, String> csvInfo = new Map<String, String>();
                                    csvInfo.put('fileName', eachItem2.name);
                                    csvInfo.put('fileSize', eachItem2.size);
                                    csvInfo.put('fileType', eachItem2.File.mimeType);
                                    csvInfo.put('fileCreatedDateTime', eachItem2.createdDateTime);
                                    csvInfo.put('fileSPWebUrl', eachItem2.webUrl);
                                    csvInfo.put('fileSPEtag', eachItem2.eTag.substring(2, eachItem2.eTag.length() - 4));
                                    
                                    emailMessageInfoUtil.csvInfoList.add(csvInfo);
                                }
                            }
                        }
                    }
                }

            } catch (Exception e) {
                System.debug('Error processing email messages: ' + e.getMessage());
            }
            System.debug('emailMessageInfoUtil.csvInfoList==>'+emailMessageInfoUtil.csvInfoList);
            System.debug('emailMessageInfoUtil.csvInfoList==>'+emailMessageInfoUtil.csvInfoList.size());
        }
    } 
*/
}