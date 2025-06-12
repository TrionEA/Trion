public class GetFolderBasedOnDate {
    public static String getData(){
    //public static string getfileData(String emailMessageId){
        ResponseWrap fileData = new ResponseWrap();
        
        String fileName;
        String fileSpId;
        String fileSPWebUrl;
        String fileCreatedDateTime;
        String fileSPEtag;
        String fileSize;
        String fileType;
        
        String endDate;
        String startDate;
        
        String responseString = '';
        String accessToken;
        
        String metadataYear;
        String metadataMonth;
        String metadataDate;
        String mergedMetadataDate;
        String caseDate,caseClosedDate;
       
        List<Sharepoint_Folder_Name__mdt> customMetadataFolderNameList=[select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, 
                                                                        QualifiedApiName, SystemModstamp, Year__c, Month__c, Date__c, Sharepoint_Folder_Name__c 
                                                                        from Sharepoint_Folder_Name__mdt];
        
        for(Sharepoint_Folder_Name__mdt fnamemdt:customMetadataFolderNameList){
            metadataYear=fnamemdt.Year__c;
            metadataMonth=fnamemdt.Month__c;
            metadataDate=fnamemdt.Date__c;
              
            mergedMetadataDate= metadataYear + '-' + metadataMonth + '-' + metadataDate;
            System.debug('Custom Metadata Date=>' + mergedMetadataDate);
            
        }
       /* 
        List<Case> caseList=[select id,ClosedDate from Case where ClosedDate <LAST_N_DAYS:3700];
        for(Case cs:caseList){
            caseDate = String.valueOf(cs.ClosedDate);
            caseClosedDate = caseDate.substring(0, caseDate.length() - 10);
            System.debug('String caseClosedDate=>' + caseClosedDate);
        }
       */ 
        
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
            // Do something with the deserialized tokenResponse object
            System.debug(res.getBody());
            accessToken = tokenResponse.access_token;
            responseString = accessToken;
            System.debug(responseString);
        } else {
            System.debug('Error: ' + res.getStatus());
            responseString = 'Error: Unable to retrieve token';
            System.debug(responseString);            
            return responseString;
        }
        
        try{
            
            String driveId = Label.SharepointDriveId;
            String encodedDriveId = EncodingUtil.urlEncode(driveId, 'UTF-8');
            System.debug('String driveId: ' + driveId);
            System.debug('String encodedDriveId: ' + encodedDriveId);
            Http httpCallout = new Http();
            HttpRequest req1 = new HttpRequest();
            String objectNameCase = 'CaseNew';
            req1.setMethod('GET');
            req1.setHeader('Authorization', 'Bearer ' + responseString);
            req1.setHeader('Content-Type', 'application/json');
            req1.setHeader('Accept', 'application/json');
            req1.setTimeout(120000);
            //req1.setEndpoint('https://graph.microsoft.com/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId+'/items/root:/'+ objectNameCase  +'/'+ caseFolderName + '/' + subFolderName +':/children'); 
            req1.setEndpoint('https://graph.microsoft.com/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId+'/items/root:/'+ objectNameCase  +':/children'); 
            
            
            HTTPResponse res1 = httpCallout.send(req1);
            System.debug('res1 status code: ' + res1.getStatusCode());
            if (res1.getStatusCode() == 200) {
                try {
                    if (res1.getBody() != null) {
                        String jsonString = res1.getBody();
                        responseString = res1.getBody();
                        Response result = (Response) JSON.deserialize(jsonString, Response.class);
                        System.debug('EmailResponse: ' + result);
                                                
                        for(Item eachItem : result.value){
                            List<object> dataList=new List<object>();
                            fileName=eachItem.name;
                            //System.debug('Code is inside the loop');
                            system.debug(eachItem.name);
                            system.debug('fileName=>'+fileName);           
                            
                            startDate = fileName.substring(20, fileName.length() - 1);
                            endDate = fileName.substring(6, fileName.length() - 15);
                            System.debug(startDate);
                            System.debug(endDate);
                        }                                               
                    } else {
                        System.debug('Response body is null or empty');
                    }
                } catch (Exception e) {
                    System.debug('Error deserializing JSON: ' + e.getMessage());
                }
            }            
        }catch(exception e){
            System.debug('Catch exception'+e.getMessage());
        }       
        
        System.debug('Out side try catch block');
        
        String mainCaseFolderName;
        if(caseClosedDate >= startDate && caseClosedDate <= endDate){
            System.debug('Code is inside the condition.');
            mainCaseFolderName=fileName;
            System.debug('String mainCaseFolderName===>'+ mainCaseFolderName);
        }
        
       
        
        
        
        
        
        
        
        
        
        return responseString;          
        
    }    
    
    public class responseWrap{
        public list<ResponseItem> responseItems;
    }
    
    public class ResponseItem {
        public String createdDateTime;
        public String eTag;
        public String id;
        public String name;
        public String webUrl;
        public String size;
        public String fileType;
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
        //public string @microsoft.graph.downloadUrl;
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
        Public File File;
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
    
    Public class File{
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