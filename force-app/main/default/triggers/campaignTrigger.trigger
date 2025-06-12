trigger campaignTrigger on Campaign (after insert, after update,before update) {
    CampaignTriggerHandler campaignTrigger = new CampaignTriggerHandler();
    /*if(trigger.isInsert){
        campaignTrigger.createInteractionEventmappingRecords(trigger.newMap);
    }*/
    if(trigger.isUpdate && trigger.isAfter){
        campaignTrigger.updateCampaignMembers(trigger.new, trigger.oldMap);
    }
    if(trigger.isInsert && trigger.isAfter){
       CampaignTriggerHandler.createTriggersendInsert(trigger.new);
    }
     
    if(trigger.isUpdate && trigger.isBefore){
       CampaignTriggerHandler.validateCampaignstage(trigger.newMap, trigger.oldMap);
    }
}