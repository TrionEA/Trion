public with sharing class UpdateCampaignMembersQueuable implements Queueable {
    List<CampaignMember> listOfCampaignMembersToBeUpdated;
    public class CustomException extends exception {}
    
    public UpdateCampaignMembersQueuable() {
        listOfCampaignMembersToBeUpdated = new List<CampaignMember>();
    }
    
    public UpdateCampaignMembersQueuable(List<CampaignMember> listOfCampaignMembers) {
        this();
        this.listOfCampaignMembersToBeUpdated = listOfCampaignMembers;
    }
    
    public void execute(QueueableContext context) {
        for(CampaignMember eachCampaignMember :listOfCampaignMembersToBeUpdated){
            eachCampaignMember.Status__c = 'Activate';
        }
        try{
            update listOfCampaignMembersToBeUpdated;
            if(CampaignTriggerHandlerTest.isTestFailInsert){
                throw new CustomException('Fail the test class!');
            }
        }
        catch(exception e)
        {
            system.debug('exception e is '+e.getMessage());
            //Declare the List to hold the Error_Login__c
            List<Error_Login__c> listOfErrorLogin = new List<Error_Login__c>();
            Error_Login__c eachErrorlogin = new Error_Login__c();
            eachErrorlogin.Error_LineNumber__c = e.getLineNumber();
            eachErrorlogin.Error_Message__c = e.getMessage();
            eachErrorlogin.Error_StackTraceString__c = e.getStackTraceString();
            eachErrorlogin.Error_TypeName__c = e.getTypeName();
            eachErrorlogin.Error_Cause__c	= string.valueof(e.getCause());
            listOfErrorLogin.add(eachErrorlogin);
            
            insert listOfErrorLogin;
        }
    }
    
}