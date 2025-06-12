public class EmailCsvBatchProcessor_V2 implements Database.Batchable<String>, Database.AllowsCallouts {
    //private List<String> sharepointEmailIdList;
    Private List<String> emailIdFromSp;
    Private string caseParentId;
    
    public EmailCsvBatchProcessor_V2(List<String> emailIdFromSp, /*List<String> sharepointEmailIdList,*/ string caseParentId) {
        //this.sharepointEmailIdList = sharepointEmailIdList;
        this.emailIdFromSp = emailIdFromSp;
        this.caseParentId = caseParentId;
    }
    
    public Iterable<String> start(Database.BatchableContext context) {
        //return sharepointEmailIdList;
        return emailIdFromSp;
    }
    public void execute(Database.BatchableContext context, List<String> scope) {
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
            //csvInfoList = EmailCsvBatchProcessor_V1.triggerProcessSharepointEmailIds(sharepointEmailIdList);
            //csvInfoList = system.enquejob(EmailCsvProcessor.EmailCsvProcessor(sharepointEmailIdList));
            
        } catch (Exception e) {
            System.debug('Error processing email messages: ' + e.getMessage());
        }
        System.debug('csvInfoList ===>'+csvInfoList);  
        System.debug('csvInfoList size ===>'+csvInfoList.size());  
        //return csvInfoList;
        
        
        try {
            Integer chunkSize = 25;
            Integer totalRecords = sharepointEmailIdList.size();
            
            for (Integer chunkStart = 0; chunkStart < totalRecords; chunkStart += chunkSize) {
                Integer chunkEnd = Math.min(chunkStart + chunkSize, totalRecords);
                List<String> chunk = new List<String>();
                
                for (Integer i = chunkStart; i < chunkEnd; i++) {
                    chunk.add(sharepointEmailIdList[i]);
                }
                
                List<Map<String, String>> chunkCsvInfoList = new List<Map<String, String>>();
                
                for (String spid : chunk) {
                    sharepointid = spid;
                    HttpRequest req2 = new HttpRequest();
                    req2.setMethod('GET');
                    req2.setHeader('Accept', 'application/json;odata=verbose');
                    req2.setEndpoint('callout:Sharepoint/v1.0/drives/' + Label.SharepointDriveId + '/items/' + sharepointid + '/content');
                    HTTPResponse res2 = new Http().send(req2);
                    
                    try {
                        while (res2.getStatusCode() == 302) {
                            req2.setEndpoint(res2.getHeader('Location'));
                            res2 = new Http().send(req2);
                        }
                    } catch (Exception e) {
                        System.debug('Catch exception: ' + e.getMessage());
                    }
                    
                    Blob headerValue = Blob.valueOf(res2.getBody());
                    String body = EncodingUtil.base64Encode(headerValue);
                    String lines = res2.getBody();
                    List<String> allValues = lines.split(',');
                    
                    List<String> Headers1 = new List<String>();
                    for (Integer i = 0; i < 39; i++) {
                        if (i <= 37)
                            Headers1.add(allValues[i]);
                        else {
                            Headers1.add('HtmlBody');
                        }
                    }
                    
                    List<String> allValues1 = lines.split('##  ');
                    List<String> Values1 = new List<String>();
                    
                    for (Integer i = 1; i < 40; i++) {
                        Values1.add(allValues1[i]);
                    }
                    
                    Map<String, String> MapHeadersValues = new Map<String, String>();
                    
                    for (Integer i = 0; i < 39; i++) {
                        MapHeadersValues.put(Headers1[i], Values1[i]);
                    }
                    
                    Map<String, String> csvInfo = new Map<String, String>();
                    csvInfo.put('IdOfCsv', String.valueOf(MapHeadersValues.get('Id')).substring(0, (String.valueOf(MapHeadersValues.get('Id')).length() - 3)));
                    csvInfo.put('ParentId', String.valueOf(MapHeadersValues.get('ParentId')).substring(0, (String.valueOf(MapHeadersValues.get('ParentId')).length() - 3)));
                    csvInfo.put('CreatedDate', String.valueOf(MapHeadersValues.get('CreatedDate')).substring(0, (String.valueOf(MapHeadersValues.get('CreatedDate')).length() - 3)));
                    csvInfo.put('Subject', String.valueOf(MapHeadersValues.get('Subject')).substring(0, (String.valueOf(MapHeadersValues.get('Subject')).length() - 3)));
                    csvInfo.put('FromAddress', String.valueOf(MapHeadersValues.get('FromAddress')).substring(0, (String.valueOf(MapHeadersValues.get('FromAddress')).length() - 3)));
                    csvInfo.put('ToAddress', String.valueOf(MapHeadersValues.get('ToAddress')).substring(0, (String.valueOf(MapHeadersValues.get('ToAddress')).length() - 3)));
                    csvInfo.put('MessageDate', String.valueOf(MapHeadersValues.get('MessageDate')).substring(0, (String.valueOf(MapHeadersValues.get('MessageDate')).length() - 3)));
                    csvInfo.put('Status', String.valueOf(MapHeadersValues.get('Status')).substring(0, (String.valueOf(MapHeadersValues.get('Status')).length() - 3)));
                    String status = statusCodeToText(Integer.valueOf(csvInfo.get('Status')));
                    csvInfo.put('Status', status);
                    System.debug(' =>' + csvInfo.get('Status'));
                    System.debug('csvInfo.put(IdOfCsv)=>' + csvInfo.get('IdOfCsv'));
                    System.debug('csvInfo.put(ParentId)=>' + csvInfo.get('ParentId'));
                    System.debug('csvInfo.put(HtmlBody)=>' + csvInfo.get('HtmlBody'));
                    chunkCsvInfoList.add(csvInfo);
                    System.debug('chunkCsvInfoList.add(csvInfo); chunkCsvInfoList===>' + chunkCsvInfoList);
                    System.debug('chunkCsvInfoList.add(csvInfo); chunkCsvInfoList size===>' + chunkCsvInfoList.size());
                }
                
                csvInfoList.addAll(chunkCsvInfoList);
                System.debug('csvInfoList.addAll(chunkCsvInfoList); csvInfoList===>' + csvInfoList);
                System.debug('csvInfoList.addAll(chunkCsvInfoList); csvInfoList size===>' + csvInfoList.size());
            }
        } catch (Exception e) {
            System.debug('Catch exception: ' + e.getMessage());
        }
        
        setCsvInfoList(csvInfoList);
        System.debug('Final csvInfoList List===>' + csvInfoList);
        System.debug('Final csvInfoList List size===>' + csvInfoList.size());
        
    }
    
    public void finish(Database.BatchableContext context) {
	 	System.debug('####################Batch is completed;');
    }
    
    /* 
public static void processSharepointEmailIds(List<String> sharepointEmailIdList) {
List<Map<String, String>> csvInfoList = new List<Map<String, String>>();
try {
Integer chunkSize = 30;
Integer totalRecords = sharepointEmailIdList.size();

for (Integer chunkStart = 0; chunkStart < totalRecords; chunkStart += chunkSize) {
Integer chunkEnd = Math.min(chunkStart + chunkSize, totalRecords);
List<String> chunk = new List<String>();

for (Integer i = chunkStart; i < chunkEnd; i++) {
chunk.add(sharepointEmailIdList[i]);
}

List<Map<String, String>> chunkCsvInfoList = new List<Map<String, String>>();

for (String spid : chunk) {
String sharepointid = spid;
HttpRequest req2 = new HttpRequest();
req2.setMethod('GET');
req2.setHeader('Accept', 'application/json;odata=verbose');
req2.setEndpoint('callout:Sharepoint/v1.0/drives/' + Label.SharepointDriveId + '/items/' + sharepointid + '/content');
HTTPResponse res2 = new Http().send(req2);

try {
while (res2.getStatusCode() == 302) {
req2.setEndpoint(res2.getHeader('Location'));
res2 = new Http().send(req2);
}
} catch (Exception e) {
System.debug('Catch exception: ' + e.getMessage());
}

Blob headerValue = Blob.valueOf(res2.getBody());
String body = EncodingUtil.base64Encode(headerValue);
String lines = res2.getBody();
List<String> allValues = lines.split(',');

List<String> Headers1 = new List<String>();
for (Integer i = 0; i < 39; i++) {
if (i <= 37)
Headers1.add(allValues[i]);
else {
Headers1.add('HtmlBody');
}
}

List<String> allValues1 = lines.split('##  ');
List<String> Values1 = new List<String>();

for (Integer i = 1; i < 40; i++) {
Values1.add(allValues1[i]);
}

Map<String, String> MapHeadersValues = new Map<String, String>();

for (Integer i = 0; i < 39; i++) {
MapHeadersValues.put(Headers1[i], Values1[i]);
}

Map<String, String> csvInfo = new Map<String, String>();
csvInfo.put('IdOfCsv', String.valueOf(MapHeadersValues.get('Id')).substring(0, (String.valueOf(MapHeadersValues.get('Id')).length() - 3)));
csvInfo.put('ParentId', String.valueOf(MapHeadersValues.get('ParentId')).substring(0, (String.valueOf(MapHeadersValues.get('ParentId')).length() - 3)));
csvInfo.put('CreatedDate', String.valueOf(MapHeadersValues.get('CreatedDate')).substring(0, (String.valueOf(MapHeadersValues.get('CreatedDate')).length() - 3)));
csvInfo.put('Subject', String.valueOf(MapHeadersValues.get('Subject')).substring(0, (String.valueOf(MapHeadersValues.get('Subject')).length() - 3)));
csvInfo.put('FromAddress', String.valueOf(MapHeadersValues.get('FromAddress')).substring(0, (String.valueOf(MapHeadersValues.get('FromAddress')).length() - 3)));
csvInfo.put('ToAddress', String.valueOf(MapHeadersValues.get('ToAddress')).substring(0, (String.valueOf(MapHeadersValues.get('ToAddress')).length() - 3)));
csvInfo.put('MessageDate', String.valueOf(MapHeadersValues.get('MessageDate')).substring(0, (String.valueOf(MapHeadersValues.get('MessageDate')).length() - 3)));
csvInfo.put('Status', String.valueOf(MapHeadersValues.get('Status')).substring(0, (String.valueOf(MapHeadersValues.get('Status')).length() - 3)));
String status = statusCodeToText(Integer.valueOf(csvInfo.get('Status')));
csvInfo.put('Status', status);
System.debug(' =>' + csvInfo.get('Status'));
System.debug('csvInfo.put(IdOfCsv)=>' + csvInfo.get('IdOfCsv'));
System.debug('csvInfo.put(ParentId)=>' + csvInfo.get('ParentId'));
System.debug('csvInfo.put(HtmlBody)=>' + csvInfo.get('HtmlBody'));
chunkCsvInfoList.add(csvInfo);
System.debug('chunkCsvInfoList.add(csvInfo); chunkCsvInfoList===>' + chunkCsvInfoList);
System.debug('chunkCsvInfoList.add(csvInfo); chunkCsvInfoList size===>' + chunkCsvInfoList.size());
}

csvInfoList.addAll(chunkCsvInfoList);
System.debug('csvInfoList.addAll(chunkCsvInfoList); csvInfoList===>' + csvInfoList);
System.debug('csvInfoList.addAll(chunkCsvInfoList); csvInfoList size===>' + csvInfoList.size());
}
} catch (Exception e) {
System.debug('Catch exception: ' + e.getMessage());
}

setCsvInfoList(csvInfoList);
System.debug('Final csvInfoList List===>' + csvInfoList);
System.debug('Final csvInfoList List size===>' + csvInfoList.size());
}
*/
    
    private static void setCsvInfoList(List<Map<String, String>> csvInfoList) {
        csvInfoListStatic = csvInfoList;
        System.debug('Code is inside setCsvInfoList');
        System.debug('setCsvInfoList csvInfoList===> ' + csvInfoList);
        System.debug('setCsvInfoList csvInfoList size===> ' + csvInfoList.size());
        System.debug('setCsvInfoList csvInfoListStatic===> ' + csvInfoListStatic);
        System.debug('setCsvInfoList csvInfoListStatic size===> ' + csvInfoListStatic.size());
    }
    
    private static List<Map<String, String>> csvInfoListStatic;
    
    public static List<Map<String, String>> triggerProcessSharepointEmailIds(List<String> emailIdFromSp, String caseParentId) {
        EmailCsvBatchProcessor_V2 batch = new EmailCsvBatchProcessor_V2(emailIdFromSp, caseParentId);
        Database.executeBatch(batch);
        return getProcessedSharepointEmailIds();
    }
    
    public static List<Map<String, String>> getProcessedSharepointEmailIds() {
        //return new List<Map<String, String>>(); 
        return csvInfoListStatic != null ? csvInfoListStatic : new List<Map<String, String>>();
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