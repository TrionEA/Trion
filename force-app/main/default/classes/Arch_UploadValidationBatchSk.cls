global class Arch_UploadValidationBatchSk implements Database.Batchable<SObject> {
    integer n=3;
    //Datetime startDate = Datetime.valueOf(Label.StartDate);
    //Datetime endDate = Datetime.valueOf(Label.EndDate);
    //string idi = '500G000000NLquZIAT'; 
    //string idi = '500VE000007aR46YAE';//500G000000NwvR2IAJ 163
    string idi = '500VE00000B65xxYAB'; //500VE00000AuTCrYAN 117 files & attachments
    global Database.QueryLocator start(Database.BatchableContext BC) {
       //String query = 'SELECT Id, Status FROM Case WHERE Status = \'Closed\' AND ClosedDate < LAST_N_DAYS:90 AND Id =: idi';
     /*String query = 'SELECT Id, Status FROM Case WHERE Status = \'Closed\' ' + 
                       'AND ClosedDate < LAST_N_DAYS:90 ' +
                       'AND CreatedDate > ' + startDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + 
                       ' AND CreatedDate < ' + endDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); */
        //String query = 'Select id, ParentId from EmailMessage where ParentId=:idi AND Parent.Status = \'Closed\' ' + 
        //               'AND Parent.ClosedDate < LAST_N_DAYS:90 ' ;
        //String query = 'Select id, ParentId from EmailMessage where ParentId=:idi AND Parent.Status = \'Closed\' ' ;
        String query = 'Select id, ParentId from EmailMessage where Parent.ClosedDate  >= LAST_N_DAYS:'+n;
        System.debug('Batch Query: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<EmailMessage> emailMessages) {
        set<ID> caseIdSet = new set<Id>();
        integer localcount = 0;
        system.debug('emailMessages----------->'+emailMessages);
        Map<Id,integer> mapofIdAttachmentCount = new Map<Id, Integer>();
        for(EmailMessage e : emailMessages){
            //caseIdSet.add(e.ParentId);
            caseIdSet.add(e.id);
        }
        List<Attachment> attList = [select Id, ParentId, Name, BodyLength from Attachment where ParentId IN: caseIdSet
                                    order by createddate asc];
        //List<ContentDocumentLink> cdlList = [select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId IN: caseIdSet and ContentDocument.CreatedDate = LAST_N_DAYS:10 ];
        List<ContentDocumentLink> cdlList = [select Id, ContentDocumentId, LinkedEntityId, ContentDocument.ContentSize from ContentDocumentLink where LinkedEntityId IN: caseIdSet AND ContentDocument.ContentSize <12000000 ];
        system.debug('attList----------->'+attList);
            system.debug('cdlList----------->'+cdlList);
        if(!attList.isEmpty()){
            for(Attachment att : attList){
            if(!mapofIdAttachmentCount.keySet().contains(att.ParentId)){
                localcount = 1;
            }
            else{
                ++localcount;
            }
            mapofIdAttachmentCount.put(att.ParentId,localcount); //map of case Id and attachment and Content document records
        }
        }
        if(!cdlList.isEmpty()){
            for(ContentDocumentLink cdl : cdlList ){
            if(!mapofIdAttachmentCount.keySet().contains(cdl.LinkedEntityId)){
                localcount = 1;
            }
            else{
                ++localcount;
            }
            mapofIdAttachmentCount.put(cdl.LinkedEntityId,localcount); //map of case Id and attachment and Content document records
        }
        }
        system.debug('mapofIdAttachmentCount----------->'+mapofIdAttachmentCount);
        for(EmailMessage em :emailMessages){
            system.debug('em ID----------->'+em.Id);
            system.debug('em Parent Id----------->'+em.ParentId);
            //system.debug('mapofIdAttachmentCount.get(em.ParentId)----------->'+mapofIdAttachmentCount.get(em.ParentId));
            system.debug('mapofIdAttachmentCount.get(em.ParentId)----------->'+mapofIdAttachmentCount.get(em.id));
            //ID jobId = System.enqueueJob(new SharePointCountMatchQueueable(em.ParentId,em.Id,mapofIdAttachmentCount.get(em.ParentId)));
            ID jobId = System.enqueueJob(new Arch_SharePointCountMatchQueue(em.ParentId,em.Id,mapofIdAttachmentCount.get(em.id)));
            system.debug('jobId----->'+jobId);
        }
        
        
        
    }
    global void finish(Database.BatchableContext BC) {
        
    }
       
}