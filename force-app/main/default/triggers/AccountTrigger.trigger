trigger AccountTrigger on Account (before insert, before update) {
trigger_proposal__c Trigger_bypass_setting = trigger_proposal__c.getInstance(UserInfo.getProfileId());
    if(Trigger_bypass_setting.proposal_trigger_bypass__c == 0){
        system.debug('::: trigger ran:::');
    
    AccountTriggerHandler accountTriggerHandler = new AccountTriggerHandler();
    if(trigger.isInsert){
        accountTriggerHandler.fillTheSurveyDate(trigger.new, null);
    } else if (trigger.isUpdate){
        accountTriggerHandler.fillTheSurveyDate(trigger.new, trigger.oldMap);
    }
    }
}