global class UpdatingPurgeCaseContent implements Database.Batchable<SObject>, Database.Stateful {
    
    global List<Stagging__c>stagingList;
    
    global UpdatingPurgeCaseContent(List<Stagging__c> stagingList){
        this.stagingList=stagingList;
    }
    
    global List<Stagging__c> start(Database.BatchableContext BC) {
        return stagingList;
    }
    
    
    global void execute(Database.BatchableContext BC,List<Stagging__c> scope) {
       /* List<Stagging__c> staggingRecordssuccess=new List<Stagging__c>();
        List<Stagging__c> staggingRecordsFailure=new List<Stagging__c>();
        for(Stagging__c s:scope){
            if(s.Status__c=='Completed'){
                staggingRecordssuccess.add(s);
            }
            if(s.Status__c=='Failed'){
                staggingRecordsFailure.add(s);
            }
        }
        Map<String, List<String>> contentDocumentMapSuccess = new Map<String, List<String>>();
        Map<String, List<String>> contentDocumentMapFailure = new Map<String, List<String>>();
        Map<String, List<String>> attachmentMapSuccess = new Map<String, List<String>>();
        Map<String, List<String>> attachmentMapFailure = new Map<String, List<String>>();        
        for (Stagging__c s : staggingRecordssuccess) {
            if (!contentDocumentMapSuccess.containsKey(s.Linked_Entity_Id__c)) {
                contentDocumentMapSuccess.put(s.Linked_Entity_Id__c, new List<String>{s.Content_Document_Id__c});
            }else{
                contentDocumentMapSuccess.get(s.Linked_Entity_Id__c).add(s.Content_Document_Id__c);
            }
            if(s.From_sObject__c=='Attachment'){
                if (!attachmentMapSuccess.containsKey(s.Linked_Entity_Id__c)) {
                    attachmentMapSuccess.put(s.Linked_Entity_Id__c, new List<String>{s.Chunk__c});
                }else{
                    contentDocumentMapSuccess.get(s.Linked_Entity_Id__c).add(s.Chunk__c);
                }
            }
        }
        
        Map<String,String>mapConIdwithError=new Map<String,String>();
        Map<String,String>mapAttachwithError=new Map<String,String>();
        for (Stagging__c s : staggingRecordsFailure) {
            mapConIdwithError.put(s.Content_Document_Id__c,s.Error_Message__c);
            if (!contentDocumentMapFailure.containsKey(s.Linked_Entity_Id__c)) {
                contentDocumentMapFailure.put(s.Linked_Entity_Id__c, new List<String>{s.Content_Document_Id__c});
            }else{
                contentDocumentMapFailure.get(s.Linked_Entity_Id__c).add(s.Content_Document_Id__c);
            }
            if(s.From_sObject__c=='Attachment'){
                mapAttachwithError.put(s.Chunk__c,s.Error_Message__c);
                if (!attachmentMapFailure.containsKey(s.Linked_Entity_Id__c)) {
                    attachmentMapFailure.put(s.Linked_Entity_Id__c, new List<String>{s.Chunk__c});
                }else{
                    attachmentMapFailure.get(s.Linked_Entity_Id__c).add(s.Chunk__c);
                }
                
            }
            List<Purge_Case__c> purgeCases = [SELECT Id, EmailMessage_Id__c,Failed_Attachment_And_Erorr__c,Attachment_Ids__c,ContentDocument_Id__c, Case_Id__c, 	Failed_Content_Doc_Ids__c,Failed_Ids_and_corresponding_error__c
                                              FROM Purge_Case__c 
                                              WHERE Status__c = 'Ready to Upload'];
            
            Map<String,List<String>>mapCaseWithContIdSuccess=new Map<String,List<String>>();
            Map<String,List<String>>mapCaseWithContIdFailure=new Map<String,List<String>>();
            Map<String,List<String>>mapCaseWithAttachmentSuccess=new Map<String,List<String>>(); 
            Map<String,List<String>>mapCaseWithAttachmentFailure=new Map<String,List<String>>();
            for(Purge_Case__c p: purgeCases){
                
                if(p.EmailMessage_Id__c != null){
                    //Adding  success conIds to new List
                    List<String> contentDocId = new List<String>();
                    List<String> attachId=new List<String>();
                    for (String emId : p.EmailMessage_Id__c.split(',\n')) {
                        if (contentDocumentMapSuccess.containsKey(emId)) {
                            List<String> docs = contentDocumentMapSuccess.get(emId);
                            contentDocId.addAll(docs);
                        }
                        if(attachmentMapSuccess.containsKey(emId)){
                            list<string> attachs=attachmentMapSuccess.get(emId);
                            attachs.addAll(attachs);
                        }
                        
                    }
                    if (!mapCaseWithContIdSuccess.containsKey(p.Case_Id__c)) {
                        mapCaseWithContIdSuccess.put(p.Case_Id__c, contentDocId);
                    }else{
                        mapCaseWithContIdSuccess.get(p.Case_Id__c).addAll(contentDocId);
                    }
                    if (!mapCaseWithAttachmentSuccess.containsKey(p.Case_Id__c)) {
                        mapCaseWithAttachmentSuccess.put(p.Case_Id__c, attachId);
                    }else{
                        mapCaseWithAttachmentSuccess.get(p.Case_Id__c).addAll(attachId);
                    }                
                }
                List<String> contentDocIds = new List<String>();
                List<String> attachIdS = new List<String>();
                if(p.EmailMessage_Id__c !=null){
                    for (String emId : p.EmailMessage_Id__c.split(',\n')) {
                        if (contentDocumentMapFailure.containsKey(emId)) {
                            List<String> docs = contentDocumentMapFailure.containskey(emId) ? contentDocumentMapFailure.get(emId) : new List<String>();
                            contentDocIds.addAll(docs);
                        }
                        if (attachmentMapFailure.containsKey(emId)) {
                            List<String> docs = attachmentMapFailure.containskey(emId) ? attachmentMapFailure.get(emId) : new List<String>();
                            attachIdS.addAll(docs);
                        }                       
                    }
                    if (!mapCaseWithContIdFailure.containsKey(p.Case_Id__c)) {
                        mapCaseWithContIdFailure.put(p.Case_Id__c, contentDocIds);
                    }else{
                        mapCaseWithContIdFailure.get(p.Case_Id__c).addAll(contentDocIds);
                    }
                    If (!mapCaseWithAttachmentFailure.containsKey(p.Case_Id__c)) {
                        mapCaseWithAttachmentFailure.put(p.Case_Id__c,attachIdS);
                    }else{
                        mapCaseWithAttachmentFailure.get(p.Case_Id__c).addAll(attachIdS);
                    }
                }                
            }
            List<Purge_Case__c> casesToUpdate = new List<Purge_Case__c>();
            for(Purge_Case__c p: purgeCases){
                
                List<String>contentDocIds=p.ContentDocument_Id__c.split(',');
                List<String>contentDocIdsUpdate=mapCaseWithContIdSuccess.get(p.Case_Id__c);
                List<String>attachIds=p.Attachment_Ids__c.split(',');
                List<String>attachIdsUpdate=mapCaseWithAttachmentSuccess.get(p.Case_Id__c);
                
                if ((contentDocIds.size() == contentDocIdsUpdate.size()) &&  (attachIds.size() == attachIdsUpdate.size()) && (p.Failed_Ids_and_corresponding_error__c == null || p.Failed_Ids_and_corresponding_error__c == '')){
                    p.Status__c='Ready to Purge';
                    
                }
                if (((!contentDocIds.isEmpty() && !contentDocIdsUpdate.isEmpty()) || (!attachIds.isEmpty() && !attachIdsUpdate.isEmpty()))) {
                    if(contentDocIds.size() != contentDocIdsUpdate.size() ||attachIds.size() != attachIdsUpdate.size() ){
                        
                        // Fetch the list of failed ConDoc IDs
                        List<String> failedConIds = mapCaseWithContIdFailure.get(p.Case_Id__c);
                        
                        System.debug('Failed Ids aree:'+failedConIds);
                        // Check if failedEmailsIds is null or empty
                        List<String> failedAttachIds = mapCaseWithAttachmentFailure.get(p.Case_Id__c);
                        if ((failedConIds != null && !failedConIds.isEmpty()) ||(failedAttachIds != null && !failedAttachIds.isEmpty()))  {
                            System.debug('Case id is.......:' + p.Case_Id__c);
                            System.debug('Failed ConIds are.......:' + failedConIds + ' And corresponding EmailIds is.......:' + mapCaseWithContIdFailure.get(p.Case_Id__c));
                            
                            String err = '';
                            for (String conId : failedConIds) {
                                String errorMsg = mapConIdwithError.containsKey(conId) ? mapConIdwithError.get(conId) : '';
                                err += conId;
                                
                                if (!String.isEmpty(errorMsg)) {
                                    err += ' => ' + errorMsg + ', ';
                                } else {
                                    err += ', ';
                                }
                            }
                            
                            // Update the status and error field on the Purge_Case__c record
                            p.Status__c = 'Failed';
                            p.Failed_Content_Doc_Ids__c= err;
                            for (String attachId : failedAttachIds) {
                                String errorMsg = mapAttachwithError.containsKey(attachId) ? mapAttachwithError.get(attachId) : '';
                                err += attachId;
                                
                                if (!String.isEmpty(errorMsg)) {
                                    err += ' => ' + errorMsg + ', ';
                                } else {
                                    err += ', ';
                                }
                            }
                            // Update the status and error field on the Purge_Case__c record                            
                            p.Failed_Attachment_And_Erorr__c= err;
                        }
                        casesToUpdate.add(p);
                    }                    
                }               
            }           
            if(!casesToUpdate.isEmpty()){
                Update casesToUpdate;
            }        
        }  */      
    }
   
    global void finish(Database.BatchableContext BC) {
        
    }
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