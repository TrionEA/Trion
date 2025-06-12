public class DeleteCaseEmail {
    
    Public static void delCase()
    {
        List<Case_Email__c> lstRec = [Select Case_Email_Number__c, Case_Number__c, EmailMessage_Id__c, Email_Message_SharePoint_Id__c, Email_Message_Created_Date__c, Case_Id__c, Email_Message_Subject__c  from Case_Email__c ];
        Delete lstRec;
    }

}