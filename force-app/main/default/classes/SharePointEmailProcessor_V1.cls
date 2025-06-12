public class SharePointEmailProcessor_V1 {
 /*   public static List<Map<String, String>> processSharepointEmailIds(List<String> spEmailId, String caseParentId) {
        System.debug(' Code is inside List<Map<String, String>> processSharepointEmailIds');        
        List<Map<String, String>> spInfoList = new List<Map<String, String>>();
        List<Map<String, String>> csvInfoList = new List<Map<String, String>>();
        List<String> sharepointEmailIdList= new List<String>();
        String fileid;
        String sharepointid;
        List<Case> caseList = [Select id from case where id = :caseParentId limit 1];
        String caseFolderName = caseList[0].id;
        String objectNameCase2 = GetFolderUsingCustomMetadata.getData(caseFolderName);
        try {
            Integer chunkSize = 15;
            System.debug('Integer chunkSize----> ' + chunkSize);
            Integer totalRecords = spEmailId.size();
            System.debug('Integer totalRecords----> ' + totalRecords);
            
            for (Integer chunkStart = 0; chunkStart < totalRecords; chunkStart += chunkSize) {
                System.debug('Integer chunkStart----> ' + chunkStart);
                Integer chunkEnd = Math.min(chunkStart + chunkSize, totalRecords);
                System.debug('Integer chunkEnd----> ' + chunkEnd);
                List<String> chunk = new List<String>();
                
                for (Integer i = chunkStart; i < chunkEnd; i++) {
                    chunk.add(spEmailId[i]);                   
                }
                System.debug('List<String> chunk------> ' + chunk);
                System.debug('List<String> chunk SIZE------> ' + chunk.size());
                
                for (String spid : chunk) {
                    
                    Http httpCallout2 = new Http();
                    HttpRequest req2 = new HttpRequest();
                    req2.setMethod('GET');
                    req2.setHeader('Content-Type', 'application/json');
                    req2.setHeader('Accept', 'application/json');
                    req2.setTimeout(120000);
                    req2.setEndpoint('callout:Sharepoint/v1.0/sites/' + Label.SharePoint_Site_Id + '/drives/' + Label.SharepointDriveId + '/items/root:/' + objectNameCase2 + '/' + caseFolderName + '/' + spid + ':/children');
                    
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
            }
        }catch (Exception e) {
            System.debug('Catch exception: ' + e.getMessage());
        }
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
*/
}