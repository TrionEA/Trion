trigger EmaiCaseTrigger on EmailMessage (after insert) {
    SYSTEM.DEBUG('tRIGGER');
    If(Trigger.isAfter && Trigger.isInsert){
        //string emId;
        SYSTEM.DEBUG('tRIGGER');
        List<EmailMessage>Listoinsert=new List<EmailMessage>();
        List<EmailMessage>LiEmUpd=NEW lIst<EmailMessage>();
        List<Case>LisInse=new List<Case>();
        for(EmailMessage e:Trigger.new){
            Case c=[select id,No_of_days__c,Closed_Date__c,Status from Case where Id=:e.ParentId];
            
            if(c.Status=='Closed' && C.No_of_days__c>2 ){
                Case cre1=new Case();
                cre1.AccountId=c.AccountId;
                cre1.ContactId=c.ContactId;
                cre1.SuppliedEmail=c.SuppliedEmail;
                cre1.Description=e.TextBody;
                cre1.Subject=e.Subject;
                cre1.OwnerId=c.OwnerId;
                LisInse.add(cre1);
                //  emId = e.Id;
                EmailMessage enew=e.clone( false, false, false, false );
                enew.ParentId=LisInse[0].id;
                system.debug(LisInse[0].id);
                Listoinsert.add(enew);
            }
            
        }
        insert Listoinsert;
        insert LisInse;
        system.debug(LisInse);
        
        /*    EmailMessage emVar =[select id, ParentId from EmailMessage where id=:emId];
emVar.ParentId=LisInse[0].id;
LiEmUpd.add(emVar);
Update LiEmUpd;*/
        
        
    }
    
}