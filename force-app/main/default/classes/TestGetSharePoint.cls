public class TestGetSharePoint{
    
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
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setTimeout(120000);
        request.setEndpoint('https://graph.microsoft.com/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/b!3RPB15XxtkSn_wJ9OGDxDwymYO9ecrFLrZXuL7fJXMpOcHHo4EI6TZMW56RJH70a/items/root:/EmailMessage:/children');
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
                    Response result = (Response) JSON.deserialize(jsonString, Response.class);
                    System.debug('EmailResponse: ' + result);
                     for(Item eachItem : result.value){
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