public class GetCSVFromSharePoint {
    public class customException extends exception{}
    @AuraEnabled
    Public static void createEmailTemplatesAndCtas(){
        
        string accessToken = getAccessToken();
        getDataFromSharePoint(accessToken);
    }
    public static String getAccessToken() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://login.microsoftonline.com/c487bfd5-493f-43f0-b382-8da34b7b213b/oauth2/v2.0/token');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setTimeout(120000);
        
        String requestBody = 'grant_type=client_credentials&client_id=c6534941-5272-4d13-a86d-58a8ae871a72&client_secret=xrO8Q~MhW1tE4axOAvGr6JgicRQjGcXAxQBqbbi_&scope=https://graph.microsoft.com/.default';
        req.setBody(requestBody);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            TokenResponse tokenResponse = (TokenResponse) JSON.deserialize(res.getBody(), TokenResponse.class);
            // Do something with the deserialized tokenResponse object
            system.debug(res.getBody());
            return tokenResponse.access_token;
        } else {
            return null;
            // Handle the error response
        }
    }
    
    
    
    public static void getDataFromSharePoint(string accessToken) {
        
        List<EmailMessage_Html__b> emailStagingList = [SELECT Title__c, Status__c, sObject__c, Is_Large_File__c, File_Size__c, Error_Message__c, Emailmessage_Id__c,Parent_Case_Id__c,File_Body__c
                                                           FROM EmailMessage_Html__b
                                                           WHERE Status__c = 'Not Started' LIMIT 1];
        
        if (emailStagingList.isEmpty()) {
                emailStagingList = [SELECT Title__c
                                    FROM EmailMessage_Html__b
                                    WHERE Status__c = 'Pending' LIMIT 1]; 
                
            }
        
        Blob fileBody;
            String fileName='';
            String csvId='';
            String emailMessagebody='';
            String objectName='';
            string parentCaseId='';
            integer listSize=emailStagingList.size();
            
            
            for (EmailMessage_Html__b emhbl : emailStagingList) {
                if(listSize > 0){
                    
                    fileName = emailStagingList[0].Title__c;
                    system.debug('fileName: ' +fileName);
                    csvId = fileName.substring(20, 38);
                    system.debug('String csvId: ' +csvId);
                    emailMessagebody = emailStagingList[0].File_Body__c;
                    fileBody = Blob.valueOf(emailMessagebody);  
                    objectName = emailStagingList[0].sObject__c;
                    parentCaseId=emailStagingList[0].Parent_Case_Id__c;
                    system.debug('String parentCaseId: ' +parentCaseId);
                }
            }
        
        String encodedParentCaseId = emailStagingList[0].Parent_Case_Id__c;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setTimeout(120000);
        request.setEndpoint('https://graph.microsoft.com/v1.0/sites/d7c113dd-f195-44b6-a7ff-027d3860f10f/drives/b!3RPB15XxtkSn_wJ9OGDxDwymYO9ecrFLrZXuL7fJXMpOcHHo4EI6TZMW56RJH70a/items/root:/Case/' + encodedParentCaseId + ':/children');
        //request.setEndpoint('https://graph.microsoft.com/v1.0/sites?search=*');
        
        HttpResponse response = http.send(request);
        
        System.debug('>>> Response Headers: ' + response.getHeaderKeys());
        System.debug('>>> Content-Type Header: ' + response.getHeader('Content-Type'));
        System.debug('>>> Full Response: ' + response.getBody());
        System.debug('>>> Status Code: ' + response.getStatusCode());
        
        if (response.getStatusCode() == 200) {
            try {
                if (response.getBody() != null) {
                    String jsonString = response.getBody();
                     Overall result = (Overall)JSON.deserialize(jsonString, Overall.class);
                    System.debug('>>> emailResponse ' +result);
                               for(cls_items eachItem : result.value){
                                       system.debug(eachItem.name);
                                     system.debug(eachItem.id);
										system.debug(eachItem.webUrl);
                               }
                    
                } else {
                    System.debug('Response body is null or empty');
                }
            } catch (Exception e) {
                System.debug('Error deserializing JSON: ' + e.getMessage());
            }
        }
    }
    
    
    public class TokenResponse {
        public String access_token { get; set; }
        public String token_type { get; set; }
        public Integer expires_in { get; set; }
        public String scope { get; set; }
        public String soap_instance_url { get; set; }
        public String rest_instance_url { get; set; }
    }
    
    
   public class Overall {
    public String odataContext;
    public List<cls_items> value;
}

public class cls_items {
    public String createdDateTime;
    public String eTag;
    public String id;
    public String lastModifiedDateTime;
    public String name;
    public String webUrl;
    public String cTag;
    public Integer size;
    public CreatedBy createdBy;
    public LastModifiedBy lastModifiedBy;
    public ParentReference parentReference;
    public FileSystemInfo fileSystemInfo;
    public FolderInfo folder;
    public Shared shared;
    // Add properties for other nested objects if needed
}

public class CreatedBy {
    public User user;
}

public class LastModifiedBy {
    public User user;
}

public class ParentReference {
    public String driveType;
    public String driveId;
    public String id;
    public String name;
    public String path;
    public String siteId;
}

public class FileSystemInfo {
    public String createdDateTime;
    public String lastModifiedDateTime;
}

public class FolderInfo {
    public Integer childCount;
}

public class Shared {
    public String scope;
}

public class User {
    public String email;
    public String id;
    public String displayName;
}

}