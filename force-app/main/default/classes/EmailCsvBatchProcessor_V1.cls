public class EmailCsvBatchProcessor_V1 implements Database.Batchable<String>, Database.AllowsCallouts {
    private List<String> sharepointEmailIdList;
    
    public EmailCsvBatchProcessor_V1(List<String> sharepointEmailIdList) {
        this.sharepointEmailIdList = sharepointEmailIdList;
    }
    
    public Iterable<String> start(Database.BatchableContext context) {
        return sharepointEmailIdList;
    }
    public void execute(Database.BatchableContext context, List<String> scope) {
         System.enqueueJob(new EmailCsvQueueable(scope));
    }
    
    public void finish(Database.BatchableContext context) {
        System.debug('#########Batch is completed');
    }
    
    public class EmailCsvQueueable implements Queueable {
        private List<String> sharepointEmailIdList;
        
        public EmailCsvQueueable(List<String> sharepointEmailIdList) {
            this.sharepointEmailIdList = sharepointEmailIdList;
        }
        
        public void execute(QueueableContext context) {
            EmailCsvBatchProcessor_V1.processSharepointEmailIds(sharepointEmailIdList);
        }
    }
    
    @future(Callout=true)
    public static void processSharepointEmailIds(List<String> sharepointEmailIdList) {
        List<Map<String, String>> csvInfoList = new List<Map<String, String>>();
        try {
            Integer chunkSize = 15;
            System.debug('Integer chunkSize----> ' + chunkSize);
            Integer totalRecords = sharepointEmailIdList.size();
            System.debug('Integer totalRecords----> ' + totalRecords);
            
            for (Integer chunkStart = 0; chunkStart < totalRecords; chunkStart += chunkSize) {
                System.debug('Integer chunkStart----> ' + chunkStart);
                Integer chunkEnd = Math.min(chunkStart + chunkSize, totalRecords);
                System.debug('Integer chunkEnd----> ' + chunkEnd);
                List<String> chunk = new List<String>();
                
                
                for (Integer i = chunkStart; i < chunkEnd; i++) {
                    chunk.add(sharepointEmailIdList[i]);
                    
                }
                System.debug('List<String> chunk------> ' + chunk);
                System.debug('List<String> chunk SIZE------> ' + chunk.size());
                
                List<Map<String, String>> chunkCsvInfoList = new List<Map<String, String>>();
                System.debug('List<Map<String, String>> chunkCsvInfoList----> ' + chunkCsvInfoList);
                System.debug('List<Map<String, String>> chunkCsvInfoList SIZE----> ' + chunkCsvInfoList.size());
                
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
                
                            
                List<GetDataFromSharepoint__e> eventList = new List<GetDataFromSharepoint__e>();
                for (Map<String, String> csvInfo : csvInfoList) {
                    GetDataFromSharepoint__e event = new GetDataFromSharepoint__e();
                    event.Emailid__c = String.valueOf(csvInfo);
                    eventList.add(event);
                    System.debug('event.Emailid__c ==>' + event.Emailid__c);
                    System.debug('event.Emailid__c length ==>' + event.Emailid__c.length());
                    System.debug('EventUuid: ' + event.EventUuid);                    
                }                
              
                if (!eventList.isEmpty()) {
                    List<Database.SaveResult> result = EventBus.publish(eventList);
                    System.debug('Database.SaveResult results==>' + result); 
                    
                    
                    List<Id> successIds = new List<Id>();
                    if (!eventList.isEmpty()) {
                        List<Database.SaveResult> saveResult = EventBus.publish(eventList);
                        
                        System.debug('List<Database.SaveResult> saveResult =>' + saveResult);
                        
                        for (Database.SaveResult resultnew : saveResult) {
                            if (resultnew.isSuccess()) {
                                successIds.add(resultnew.getId());
                                System.debug('List<Id> successIds==>' + successIds);
                                System.debug('successIds.add(resultnew.getId())==>' + resultnew.getId());
                            } else {
                                for (Database.Error error : resultnew.getErrors()) {
                                    System.debug('Error message: ' + error.getMessage());
                                    System.debug('Status code: ' + error.getStatusCode());
                                }
                            }
                        }
                    }
                    eventList.clear();
                }
            }
            
            
        } catch (Exception e) {
            System.debug('Catch exception: ' + e.getMessage());
        }
        
        
        setCsvInfoList(csvInfoList);
        System.debug('Final csvInfoList List===>' + csvInfoList);
        System.debug('Final csvInfoList List size===>' + csvInfoList.size()); 
        
    }
    private static void setCsvInfoList(List<Map<String, String>> csvInfoList) {
        csvInfoListStatic = csvInfoList;
        System.debug('Code is inside setCsvInfoList');
        System.debug('setCsvInfoList csvInfoList===> ' + csvInfoList);
        System.debug('setCsvInfoList csvInfoList size===> ' + csvInfoList.size());
        System.debug('setCsvInfoList csvInfoListStatic===> ' + csvInfoListStatic);
        System.debug('setCsvInfoList csvInfoListStatic size===> ' + csvInfoListStatic.size());
    }
    
    private static List<Map<String, String>> csvInfoListStatic;
    public static List<String> chunk;
    public static List<Map<String, String>> triggerProcessSharepointEmailIds(List<String> sharepointEmailIdList) {
        EmailCsvBatchProcessor_V1 batch = new EmailCsvBatchProcessor_V1(sharepointEmailIdList);
        Database.executeBatch(batch);
        return getProcessedSharepointEmailIds();
    }
    
    public static List<Map<String, String>> getProcessedSharepointEmailIds() {
        //return new List<Map<String, String>>(); 
        return csvInfoListStatic != null ? csvInfoListStatic : new List<Map<String, String>>();
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



/*public class EmailCsvProcessor implements Queueable {
private List<String> sharepointEmailIdList;

public EmailCsvProcessor(List<String> sharepointEmailIdList) {
this.sharepointEmailIdList = sharepointEmailIdList;
}

public void execute(QueueableContext context) {
processSharepointEmailIdsAsync(sharepointEmailIdList);
//List<Map<String, String>> csvInfoList = system.enqueJob(EmailCsvProcessor.EmailCsvProcessor(sharepointEmailIdList));

}


@future(callout=true)
public static void processSharepointEmailIdsAsync(List<String> sharepointEmailIdList) {
List<Map<String, String>> csvInfoList = new List<Map<String, String>>();
try {
Integer chunkSize = 15;
System.debug('Integer chunkSize  ===>' + chunkSize);
Integer totalRecords = sharepointEmailIdList.size();
System.debug('Integer totalRecords  ===>' + totalRecords);

for (Integer chunkStart = 0; chunkStart < totalRecords; chunkStart += chunkSize) {
System.debug('Integer chunkStart  ===>' + chunkStart);
Integer chunkEnd = Math.min(chunkStart + chunkSize, totalRecords);
System.debug('Integer chunkEnd  ===>' + chunkEnd);
List<String> chunk = new List<String>();
System.debug('List<String> chunk  ===>' + chunk);
System.debug('List<String> chunk size  ===>' + chunk.size());

for (Integer i = chunkStart; i < chunkEnd; i++) {
chunk.add(sharepointEmailIdList[i]);
System.debug('List<String> chunk  ===>' + chunk);
System.debug('List<String> chunk size  ===>' + chunk.size());
}

List<Map<String, String>> chunkCsvInfoList = new List<Map<String, String>>();

for (String spid : chunk) {
String sharepointid = spid;
System.debug('sharepointid ===>' + sharepointid);

String driveId2 = Label.SharepointDriveId;
HttpRequest req2 = new HttpRequest();
req2.setMethod('GET');
req2.setHeader('Accept', 'application/json;odata=verbose');
req2.setEndpoint('callout:Sharepoint/v1.0/drives/' + driveId2 + '/items/' + sharepointid + '/content');
HTTPResponse res2 = new Http().send(req2);

try {
while (res2.getStatusCode() == 302) {
req2.setEndpoint(res2.getHeader('Location'));
res2 = new Http().send(req2);
}
} catch (Exception o) {
System.debug('Catch exception1: ' + o.getMessage());
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
System.debug(allValues1[i]);
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
System.debug('string status ==>' + status);
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
System.debug('Final csvInfoList List===>' + csvInfoList);
System.debug('Final csvInfoList List size===>' + csvInfoList.size());
setCsvInfoList(csvInfoList);
}

private static void setCsvInfoList(List<Map<String, String>> csvInfoList) {
csvInfoListStatic = csvInfoList;
System.debug('Code is inside setCsvInfoList');
System.debug('setCsvInfoList csvInfoList===> ' + csvInfoList);
System.debug('setCsvInfoList csvInfoList size===> ' + csvInfoList.size());
System.debug('setCsvInfoList csvInfoListStatic===> ' + csvInfoListStatic);
System.debug('setCsvInfoList csvInfoListStatic size===> ' + csvInfoListStatic.size());
}
private static List<Map<String, String>> csvInfoListStatic;

public static List<Map<String, String>> triggerProcessSharepointEmailIds(List<String> sharepointEmailIdList) {
System.debug(' triggerProcessSharepointEmailIds(List<String> sharepointEmailIdList)==> ' + sharepointEmailIdList);
System.debug(' triggerProcessSharepointEmailIds(List<String> sharepointEmailIdList) size==> ' + sharepointEmailIdList.size());
EmailCsvProcessor job = new EmailCsvProcessor(sharepointEmailIdList);
Id jobId = System.enqueueJob(job);
System.debug('Id jobId===> ' + jobId);
return getProcessedSharepointEmailIds();
}

public static List<Map<String, String>> getProcessedSharepointEmailIds() {
//return new List<Map<String, String>>(); 
return csvInfoListStatic != null ? csvInfoListStatic : new List<Map<String, String>>();
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
*/