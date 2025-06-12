/*
With out generating access token using named credential
*/


public class GetCsvUsingCaseSPId_checkV7 { 
    
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
    
    public static List<Map<String, String>> fetchEmailMessagesSync(String caseParentId){
      List<String> sharepointEmailIdList = getEmailMessageSharePointIds(caseParentId);
        
        if (!sharepointEmailIdList.isEmpty()) {
            return fetchEmailMessages(sharepointEmailIdList, caseParentId);
        }
        System.debug('fetchEmailMessages(sharepointEmailIdList===> '+sharepointEmailIdList); 
        System.debug('fetchEmailMessages(caseParentId===> '+caseParentId); 
        return null;
    }
    
    private static List<Map<String, String>> fetchEmailMessages(List<String> emailIdFromSp, String caseParentId) {
        List<Map<String, String>> spInfoList = new List<Map<String, String>>();
        List<Map<String, String>> csvInfoList = new List<Map<String, String>>();
        List<String> sharepointEmailIdList = new List<String>();
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
                                spInfo.put('fileDownloadUrl', eachItem2.webUrl.substring(0, eachItem2.webUrl.length() - 9) + '/download');
                                sharepointEmailIdList.add(eachItem2.id);
                                spInfoList.add(spInfo);
                            }
                        }
                    }
                }
            }
            
            csvInfoList = EmailCsvProcessor.triggerProcessSharepointEmailIds(sharepointEmailIdList);
            
            if (!csvInfoList.isEmpty()) {
                emailMessageInfoUtil.csvInfoList = csvInfoList;
            }
            
        } catch (Exception e) {
            System.debug('Catch exception: ' + e.getMessage());
        }
        return csvInfoList;
    }
    /* 
try{

for (string spid:sharepointEmailIdList){                
sharepointid=spid;
System.debug('sharepointid ===>'+sharepointid);


String driveId2 = Label.SharepointDriveId;
HttpRequest req2 = new HttpRequest();
req2.setMethod('GET');
req2.setHeader('Accept', 'application/json;odata=verbose');
req2.setEndpoint('callout:Sharepoint/v1.0/drives/'+driveId2+'/items/' + sharepointid + '/content');
HTTPResponse res2 = new Http().send(req2);
try{
while (res2.getStatusCode() == 302) {
req2.setEndpoint(res2.getHeader('Location'));
res2 = new Http().send(req2);
}
}catch(exception o){
System.debug('Catch exception1'+o.getMessage());
}

Blob headerValue= blob.valueOf(res2.getBody());

String body = EncodingUtil.base64Encode(headerValue);

String lines = res2.getBody();
List<String>allValues=lines.split(',');            

List<String> Headers1=New List<String>();
for(Integer i=0;i<39;i++){
if(i<=37)
Headers1.add(allValues[i]);
else{
Headers1.add('HtmlBody');
}               
}
List<String>allValues1=lines.split('##  ');

List<String> Values1=new List<String>();
for(Integer i=1;i<40;i++){
Values1.add(allValues1[i]);
System.debug(allValues1[i]);               
}
Map<String,String> MapHeadersValues=new Map<String,String>();
for(Integer i=0;i<39;i++){
MapHeadersValues.put(Headers1[i],Values1[i]);                
}

Map<String, String> csvInfo = new Map<String, String>();
csvInfo.put('IdOfCsv', String.valueOf(mapHeadersValues.get('Id')).substring(0, (String.valueOf(mapHeadersValues.get('Id')).length() - 3)));
csvInfo.put('ParentId', String.valueOf(mapHeadersValues.get('ParentId')).substring(0, (String.valueOf(mapHeadersValues.get('ParentId')).length() - 3)));
csvInfo.put('CreatedDate', String.valueOf(mapHeadersValues.get('CreatedDate')).substring(0, (String.valueOf(mapHeadersValues.get('CreatedDate')).length() - 3)));
//string CreatedById = String.valueOf(mapHeadersValues.get('CreatedById')).substring(0, (String.valueOf(mapHeadersValues.get('CreatedById')).length() - 3));
//csvInfo.put('CreatedById', CreatedById);
//system.debug(' <> CreatedById '+ CreatedById );
//csvInfo.put('CreatedByUserName', getUserNameRecordbyId(CreatedById) );
//string LastModifiedById = String.valueOf(mapHeadersValues.get('LastModifiedById')).substring(0, (String.valueOf(mapHeadersValues.get('LastModifiedById')).length() - 3));
//csvInfo.put('LastModifiedByUserName', getUserNameRecordbyId(LastModifiedById) );
//csvInfo.put('TextBody', String.valueOf(mapHeadersValues.get('TextBody')).substring(0, (String.valueOf(mapHeadersValues.get('TextBody')).length() - 3)));
//csvInfo.put('Headers', String.valueOf(mapHeadersValues.get('Headers')).substring(0, (String.valueOf(mapHeadersValues.get('Headers')).length() - 3)));
csvInfo.put('Subject', String.valueOf(mapHeadersValues.get('Subject')).substring(0, (String.valueOf(mapHeadersValues.get('Subject')).length() - 3)));
csvInfo.put('FromAddress', String.valueOf(mapHeadersValues.get('FromAddress')).substring(0, (String.valueOf(mapHeadersValues.get('FromAddress')).length() - 3)));
csvInfo.put('ToAddress', String.valueOf(mapHeadersValues.get('ToAddress')).substring(0, (String.valueOf(mapHeadersValues.get('ToAddress')).length() - 3)));
//csvInfo.put('CcAddress', String.valueOf(mapHeadersValues.get('CcAddress')).substring(0, (String.valueOf(mapHeadersValues.get('CcAddress')).length() - 3)));
//csvInfo.put('BccAddress', String.valueOf(mapHeadersValues.get('BccAddress')).substring(0, (String.valueOf(mapHeadersValues.get('BccAddress')).length() - 3)));
csvInfo.put('MessageDate', String.valueOf(mapHeadersValues.get('MessageDate')).substring(0, (String.valueOf(mapHeadersValues.get('MessageDate')).length() - 3)));
//csvInfo.put('HtmlBody', String.valueOf(mapHeadersValues.get('HtmlBody')).substring(0, (String.valueOf(mapHeadersValues.get('HtmlBody')).length() - 3)));
csvInfo.put('Status', String.valueOf(mapHeadersValues.get('Status')).substring(0, (String.valueOf(mapHeadersValues.get('Status')).length() - 3)));   
string status = statusCodeToText(integer.valueOf(csvInfo.get('Status')));
system.debug('string status ==>'  +status);
csvInfo.put('Status', status);
system.debug('csvInfo.put(Status)=>' + csvInfo.get('Status'));
system.debug('csvInfo.put(IdOfCsv)=>'   +csvInfo.get('IdOfCsv'));
system.debug('csvInfo.put(ParentId)=>'   +csvInfo.get('ParentId'));
system.debug('csvInfo.put(HtmlBody)=>'   +csvInfo.get('HtmlBody'));
csvInfoList.add(csvInfo);            }
}catch(exception e){
System.debug('Catch exception'+e.getMessage());
}
return csvInfoList;*/
    
    
    public static List<Map<String, String>> getCsvInfoList() {
        return emailMessageInfoUtil.csvInfoList;
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
            //this.accessToken = accessToken;
            this.caseParentId = caseParentId;
            this.emailMessageInfoUtil = emailMessageInfoUtil;
        }
        
        public void execute(QueueableContext context) {
            List<Map<String, String>> csvInfoList = GetCsvUsingCaseSPId_checkV7.fetchEmailMessages(emailIdFromSp, caseParentId);
            emailMessageInfoUtil.csvInfoList.addAll(csvInfoList);
            
            System.debug('FetchEmailMessagesQueueable List<Map<String, String>> csvInfoList ===> ' + csvInfoList);
            System.debug('FetchEmailMessagesQueueable List<Map<String, String>> csvInfoList ===> ' + csvInfoList.size());
            System.debug('FetchEmailMessagesQueueable emailMessageInfoUtil.csvInfoList.addAll(csvInfoList) ===> ' + emailMessageInfoUtil.csvInfoList);
            System.debug('FetchEmailMessagesQueueable emailMessageInfoUtil.csvInfoList.addAll(csvInfoList) ===> ' + emailMessageInfoUtil.csvInfoList.size());
        }
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