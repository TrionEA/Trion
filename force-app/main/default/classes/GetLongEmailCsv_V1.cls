public class GetLongEmailCsv_V1 {
    
    public static void extractCsv() {
        Http httpCallout = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setTimeout(120000);
        //req.setEndpoint('callout:Sharepoint/v1.0/sites/' + Label.SharePoint_Site_Id + '/drives/' + Label.SharepointDriveId + '/items/root:/Case/500VE00000B65xxYAB/02sVE000004Mh7FYAS:/children');
        req.setEndpoint('callout:Sharepoint/v1.0/sites/' + Label.SharePoint_Site_Id + '/drives/' + Label.SharepointDriveId + '/items/root:/Case/500VE000009VsztYAC/02sVE000002wudOYAQ:/children');

        HTTPResponse res = httpCallout.send(req);
        System.debug('Res get status code====>' + res.getStatusCode());
        System.debug('Res get body====>' + res.getBody());
        
        String sharepointId = null;
        String jsonString = res.getBody();
        Response result = (Response) JSON.deserialize(jsonString, Response.class);
        
        for (Item item : result.value) {
            if (item.name.contains('EmailMessageDetails')) {
                sharepointId = item.id;
                break;
            }
        }
        
        if (sharepointId == null) {
            System.debug('No matching SharePoint item found.');
            return;
        }
        
        System.debug('SharePoint ID====>' + sharepointId);
        
        HttpRequest req2 = new HttpRequest();
        req2.setMethod('GET');
        req2.setHeader('Accept', 'application/json;odata=verbose');
        req2.setEndpoint('callout:Sharepoint/v1.0/drives/' + Label.SharepointDriveId + '/items/' + sharepointId + '/content');
        HTTPResponse res2 = new Http().send(req2);
        
        try {
            while (res2.getStatusCode() == 302) {
                req2.setEndpoint(res2.getHeader('Location'));
                res2 = new Http().send(req2);
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        
        System.debug('Res2 get status code====>' + res2.getStatusCode());
        System.debug('Res2 get body====>' + res2.getBody());
        
        String body = res2.getBody();
        List<String> allValues = body.split(',');
        System.debug('allValues====>' + System.JSON.serializePretty(allValues));
        // Ensure we have at least 39 values
        if (allValues.size() < 39) {
            System.debug('CSV data does not have enough columns.');
            return;
        }
        
        List<String> headers = new List<String>();
        for (Integer i = 0; i < 39; i++) {
            headers.add(i < 37 ? allValues[i] : 'HtmlBody');
        }
        System.debug('Headers====>' + headers);
        System.debug('Headers====>' + System.JSON.serializePretty(headers));
        List<String> values = new List<String>();
        List<String> allValuesSplit = body.split('##  ');
        
        for (Integer i = 1; i < allValuesSplit.size(); i++) {
            values.add(allValuesSplit[i]);
        }
        System.debug('All Values Split====>' + allValuesSplit);
        System.debug('Values====>' + values);
        System.debug('values====>' + System.JSON.serializePretty(values));
        System.debug('allValuesSplit====>' + System.JSON.serializePretty(allValuesSplit));
        // Ensure we have at least 39 values
        if (values.size() < 39) {
            System.debug('CSV data does not have enough values.');
            return;
        }
        
        Map<String, String> mapHeadersValues = new Map<String, String>();
        for (Integer i = 0; i < 39; i++) {
            mapHeadersValues.put(headers[i], values[i]);
        }
        System.debug('MapHeadersValues====>' + mapHeadersValues);
        System.debug('mapHeadersValues====>' + System.JSON.serializePretty(mapHeadersValues));
        Map<String, String> csvInfo = new Map<String, String>();
        csvInfo.put('IdOfCsv', trimValue(mapHeadersValues.get('Id')));
        csvInfo.put('ParentId', trimValue(mapHeadersValues.get('ParentId')));
        csvInfo.put('CreatedDate', trimValue(mapHeadersValues.get('CreatedDate')));
        String createdById = trimValue(mapHeadersValues.get('CreatedById'));
        csvInfo.put('CreatedById', createdById);
        // Uncomment if needed
        // csvInfo.put('CreatedByUserName', getUserNameRecordbyId(createdById));
        csvInfo.put('TextBody', trimValue(mapHeadersValues.get('TextBody')));
        csvInfo.put('Headers', trimValue(mapHeadersValues.get('Headers')));
        csvInfo.put('Subject', trimValue(mapHeadersValues.get('Subject')));
        csvInfo.put('FromAddress', trimValue(mapHeadersValues.get('FromAddress')));
        csvInfo.put('ToAddress', trimValue(mapHeadersValues.get('ToAddress')));
        // Uncomment if needed
        // csvInfo.put('CcAddress', trimValue(mapHeadersValues.get('CcAddress')));
        csvInfo.put('BccAddress', trimValue(mapHeadersValues.get('BccAddress')));
        csvInfo.put('MessageDate', trimValue(mapHeadersValues.get('MessageDate')));
        csvInfo.put('HtmlBody', trimValue(mapHeadersValues.get('HtmlBody')));
        csvInfo.put('Status', trimValue(mapHeadersValues.get('Status')));
        
        String status = statusCodeToText(Integer.valueOf(csvInfo.get('Status')));
        csvInfo.put('Statustext', status);
        
        
        System.debug('csvInfo.put(Status) =>' + csvInfo.get('Status'));
        System.debug('csvInfo.put(IdOfCsv)=>' + csvInfo.get('IdOfCsv'));
        System.debug('csvInfo.put(ParentId)=>' + csvInfo.get('ParentId'));
        System.debug('csvInfo.put(CreatedDate)=>' + csvInfo.get('CreatedDate'));
        System.debug('csvInfo.put(CreatedById)=>' + csvInfo.get('CreatedById'));
        //System.debug('csvInfo.put(CreatedByUserName)=>' + csvInfo.get('CreatedByUserName'));
        System.debug('csvInfo.put(TextBody)=>' + csvInfo.get('TextBody'));
        System.debug('csvInfo.put(Headers)=>' + csvInfo.get('Headers'));
        System.debug('csvInfo.put(Subject)=>' + csvInfo.get('Subject'));
        System.debug('csvInfo.put(FromAddress)=>' + csvInfo.get('FromAddress'));
        System.debug('csvInfo.put(ToAddress)=>' + csvInfo.get('ToAddress'));
        System.debug('csvInfo.put(MessageDate)=>' + csvInfo.get('MessageDate'));
        System.debug('csvInfo.put(HtmlBody)=>' + csvInfo.get('HtmlBody'));
        
        System.debug('CSV Info====>' + System.JSON.serializePretty(csvInfo));
    }
    
    private static String trimValue(String value) {
        if (value == null) {
            return '';
        }
        return value.length() > 3 ? value.substring(0, value.length() - 3) : value;
    }
    
    @AuraEnabled
    public static Case getCaseRecordbyId(String caseId) {
        try {
            return [SELECT Id, CaseNumber FROM Case WHERE Id = :caseId LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving case record: ' + e.getMessage());
        }
    }
   /* 
    public static String getUserNameRecordbyId(String userId) {
        try {
            List<User> userRecords = [SELECT Id, Name FROM User WHERE Id = :userId LIMIT 1];
            if (!userRecords.isEmpty()) {
                return userRecords[0].Name;
            } else {
                return 'Unknown User';
            }
        } catch (Exception e) {
            return 'Unknown User';
        }
    }
    */
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
        public String mimeType;
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