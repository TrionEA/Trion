public class CampaignTriggerHandler {
    
      public class CustomException extends exception {}
    Public CampaignTriggerHandler(){
        
    }
    Public void updateCampaignMembers(List<Campaign> listOfCampaignsUpdated, Map<Id, Campaign> mapOfCampaignsBeforeUpdate){
        try{        
            List<Id> listOfCampaignsToConsider = new List<Id>();
            //Map<Id, string> mapOfIdAndStatus = new Map<Id, String>();
            List<Id> listOfOtherCampaigns = new List<Id>();
            Map<Id, Integer> mapOfCampaignAndSizeOfMembers = new Map<Id, Integer>();
            for(Campaign eachCampaign : (List<Campaign>) trigger.new){
                if(mapOfCampaignsBeforeUpdate.get(eachCampaign.Id).Campaign_Stage__c != 'Activated / In Progress' && eachCampaign.Campaign_Stage__c == 'Activated / In Progress'){
                    listOfCampaignsToConsider.add(eachCampaign.Id);
                } else if (mapOfCampaignsBeforeUpdate.get(eachCampaign.Id).Campaign_Stage__c != eachCampaign.Campaign_Stage__c ){
                    //mapOfIdAndStatus.put(eachCampaign.Id, eachCampaign.Campaign_Stage__c);
                    listOfOtherCampaigns.add(eachCampaign.Id);
                }
            }
            system.debug('listOfCampaignsToConsider are '+listOfCampaignsToConsider);
            checkIfTSAreActivatedPreviously(listOfCampaignsToConsider, listOfCampaignsUpdated);
            List<CampaignMember> campaignMemsToUpdate = new lIst<CampaignMember>();
            for(Campaign eachCampaign : [SELECT Id, Campaign_Stage__c, (SELECT Campaign_completed__c, CampaignId, Status__c FROM CampaignMembers) FROM Campaign WHERE Id IN: listOfOtherCampaigns]){
                for(CampaignMember eachCampaignMember: eachCampaign.CampaignMembers){
                    eachCampaignMember.Status__c = eachCampaign.Campaign_Stage__c;
                    campaignMemsToUpdate.add(eachCampaignMember);
                }
            }
            if(!campaignMemsToUpdate.isEmpty()){
                update campaignMemsToUpdate;
            }
            system.debug(campaignMemsToUpdate);
            
            //Get the list of Campaigns and its members
            Map<Id, Campaign> mapOfCampaigns = new Map<Id, Campaign>([SELECT Id, Campaign_Stage__c, (SELECT Campaign_completed__c, CampaignId FROM CampaignMembers) FROM Campaign WHERE Id IN: listOfCampaignsToConsider]);
            List<CampaignMember> listOfCampaignMembersToUpdate = new List<CampaignMember>();
            for(Id eachCampaign : mapOfCampaigns.keySet()){
                if(mapOfCampaigns.get(eachCampaign).CampaignMembers.size() > 50){
                    queueCampaignMembers(mapOfCampaigns.get(eachCampaign).CampaignMembers);
                }else{
                    for(CampaignMember eachCampaignMember : mapOfCampaigns.get(eachCampaign).CampaignMembers){
                        eachCampaignMember.Status__c = 'Activated / In Progress';
                        listOfCampaignMembersToUpdate.add(eachCampaignMember);
                    }
                }
            }
            if(!listOfCampaignMembersToUpdate.isEmpty()){
                update listOfCampaignMembersToUpdate;
            }}
        catch(Exception e)
        {
            System.debug('Exception is '+e.getMessage());
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
    
    Public void checkIfTSAreActivatedPreviously(List<Id> listOfCampaignIds, List<Campaign> listOfCampaignsUpdated){
        Map<Id, Campaign> mapOfCampaignsUpdated = New Map<Id, Campaign>(listOfCampaignsUpdated);
        Map<Id, DateTime> mapOfCampaignIdAndTime = new Map<Id, DateTime>();
        Map<Id, Boolean> mapOfCampaignIdAndActive = new Map<Id, Boolean>();
        Map<Id, Campaign> mapOfCampaignAndETMs = New Map<Id, Campaign>([SELECT Id, (SELECT Id, Name, Template_Last_Activated_On__c FROM Email_Template_Mappings__r WHERE Template_Last_Activated_On__c != Null AND Status__c = 'Activate' ORDER BY Template_Last_Activated_On__c DESC LIMIT 1) FROM Campaign]);
        for(et4ae5__Automated_Send__c eachAutomatedSend: [SELECT Id, Activated_previously_on__c, Campaign__c, et4ae5__Active__c FROM et4ae5__Automated_Send__c WHERE Campaign__c IN: listOfCampaignIds ORDER BY Activated_previously_on__c DESC LIMIT 1 ]){
            mapOfCampaignIdAndTime.put(eachAutomatedSend.Campaign__c, eachAutomatedSend.Activated_previously_on__c);
            mapOfCampaignIdAndActive.put(eachAutomatedSend.Campaign__c, eachAutomatedSend.et4ae5__Active__c);
        }
        system.debug(mapOfCampaignAndETMs);
        for(Id eachCampaignId : listOfCampaignIds){
            system.debug('campaignId '+eachCampaignId);
            system.debug('mapOfCampaignAndETMs.get(eachCampaignId).Email_Template_Mappings__r[0].name ' + mapOfCampaignAndETMs.get(eachCampaignId).Email_Template_Mappings__r[0].name);
            system.debug('mapOfCampaignAndETMs.get(eachCampaignId).Email_Template_Mappings__r[0].Template_Last_Activated_On__c '+mapOfCampaignAndETMs.get(eachCampaignId).Email_Template_Mappings__r[0].Template_Last_Activated_On__c);
            system.debug('mapOfCampaignIdAndTime.get(eachCampaignId) '+mapOfCampaignIdAndTime.get(eachCampaignId));
            if(mapOfCampaignIdAndActive?.get(eachCampaignId) == false){
                mapOfCampaignsUpdated.get(eachCampaignId).addError('The triggered send should be activated');
            } else if(mapOfCampaignAndETMs.get(eachCampaignId).Email_Template_Mappings__r[0].Template_Last_Activated_On__c > mapOfCampaignIdAndTime.get(eachCampaignId)){
                mapOfCampaignsUpdated.get(eachCampaignId).addError('The triggered send should be deactivated and activated');
            }
        }
        
    }
    
    Public void queueCampaignMembers(List<CampaignMember> campaignMembersToBeUpdated){
        Map<Id, CampaignMember> mapOfCampaignMember = new Map<Id, CampaignMember>(campaignMembersToBeUpdated);
        //Declare a list to hold the list of campaign members
        List<CampaignMember> listOfCampaignMembers = new List<CampaignMember>();
        //Break the list of campaign members into list of 50 and update them to Activate state
        for(Id eachCampaignMember : new Map<Id, CampaignMember>(campaignMembersToBeUpdated).keySet()){
            if(listOfCampaignMembers.size() > 40){
                Id jobId = system.enqueueJob(new UpdateCampaignMembersQueuable(listOfCampaignMembers));
                listOfCampaignMembers.clear();
            }
            listOfCampaignMembers.add(mapOfCampaignMember.get(eachCampaignMember));
        }
        if(listOfCampaignMembers.size() > 0){
            Id jobId = system.enqueueJob(new UpdateCampaignMembersQueuable(listOfCampaignMembers));
            listOfCampaignMembers.clear();
        }
        
    }
    // Created by Yamini---19th May 
    // When a Campaign is created,Create the TriggerSendRecord
    Public static void createTriggersendInsert(List<Campaign> newCampaignList)
    {  
        //Declare a list to hold the list of et4ae5__Automated_Send__c
        List<et4ae5__Automated_Send__c> listOfAutomatedSend = new List<et4ae5__Automated_Send__c>();
        
        //Get the list of et4ae5__Business_Unit__c
        List<et4ae5__Business_Unit__c> listOfBusinessUnit = [Select id,Name from et4ae5__Business_Unit__c Where Name='Trion Solutions II, Inc' Limit 1];
        
        //Get the list of Email_Template__c
        List<Email_Template__c> listOfemailTemplate = [Select id,Name,Email_Asset_Id__c,Email_Template_Id__c from Email_Template__c where Name='Manual timekeeping systems are widely Inaccurate' Limit 1  ];
        
        
        for(Campaign campaignObjEach: newCampaignList)
        {  
            et4ae5__Automated_Send__c eachAutomatedSend = new et4ae5__Automated_Send__c();
            
            Id inactiveRecordTypeId = Schema.SObjectType.et4ae5__Automated_Send__c.getRecordTypeInfosByName().get('Inactive').getRecordTypeId();
            
            string filter =	'('+ 'campaign_name__c'+' = \''+ campaignObjEach.Name + '\'' +' AND '+ 'interacted__c'+ ' = '+'False'+ ' AND '+'send_campaign_emails__c ' + '=' + ' True ' + 'AND status__c ' + '=' + ' \'Activated / In Progress\''+')';
            // system.debug(filter);
            eachAutomatedSend.Name = 'Triggered send - ' + ' ' + campaignObjEach.Id;
            eachAutomatedSend.et4ae5__Object__c = 'CAMPAIGNMEMBER';
            eachAutomatedSend.et4ae5__Filter__c = filter;
            eachAutomatedSend.et4ae5__Contact_Lead_FIeld__c = 'Contact';
            eachAutomatedSend.Campaign__c = campaignObjEach.id;
            //eachAutomatedSend.et4ae5__Data_Extension_Name__c ='TriggeredSDE';
            eachAutomatedSend.et4ae5__Hours_Delayed__c = 0;
            eachAutomatedSend.et4ae5__SendClassificationName__c = 'No Reply Survey';
            eachAutomatedSend.et4ae5__SendClassificationName__c = 
            eachAutomatedSend.et4ae5__SendClassificationId__c = '8dde213e-e020-ee11-a5c0-5cba2c1a53e8';
            eachAutomatedSend.et4ae5__Subscriber_Field__c = 'contactid';
            
            //check and assign the list only when the size is more than 0
            if(listOfBusinessUnit.size()>0){
                eachAutomatedSend.et4ae5__Business_Unit__c = listOfBusinessUnit[0].id;
            }
            eachAutomatedSend.et4ae5__Use_All_Subscribers_List__c = true;
            eachAutomatedSend.et4ae5__Subscribed_For_Tracking__c =true;	
            //check and assign the list only when the size is more than 0
            if(listOfemailTemplate.size()>0){
                eachAutomatedSend.et4ae5__EmailId__c = listOfemailTemplate[0].Email_Asset_Id__c;
                eachAutomatedSend.et4ae5__EmailAssetId__c = listOfemailTemplate[0].Email_Template_Id__c;
                eachAutomatedSend.et4ae5__EmailName__c = listOfemailTemplate[0].Name;
            }
               //eachAutomatedSend.et4ae5__FromEmail__c = 'rahulallada@enabledanalytics.com';
              eachAutomatedSend.et4ae5__FromEmail__c = 'Gangabhavani@enabledanalytics.com';

            eachAutomatedSend.et4ae5__Active__c = false;
            eachAutomatedSend.RecordTypeId = inactiveRecordTypeId;
            eachAutomatedSend.et4ae5__Action__c = 'EitherSubsequently';
            
            listOfAutomatedSend.add(eachAutomatedSend);
            
        }
        try
        {   
            insert listOfAutomatedSend;
            if(CampaignTriggerHandlerTest.isTestFailInsert){
                    
                    throw new CustomException('Fail the test class!');
                    
                }
        }
        catch(exception e){
            System.debug('Exception is '+e.getMessage());
            //Declare the List to hold the Error_Login__c
            insert new Error_Login__c(
                Error_LineNumber__c = e.getLineNumber(),
                Error_Message__c = e.getMessage(),
                Error_StackTraceString__c = e.getStackTraceString(),
                Error_TypeName__c = e.getTypeName(),
                Error_Cause__c = String.valueOf(e.getCause())
            );
            
        }
    }
    
    
    
    public static void validateCampaignstage(Map<Id, Campaign> insertedCampaignMap, Map<Id, Campaign> oldCampaignMap){
        
        List<Email_Template_Mapping__c> listOfEmailTemplateMappingsToUpdate = new List<Email_Template_Mapping__c>();
        List<Campaign> listOfCampaigns = [SELECT Id, Campaign_Stage__c, No_Of_Times_Activated__c, (SELECT Id, Status__c, Activation_Order__c FROM Email_Template_Mappings__r WHERE Status__c = 'Activate') FROM Campaign WHERE Id IN: insertedCampaignMap.keySet()];
        for(Campaign eachInsertedCampaign : listOfCampaigns){
            if(eachInsertedCampaign.Email_Template_Mappings__r.size() == 0 && insertedCampaignMap.get(eachInsertedCampaign.Id).Campaign_Stage__c =='Activated / In Progress'){
                insertedCampaignMap.get(eachInsertedCampaign.Id).addError('Please activate an email template before activating the campaign');
            } else if(insertedCampaignMap.get(eachInsertedCampaign.Id).Campaign_Stage__c =='Activated / In Progress' && oldCampaignMap.get(eachInsertedCampaign.Id).Campaign_Stage__c !='Activated / In Progress' && eachInsertedCampaign.Email_Template_Mappings__r.size() == 1){
                insertedCampaignMap.get(eachInsertedCampaign.Id).No_Of_Times_Activated__c += 1;
                if(string.isEmpty(eachInsertedCampaign.Email_Template_Mappings__r[0].Activation_Order__c)){
                    eachInsertedCampaign.Email_Template_Mappings__r[0].Activation_Order__c = string.valueOf(insertedCampaignMap.get(eachInsertedCampaign.Id).No_Of_Times_Activated__c);
                    listOfEmailTemplateMappingsToUpdate.add(eachInsertedCampaign.Email_Template_Mappings__r[0]);
                } else  {
                    eachInsertedCampaign.Email_Template_Mappings__r[0].Activation_Order__c = eachInsertedCampaign.Email_Template_Mappings__r[0].Activation_Order__c + ' - ' + insertedCampaignMap.get(eachInsertedCampaign.Id).No_Of_Times_Activated__c;
                    listOfEmailTemplateMappingsToUpdate.add(eachInsertedCampaign.Email_Template_Mappings__r[0]);
                }
            }
            try{
                update listOfEmailTemplateMappingsToUpdate;
                if(CampaignTriggerHandlerTest.isTestFailInsert){
                    
                    throw new CustomException('Fail the test class!');
                    
                }
            } Catch(Exception e){
                system.debug('Exception e is ' + e.getMessage());
            }
        }
    } 
    
    Public static void checkDuplicateCampaignNames (List<Campaign> listOfInsertedCampaigns, Map<Id, Campaign> oldCampaignMap){
        List<String> listOfCampaignNames = new List<String>();
        for(Campaign eachCampaign: [SELECT Name FROM Campaign]){
            listOfCampaignNames.add(eachCampaign.Name);
        }
        for(Campaign eachCampaign : listOfInsertedCampaigns){
            if(listOfCampaignNames.contains(eachCampaign.Name)){
                eachCampaign.addError('An campaign with the name '+ eachCampaign.Name + ' already exists! Please give a different name and try again.');
            }
        }
        
    }
}