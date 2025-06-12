global class Arch_PurgeEmail implements Database.Batchable<SObject> {
    public Datetime startDate;
    public Datetime endDate;
    String startDateLabel;
    String endDateLabel;
    global List<EmailMessage> start(Database.BatchableContext bc){ 
        this.startDateLabel = Label.startDate;
        this.endDateLabel = Label.endDate;
        this.startDate = Date.valueOf(startDateLabel);
        this.endDate = Date.valueOf(endDateLabel);
        String queryString = 'select id,Parent.ClosedDate, Subject, ParentId, CreatedDate, Parent.CaseNumber'
            				+'from EmailMessage where parent.ClosedDate >= '+startDate+' AND '
            				+'Parent.ClosedDate  <= ' +endDate+ 'and Parent.have_more_character__c =false' ;
        System.debug(queryString); 
        List<EmailMessage> emailList = (List<EmailMessage>) Database.query(queryString);
        return emailList;
                
    }
    
    global void execute(Database.BatchableContext bc, List<EmailMessage> emailList){
        delete emailList;
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}