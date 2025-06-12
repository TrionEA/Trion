public class GetParentFolderData {
   public static FileDataResult getfileData(String caseParentId){
            FileDataResult fileData = new FileDataResult();
           fileData.resultMap = new Map<String, List<Object>>();
            //fileData.resultList = new List<Object>();
        String accessToken;
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
            accessToken=tokenResponse.access_token;
            //return tokenResponse.access_token;
        } else {
            return null;
            // Handle the error response
        }
        
        List<Case_Email__c> caseEmail = [Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                                   LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, 
                                   LastReferencedDate, Case__c, Case_Email_Number__c, Case_Number__c, EmailMessage_Id__c, 
                                   Email_Message_SharePoint_Id__c, Email_Message_Created_Date__c, Case_Id__c 
                                   from Case_Email__c where Case_Id__c =: caseParentId ];
       String caseFolderName=caseEmail[0].Case_Id__c;
       String subFolderName;
       List<string> emailMessageIds = new List<string>();

       for(Case_Email__c ce:caseEmail){
           //subFolderName=ce.EmailMessage_Id__c;
           emailMessageIds.add(ce.EmailMessage_Id__c);
       }
       System.debug('List<String> emailMessageIds=>' +emailMessageIds);
       
      for(string ce:emailMessageIds){
           subFolderName=ce;
          System.debug('String subFolderName' +subFolderName);
       
      
       String emailMessageIdsString = String.join(emailMessageIds, ',');
       System.debug('String emailMessageIdsString=='+emailMessageIdsString);
        //String subFolderName=caseEmail[0].EmailMessage_Id__c;
        System.debug('String caseFolderName' +caseFolderName);
        System.debug('String subFolderName' +subFolderName);
        //Map<String,List<object>> MapWeb=new Map<String,List<object>>();
        String fileName;
        String fileSpId;
        String fileSPWebUrl;
        String fileCreatedDateTime;
        String fileSPEtag;
        String fileSize;
        String fileType;
        
        
        
        try{
            
            String driveId = 'b!3RPB15XxtkSn_wJ9OGDxDwymYO9ecrFLrZXuL7fJXMpOcHHo4EI6TZMW56RJH70a';
            String encodedDriveId = EncodingUtil.urlEncode(driveId, 'UTF-8');
            //String encodedFileName = EncodingUtil.urlEncode(fileName, 'UTF-8');
            //String subFolderName = stagingList[0].Linked_Entity_Id__c;
            //String objectName = stagingList[0].sObject__c;
            
            Http httpCallout = new Http();
            HttpRequest req1 = new HttpRequest();
            String objectNameCase = 'Case';
            
            
            
            
            //req.setEndpoint('callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/'+ objectName  +'/'+subFolderName+'/' + encodedFileName.replaceall('\\+', '%20') + ':/content');
            req1.setMethod('GET');
            req1.setHeader('Authorization', 'Bearer ' + accessToken);
            req1.setHeader('Content-Type', 'application/json');
            req1.setHeader('Accept', 'application/json');
            req1.setTimeout(120000);
            req1.setEndpoint('https://graph.microsoft.com/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId+'/items/root:/'+ objectNameCase  +'/'+ caseFolderName + '/' + subFolderName +':/children'); 
            
            //req.setBodyAsBlob(fileBody);
            
            HTTPResponse res1 = httpCallout.send(req1);
            
            if (res1.getStatusCode() == 200) {
                try {
                    if (res1.getBody() != null) {
                        String jsonString = res1.getBody();
                        Response result = (Response) JSON.deserialize(jsonString, Response.class);
                        System.debug('EmailResponse: ' + result);
                        for(Item eachItem : result.value){
                            List<object> dataList=new List<object>();
                            
                            fileName=eachItem.name;
                            if(!fileName.contains('EmailMessageDetails')){
                            fileSpId=eachItem.id;
                            fileSPWebUrl=eachItem.webUrl;
                            fileCreatedDateTime=eachItem.createdDateTime;
                            fileSPEtag=eachItem.eTag.substring(2, eachItem.eTag.length() - 4);
                            fileSize=eachItem.size;
                            fileType=eachItem.File.mimeType;
                            system.debug(eachItem.name);
                            system.debug(eachItem.id);
                            system.debug(eachItem.webUrl);
                            system.debug(eachItem.createdDateTime);
                            system.debug(eachItem.eTag.substring(2, eachItem.eTag.length() - 4));
                            system.debug(eachItem.size);
                            system.debug(eachItem.File.mimeType);
                            dataList.add(fileName);
                            dataList.add(fileSize);
                            dataList.add(fileType);
                            dataList.add(fileSPEtag);
                            dataList.add(fileCreatedDateTime);
                            fileData.resultMap.put(fileSPWebUrl, dataList);
                            }
                            
                        }
                            System.debug('Map<String,List<Object>> MapWeb==>' + fileData.resultMap);                          
                            //System.debug('Map<String,List<object>> MapWeb==>'+MapWeb);
                            //System.debug('List<object> dataList=>'+dataList);
                        
                    } else {
                        System.debug('Response body is null or empty');
                    }
                } catch (Exception e) {
                    System.debug('Error deserializing JSON: ' + e.getMessage());
                }
            }
            
            
            
            /*     if(res1.getStatusCode() == 200){
String jsonString = res1.getBody();
System.debug('String jsonString' +jsonString);
Map<String, Object> deserializeResponse = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
System.debug('Map<String, Object> deserializeResponse' +deserializeResponse);


Map<String, Object> fileType = (Map<String, Object>) deserializeResponse.get('file');
System.debug('Map<String, Object> fileType ' +fileType);

if (deserializeResponse != null) {
String spid = (String) deserializeResponse.get('id');
System.debug('id: ' +spid);
String spetagid = (String) deserializeResponse.get('eTag');
System.debug('eTag: ' +spetagid);
dataList.add(spetagid);
String spweburl = (String) deserializeResponse.get('webUrl');
System.debug('webUrl: ' +spweburl); 
Integer spsize = (integer) deserializeResponse.get('size');
dataList.add(spsize);
System.debug('size: ' +spsize);
String spfilecreateddate = (String) deserializeResponse.get('createdDateTime');
dataList.add(spfilecreateddate);
System.debug('createdDateTime: ' +spfilecreateddate); 
String spfiletype = (String) fileType.get('mimeType');
dataList.add(spfiletype);
MapWeb.put(spweburl,dataList);
System.debug('mimeType: ' +spfiletype);

System.debug('List<object>li: ' +dataList);
System.debug('Map<String,List<object>>MapWeb: ' +MapWeb);
}
}
*/
        }catch(exception e){
            System.debug('Catch exception'+e.getMessage());
        }
        //return dataList;
      }
        return fileData;
        
    }
     
public class FileDataResult {
public Map<String, List<Object>> resultMap { get; set; }
//public List<Object> resultList { get; set; }
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