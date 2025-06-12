public class startandenddate {
    public static void datedis(){
        List<EmailMessage> em = [select id,ParentId,Parent.ClosedDate,Parent.Failed_Record__c,Parent.Processed_Record__c from EmailMessage where Parent.ClosedDate <= today order by Parent.ClosedDate desc limit 1];
        Date extactdate = null;
        if(!em.isEmpty()){
            extactdate = em[0].Parent.ClosedDate.date();
        }
        system.debug(extactdate);
    }
}