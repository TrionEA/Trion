/*
Run this class with getSharepointId(String caseParentId){   
Using platform Event  
With GetCsvUsingCaseSPId_checkv2Handler Trigger Class 
*/

public class GetCsvUsingCaseSPId_checkV6 {
    
    
    private static EmailMessageInfoUtil emailMessageInfoUtil = new EmailMessageInfoUtil();
    
    public static List<Map<String, String>> getSharepointId(String caseParentId) {
        //public static string getSharepointId(String caseParentId){
        /*EventBusSubscriber subscriber = new EventBusSubscriber();
        EventBusSubscriberInterface eventBusSubscriber = (EventBusSubscriberInterface)subscriber;
        Database.registerSubscriber(eventBusSubscriber);
        */

        List<String> sharepointEmailIdList = getEmailMessageSharePointIds(caseParentId);
        String jobId;
        System.debug('List<String> sharepointEmailIdList ' + sharepointEmailIdList);  
        
        if (!sharepointEmailIdList.isEmpty()) {
            jobId = System.enqueueJob(new FetchEmailMessagesQueueable(sharepointEmailIdList,  caseParentId, emailMessageInfoUtil));
        }
        System.debug('eString jobId===>' + jobId);  
        System.debug('sharepointEmailIdList===> ' + sharepointEmailIdList); 
        System.debug('sharepointEmailIdList===> ' + sharepointEmailIdList.size()); 
        System.debug('caseParentId====> ' + caseParentId); 
        
        System.debug('emailMessageInfoUtil====> ' + emailMessageInfoUtil);  
        System.debug('return emailMessageInfoUtil.csvInfoList;;'+emailMessageInfoUtil.csvInfoList); 
        
        If(!emailMessageInfoUtil.csvInfoList.isEmpty()){
            System.debug('emailMessageInfoUtil.csvInfoList is not empty;');            
        }else{
            System.debug('emailMessageInfoUtil.csvInfoList is empty;');
        }
        System.debug('return emailMessageInfoUtil.csvInfoList;;'+emailMessageInfoUtil.csvInfoList);   
        System.debug('return jobId;;2222222222 ' + jobId);   
        return emailMessageInfoUtil.csvInfoList;
        //return jobId;
    }
    
    /* public class GetDataFromSharepoint__e extends Messaging.Event {
public List<Map<String, String>> csvInfoList;
}*/
    
    public static List<Map<String, String>> getCsvInfoList() {
        System.debug('Code is inside List<Map<String, String>> getCsvInfoList() method');
        System.debug('return emailMessageInfoUtil.csvInfoList;===>'+emailMessageInfoUtil.csvInfoList);
        return emailMessageInfoUtil.csvInfoList;
    }
    public class Database {
        //public static void registerSubscriber(EventBusSubscriberInterface subscriber) {
        //}
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
    
   
    
    public class EmailMessageInfoUtil {
        public List<Map<String, String>> csvInfoList = new List<Map<String, String>>();
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
            try {
                Case caseRecord = GetCsvUsingCaseSPId_checkv2.getCaseRecordbyId(caseParentId);
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
                
                //for(GetDataFromSharepoint__e eventVar:emailMessageInfoUtil.csvInfoList){
                
                GetDataFromSharepoint__e event = new GetDataFromSharepoint__e();
                System.debug('GetDataFromSharepoint__e event==>'+event);
                event.Emailid__c = String.valueof(EmailMessageInfoUtil.csvInfoList);
                System.debug('event.Emailid__c ==>'+event.Emailid__c);
                System.debug('event.Emailid__c ==>'+event.Emailid__c.length());
                System.debug('EventUuid: ' + event.EventUuid);
                Database.SaveResult result = EventBus.publish(event);
                System.debug('Database.SaveResult result==>'+result); 
                eventDataList.add(event);
                System.debug('eventDataList.add(event);==>'+eventDataList); 
                if (!result.isSuccess()) {
                    for (Database.Error err : result.getErrors()) {
                        System.debug('Error publishing event: ' + err.getMessage());
                    }
                }
                List<Id> successIds = new List<Id>();
                if (!eventDataList.isEmpty()) {
                    List<Database.SaveResult> results = EventBus.publish(eventDataList);
                    eventDataList.clear();
                    System.debug('List<Database.SaveResult> results =>' + results);
                    
                    for (Database.SaveResult resultnew : results) {
                        if (!resultnew.isSuccess()) {
                            successIds.add(resultnew.getId());
                            System.debug('List<Id> successIds==>'+successIds);
                            System.debug('successIds.add(resultnew.getId());==>'+resultnew.getId());
                            for (Database.Error error : resultnew.getErrors()) {
                                System.debug('Error message: ' + error.getMessage());
                                System.debug('Status code: ' + error.getStatusCode());
                            }
                        }
                    }
                    
                }
                
                //}
                
            } catch (Exception e) {
                System.debug('Error processing email messages: ' + e.getMessage());
            }
            System.debug('emailMessageInfoUtil.csvInfoList==>'+emailMessageInfoUtil.csvInfoList);
            System.debug('emailMessageInfoUtil.csvInfoList==>'+emailMessageInfoUtil.csvInfoList.size());
        }
    } 
    //System.debug('eventDataList==>'+eventDataList); 
    Public static List<GetDataFromSharepoint__e> eventDataList=new List<GetDataFromSharepoint__e>();
    
    /*    
private static EmailMessageInfoUtil emailMessageInfoUtil = new EmailMessageInfoUtil();

public static List<Map<String, String>> getSharepointId(String caseParentId) {
EventBusSubscriber subscriber = new EventBusSubscriber();
EventBusSubscriberInterface eventBusSubscriber = (EventBusSubscriberInterface)subscriber;
Database.registerSubscriber(eventBusSubscriber);

String accessToken = getAccessToken();
if (accessToken == null) {
return null;
}

List<String> sharepointEmailIdList = getEmailMessageSharePointIds(caseParentId, accessToken);

if (!sharepointEmailIdList.isEmpty()) {
String jobId = System.enqueueJob(new FetchEmailMessagesQueueable(sharepointEmailIdList, accessToken, caseParentId, emailMessageInfoUtil));
}

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

public class EmailMessageInfoUtil {
public List<Map<String, String>> csvInfoList = new List<Map<String, String>>();
}

private static String getAccessToken() {
HttpRequest req = new HttpRequest();
req.setEndpoint('https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/token');
req.setMethod('POST');
req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
req.setTimeout(120000);

String requestBody = 'grant_type=client_credentials&client_id={client-id}&client_secret={client-secret}&scope=https://graph.microsoft.com/.default';
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

private static List<String> getEmailMessageSharePointIds(String caseParentId, String accessToken) {
List<String> emailIdFromSp = new List<String>();
try {
List<Case> caseList = [SELECT Id FROM Case WHERE Id = :caseParentId LIMIT 1];
String caseFolderName = caseList.isEmpty() ? '' : caseList[0].Id;
String objectNameCase2 = GetFolderUsingCustomMetadata.getData(caseFolderName); // Assuming GetFolderUsingCustomMetadata class and method exist

String driveId = Label.SharepointDriveId; // Assuming Label.SharepointDriveId is defined somewhere

Http httpCallout = new Http();
HttpRequest req1 = new HttpRequest();
req1.setMethod('GET');
req1.setHeader('Authorization', 'Bearer ' + accessToken);
req1.setHeader('Content-Type', 'application/json');
req1.setHeader('Accept', 'application/json');
req1.setTimeout(120000);
req1.setEndpoint('https://graph.microsoft.com/v1.0/sites/3851/drives/'+driveId+'/items/root:/' + objectNameCase2 + '/' + caseFolderName + ':/children');             

HTTPResponse res1 = httpCallout.send(req1);

if (res1.getStatusCode() == 200) {
if (res1.getBody() != null) {
String jsonString = res1.getBody();
Response result = (Response) JSON.deserialize(jsonString, Response.class);
for (Item eachItem : result.value) {
emailIdFromSp.add(eachItem.name);
}
}
} else {
System.debug('Error fetching SharePoint IDs: ' + res1.getBody());
}
} catch (Exception e) {
System.debug('Exception while fetching SharePoint IDs: ' + e.getMessage());
}
return emailIdFromSp;
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

public class FileDataResult {
public Map<String, List<Object>> resultMap { get; set; }
}

public class GetDataFromSharepoint__e extends Messaging.Event {
public List<Map<String, String>> csvInfoList;
}

public class Response {
public List<Item> value;
}

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
String objectNameCase2 = GetFolderUsingCustomMetadata.getData(caseFolderName); // Assuming GetFolderUsingCustomMetadata class and method exist

for (String eachEmailMessageIdFromSp : emailIdFromSp) {
String driveId = Label.SharepointDriveId; // Assuming Label.SharepointDriveId is defined somewhere

Http httpCallout2 = new Http();
HttpRequest req2 = new HttpRequest();
req2.setMethod('GET');
req2.setHeader('Authorization', 'Bearer ' + accessToken);
req2.setHeader('Content-Type', 'application/json');
req2.setHeader('Accept', 'application/json');
req2.setTimeout(120000);
req2.setEndpoint('https://graph.microsoft.com/v1.0/sites/31/drives/' + driveId + '/items/root:/' + objectNameCase2 + '/' + caseFolderName + '/' + eachEmailMessageIdFromSp + ':/children');

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

GetDataFromSharepoint__e event = new GetDataFromSharepoint__e();
event.csvInfoList = emailMessageInfoUtil.csvInfoList;
Database.SaveResult result = EventBus.publish(event);

if (!result.isSuccess()) {
for (Database.Error err : result.getErrors()) {
System.debug('Error publishing event: ' + err.getMessage());
}
}
} catch (Exception e) {
System.debug('Error processing email messages: ' + e.getMessage());
}
}
}

*/
}