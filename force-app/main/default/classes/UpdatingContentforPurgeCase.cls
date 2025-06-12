global class UpdatingContentforPurgeCase implements Database.Batchable<SObject>, Database.Stateful {
    
    global List<Stagging__c> stagingList;
    
    // Constructor
    global UpdatingContentforPurgeCase(List<Stagging__c> stagingList) {
        this.stagingList = stagingList;
    }
    
    // Start method
    global List<Stagging__c> start(Database.BatchableContext BC) {
        return stagingList;
           
    }
    
    // Execute method
    global void execute(Database.BatchableContext BC, List<Stagging__c> scope) {
        /*List<Stagging__c> staggingRecordssuccess = new List<Stagging__c>();
        List<Stagging__c> staggingRecordsFailure = new List<Stagging__c>();

        for (Stagging__c s : scope) {
            if (s.Status__c == 'Completed') {
                staggingRecordssuccess.add(s);
            } else if (s.Status__c == 'Failed') {
                staggingRecordsFailure.add(s);
            }
        }

        Map<String, List<String>> contentDocumentMapSuccess = new Map<String, List<String>>();
        Map<String, List<String>> contentDocumentMapFailure = new Map<String, List<String>>();
        Map<String, String> mapConIdwithError = new Map<String, String>();

        for (Stagging__c s : staggingRecordssuccess) {
            if (!contentDocumentMapSuccess.containsKey(s.Linked_Entity_Id__c)) {
                contentDocumentMapSuccess.put(s.Linked_Entity_Id__c, new List<String>{s.Content_Document_Id__c});
            } else {
                contentDocumentMapSuccess.get(s.Linked_Entity_Id__c).add(s.Content_Document_Id__c);
            }
        }

        for (Stagging__c s : staggingRecordsFailure) {
            mapConIdwithError.put(s.Content_Document_Id__c, s.Error_Message__c);
            if (!contentDocumentMapFailure.containsKey(s.Linked_Entity_Id__c)) {
                contentDocumentMapFailure.put(s.Linked_Entity_Id__c, new List<String>{s.Content_Document_Id__c});
            } else {
                contentDocumentMapFailure.get(s.Linked_Entity_Id__c).add(s.Content_Document_Id__c);
            }
        }

        List<Purge_Case__c> purgeCases = [SELECT Id, EmailMessage_Id__c, Case_Id__c, Failed_Content_Doc_Ids__c, Failed_Ids_and_corresponding_error__c
                                          FROM Purge_Case__c 
                                          WHERE Status__c = 'Ready to Purge'];

        Map<String, List<String>> mapCaseWithContIdSuccess = new Map<String, List<String>>();
        Map<String, List<String>> mapCaseWithContIdFailure = new Map<String, List<String>>();

        for (Purge_Case__c p : purgeCases) {
            List<String> contentDocId = new List<String>();
            List<String> contentDocIdsFailure = new List<String>();

            if (p.EmailMessage_Id__c != null) {
                for (String emId : p.EmailMessage_Id__c.split(',\n')) {
                    if (contentDocumentMapSuccess.containsKey(emId)) {
                        contentDocId.addAll(contentDocumentMapSuccess.get(emId));
                    }
                    if (contentDocumentMapFailure.containsKey(emId)) {
                        contentDocIdsFailure.addAll(contentDocumentMapFailure.get(emId));
                    }
                }
            }

            if (!mapCaseWithContIdSuccess.containsKey(p.Case_Id__c)) {
                mapCaseWithContIdSuccess.put(p.Case_Id__c, contentDocId);
            } else {
                mapCaseWithContIdSuccess.get(p.Case_Id__c).addAll(contentDocId);
            }

            if (!mapCaseWithContIdFailure.containsKey(p.Case_Id__c)) {
                mapCaseWithContIdFailure.put(p.Case_Id__c, contentDocIdsFailure);
            } else {
                mapCaseWithContIdFailure.get(p.Case_Id__c).addAll(contentDocIdsFailure);
            }
        }

        for (Purge_Case__c p : purgeCases) {
            if (!mapCaseWithContIdFailure.get(p.Case_Id__c).isEmpty()) {
                p.Status__c = 'Failed';
                String failedIds = String.join(mapCaseWithContIdFailure.get(p.Case_Id__c), ', ');
                p.Failed_Ids_and_corresponding_error__c = failedIds;
            } else if (!mapCaseWithContIdSuccess.get(p.Case_Id__c).isEmpty()) {
                p.Status__c = 'Success';
            } else {
                p.Status__c = 'Failed';
            }
        }

        update purgeCases;*/
    }
    
    // Finish method
    global void finish(Database.BatchableContext BC) {}
}

/*global class UpdatingPurgCaseComplete implements Database.Batchable<SObject>, Database.Stateful {

global List<EmailMessageHtml__c> listEmailHtmls;
global UpdatingPurgCaseComplete(List<EmailMessageHtml__c> listEmailHtmls){
this.listEmailHtmls=listEmailHtmls;
}
global List<EmailMessageHtml__c> start(Database.BatchableContext BC) {

return listEmailHtmls;
}


global void execute(Database.BatchableContext BC, List<EmailMessageHtml__c> scope) {
List<String>emIds=new List<String>();
Map<String,List<String>> MapingCaseIdWithEmailId=new Map<String,List<String>>();
Map<String,String> mappingEmailIdWithError=new Map<String,String>();
for(EmailMessageHtml__c emHtmlRec:scope){

emIds.add(emHtmlRec.EmailMessage_Id__c);

if (MapingCaseIdWithEmailId.containsKey(emHtmlRec.Parent_Case_Id__c)) {
List<String>emailIds = MapingCaseIdWithEmailId.get(emHtmlRec.Parent_Case_Id__c);
emailIds.add(emHtmlRec.EmailMessage_Id__c);
MapingCaseIdWithEmailId.put(emHtmlRec.Parent_Case_Id__c, emailIds);
MapingCaseIdWithEmailId.get(emHtmlRec.Parent_Case_Id__c).add(emHtmlRec.EmailMessage_Id__c);
} 
else 
{ 
MapingCaseIdWithEmailId.put(emHtmlRec.Parent_Case_Id__c, new List<String>{emHtmlRec.EmailMessage_Id__c});  
}
if(emHtmlRec.Error_Message__c!=null){
mappingEmailIdWithError.put(emHtmlRec.EmailMessage_Id__c,emHtmlRec.Error_Message__c);
}
} 
Map<String,List<String>> MapingCaseIdWithEmailIdSuccess=new Map<String,List<String>>();
for(EmailMessageHtml__c emHtSucc:scope){
if(emHtSucc.Status__c=='Completed'){
if (MapingCaseIdWithEmailIdSuccess.containsKey(emHtSucc.Parent_Case_Id__c)) {
List<String>emailIds = MapingCaseIdWithEmailIdSuccess.get(emHtSucc.Parent_Case_Id__c);
emailIds.add(emHtSucc.EmailMessage_Id__c);
MapingCaseIdWithEmailIdSuccess.put(emHtSucc.Parent_Case_Id__c, emailIds);
} 
else 
{
List<String> emailIds = new List<String>();
emailIds.add(emHtSucc.EmailMessage_Id__c);  
MapingCaseIdWithEmailIdSuccess.put(emHtSucc.Parent_Case_Id__c, emailIds);  
}
}
}
System.debug('Mapiing case to emaids which are success'+MapingCaseIdWithEmailIdSuccess);
Map<String,List<String>> MapingCaseIdWithEmailIdFailed=new Map<String,List<String>>();
for(EmailMessageHtml__c emHtFail:scope){
if(emHtFail.Status__c=='Failed'){
if (MapingCaseIdWithEmailIdFailed.containsKey(emHtFail.Parent_Case_Id__c)) {
List<String>emailIds = MapingCaseIdWithEmailIdFailed.get(emHtFail.Parent_Case_Id__c);
emailIds.add(emHtFail.EmailMessage_Id__c);
MapingCaseIdWithEmailIdFailed.put(emHtFail.Parent_Case_Id__c, emailIds);
} 
else 
{
List<String> emailIds = new List<String>();
emailIds.add(emHtFail.EmailMessage_Id__c);  
MapingCaseIdWithEmailIdFailed.put(emHtFail.Parent_Case_Id__c, emailIds);  
}
}
}

System.debug('Mapiing case to emaids which are Failure'+MapingCaseIdWithEmailIdFailed);

Set<String>caseIds=MapingCaseIdWithEmailId.keySet();


List<Stagging__c> staggingRecordsFailure=[Select Id,Content_Document_Id__c, Content_Size__c, Error_Message__c, From_sObject__c, Is_Large_File__c, Job_ID__c, Linked_Entity_Id__c, sObject__c, Status__c, Status_Code__c, Title__c, tmp__c, Upload_Failed__c, Retry_Executed_Count__c from Stagging__c where Linked_Entity_Id__c In :emIds and Status__c='Failed'];
List<Stagging__c> staggingRecordssuccess=[Select Id,Content_Document_Id__c, Content_Size__c, Error_Message__c, From_sObject__c, Is_Large_File__c, Job_ID__c, Linked_Entity_Id__c, sObject__c, Status__c, Status_Code__c, Title__c, tmp__c, Upload_Failed__c, Retry_Executed_Count__c from Stagging__c where Linked_Entity_Id__c In :emIds and Status__c='Completed'];
System.debug('Failed staging are :'+staggingRecordsFailure);
System.debug('Success Documents are :'+staggingRecordssuccess);
Map<String, List<String>> contentDocumentMapSuccess = new Map<String, List<String>>();
for (Stagging__c s : staggingRecordssuccess) {

if (!contentDocumentMapSuccess.containsKey(s.Linked_Entity_Id__c)) {
contentDocumentMapSuccess.put(s.Linked_Entity_Id__c, new List<String>());
}
contentDocumentMapSuccess.get(s.Linked_Entity_Id__c).add(s.Content_Document_Id__c);

}
System.debug('Mapping linked entity id to contentdocid which are success:'+contentDocumentMapSuccess);
List<Purge_Case__c> purgeCases = [SELECT Id, EmailMessage_Id__c, Case_Id__c, ContentDocument_Id__c,Failed_Ids_and_corresponding_error__c
FROM Purge_Case__c 
WHERE Status__c = 'Ready to Purge' and Case_Id__c In: caseIds ];
Map<String,List<String>>mapCaseWithContIdSuccess=new Map<String,List<String>>();
for(Purge_Case__c p: purgeCases){
List<String>emailIds=p.EmailMessage_Id__c.split(',\n');

List<String> contentDocIds = new List<String>();
for (String emId : emailIds) {

if (contentDocumentMapSuccess.containsKey(emId)) {

List<String> docs = contentDocumentMapSuccess.get(emId);


contentDocIds.addAll(docs);
}
}


if (!mapCaseWithContIdSuccess.containsKey(p.Case_Id__c)) {
mapCaseWithContIdSuccess.put(p.Case_Id__c, new List<String>());
}
mapCaseWithContIdSuccess.get(p.Case_Id__c).addAll(contentDocIds);
}
System.debug('Mapping case with conte success'+mapCaseWithContIdSuccess);
Map<String, List<String>> contentDocumentMapFailure = new Map<String, List<String>>();
Map<String,String>mapConIdwithError=new Map<String,String>();
for (Stagging__c s : staggingRecordsFailure) {
mapConIdwithError.put(s.Content_Document_Id__c,s.Error_Message__c);
if (!contentDocumentMapFailure.containsKey(s.Linked_Entity_Id__c)) {
contentDocumentMapFailure.put(s.Linked_Entity_Id__c, new List<String>());
}
contentDocumentMapFailure.get(s.Linked_Entity_Id__c).add(s.Content_Document_Id__c);

}
System.debug('Mapping linked entity id with conId Failure:'+contentDocumentMapFailure);
Map<String,List<String>>mapCaseWithContIdFailure=new Map<String,List<String>>();
for(Purge_Case__c p: purgeCases){
List<String>emailIds=p.EmailMessage_Id__c.split(',\n');

List<String> contentDocIds = new List<String>();
for (String emId : emailIds) {

if (contentDocumentMapFailure.containsKey(emId)) {

List<String> docs = contentDocumentMapFailure.get(emId);


contentDocIds.addAll(docs);
}
}


if (!mapCaseWithContIdFailure.containsKey(p.Case_Id__c)) {
mapCaseWithContIdFailure.put(p.Case_Id__c, new List<String>());
}
mapCaseWithContIdFailure.get(p.Case_Id__c).addAll(contentDocIds);
}
System.debug('Mapping case with conte Faile'+mapCaseWithContIdFailure);
List<Purge_Case__c>purgeCasesToUpdateToSuccess=new List<Purge_Case__c>();
List<Purge_Case__c>purgeCasesToUpdateToFailure=new List<Purge_Case__c>();

for(Purge_Case__c p: purgeCases){

List<String>emailIds=p.EmailMessage_Id__c.split(',\n');
List<String>emailIdsAfterUpdate=MapingCaseIdWithEmailIdSuccess.get(p.Case_Id__c);
List<String>contentDocIds=p.ContentDocument_Id__c.split(',');
List<String>contentDocIdsUpdate=mapCaseWithContIdSuccess.get(p.Case_Id__c);
if((emailIds.size() == emailIdsAfterUpdate.size()) && (contentDocIds.size() == contentDocIdsUpdate.size())){
p.Status__c='Success';
purgeCasesToUpdateToSuccess.add(p);
}
if(emailIds.size() != emailIdsAfterUpdate.size()){

List<String>failedEmailsIds=MapingCaseIdWithEmailIdFailed.get(p.Case_Id__c);
String err = '';  
for (String emId : failedEmailsIds) {
String errorMsg = mappingEmailIdWithError.get(emId);
err += emId + '=>' + errorMsg + ', ';
}
p.Status__c='Failed';
p.Failed_Ids_and_corresponding_error__c=err;
purgeCasesToUpdateToFailure.add(p);
}

}
Update purgeCasesToUpdateToSuccess;
Update purgeCasesToUpdateToFailure;
}


global void finish(Database.BatchableContext BC) {

}
}*/