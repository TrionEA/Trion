/*
* Author: Rahul Allada (EA)
* Date: 19th May 2022
* Description: This batch will help us in populating the Campaign, Campaign Member and the Opportunity in the IER
* Note: When an IER is marked as "marked by the scheduler", this record will not be picked up by the scheduler again.
*/

global class InvidualEmailResultsBatchHandler implements Database.Batchable<sObject> {
    
    List<Id> listOfTriggeredIdsToQuery;
    List<Id> listOfCampaignIds;
    List<Id> listOfContactIds;
    List<Id> listOfCampaignMemberIds;
    Map<Id, Map<Id, Id>> mapOfCampaignMemberAndContact;
    public InvidualEmailResultsBatchHandler(){
        listOfTriggeredIdsToQuery = new List<Id>();
        listOfCampaignIds = new List<Id>();
        listOfContactIds = new List<Id>();
        mapOfCampaignMemberAndContact = new Map<Id, Map<Id, Id>>();
        listOfCampaignMemberIds = new List<Id>();
    }
    
    //Get all the IER where scheduling is not marked yet. Scheduled marked is a field that is used to track if the record is marked by the scheduler
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        String query = 'SELECT Id, Campaign__c, Campaign__r.Name, et4ae5__Lead__c, '
            + 'et4ae5__CampaignMemberId__c, et4ae5__Contact__c, ' 
			+ 'et4ae5__Contact__r.Account.name, '
            + 'et4ae5__Contact__r.Name, et4ae5__TriggeredSendDefinition__c, '
            + 'Create_Opportunity_On_Open__c, et4ae5__NumberOfTotalClicks__c, '
            + 'et4ae5__Opened__c, Marked_by_Scheduling__c '
            + 'FROM et4ae5__IndividualEmailResult__c '
            + 'WHERE Marked_by_Scheduling__c = False AND '
            + 'Campaign__c != Null AND et4ae5__CampaignMemberId__c != Null AND et4ae5__Lead__c = Null ';

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<et4ae5__IndividualEmailResult__c> listOfIndividualEmailResInserted) {
        //s<Id> listOfCampaignMemberIds = new List<Id>();
        
        //Get the list of all the triggered sends from the IERs
        for(et4ae5__IndividualEmailResult__c eachIndividualResults: listOfIndividualEmailResInserted) {
            listOfCampaignMemberIds.add(eachIndividualResults.et4ae5__CampaignMemberId__c);
        }
        
        //Get the list of all the triggered sends and Contacts tagged in the IER. 
        /*Map<Id, et4ae5__Automated_Send__c> listOfTriggeredSends = new Map<Id, et4ae5__Automated_Send__c>([SELECT Id, Campaign__c FROM et4ae5__Automated_Send__c WHERE Id IN: listOfTriggeredIdsToQuery]);
        for(et4ae5__IndividualEmailResult__c eachIndividualResults: listOfIndividualEmailResInserted){
            if(string.isEmpty(listOfTriggeredSends.get(eachIndividualResults.et4ae5__TriggeredSendDefinition__c)?.Campaign__c)){
                eachIndividualResults.Errored__c = true;
                eachIndividualResults.Error_Description__c = 'Triggered send should be populated with the Campaign field';
            }
                eachIndividualResults.Campaign__c = listOfTriggeredSends.get(eachIndividualResults.et4ae5__TriggeredSendDefinition__c)?.Campaign__c;
                listOfCampaignIds.add(eachIndividualResults.Campaign__c);
                listOfContactIds.add(eachIndividualResults.et4ae5__Contact__c);
           
        }*/
        
        //From the queried Campaign, Put it into a map of Campaign Id -> Contact Id -> Campaign member Id
        /*for(CampaignMember eachCampaignMember: [SELECT Id, CampaignId, ContactId FROM CampaignMember WHERE CampaignId IN: listOfCampaignIds AND ContactId IN: listOfContactIds]){
            
            if(mapOfCampaignMemberAndContact.containsKey(eachCampaignMember.CampaignId)){
                mapOfCampaignMemberAndContact.get(eachCampaignMember.CampaignId).put(eachCampaignMember.ContactId, eachCampaignMember.Id);
            } else {
                mapOfCampaignMemberAndContact.put(eachCampaignMember.CampaignId, new map<Id, Id>{eachCampaignMember.ContactId => eachCampaignMember.Id});
            }
        }*/
        
        system.debug('mapOfCampaignMemberAndContact is '+mapOfCampaignMemberAndContact);
        /*for(et4ae5__IndividualEmailResult__c eachIndividualEmailResult: listOfIndividualEmailResInserted){
            //eachIndividualEmailResult.Marked_by_Scheduling__c = true;
            
            if(mapOfCampaignMemberAndContact.containsKey(eachIndividualEmailResult.Campaign__c) && mapOfCampaignMemberAndContact.get(eachIndividualEmailResult.Campaign__c).containsKey(eachIndividualEmailResult.et4ae5__Contact__c)){
                eachIndividualEmailResult.et4ae5__CampaignMemberId__c = mapOfCampaignMemberAndContact.get(eachIndividualEmailResult.Campaign__c)?.get(eachIndividualEmailResult.et4ae5__Contact__c);
                listOfCampaignMemberIds.add(eachIndividualEmailResult.et4ae5__CampaignMemberId__c);
            }
        }*/
        
        List<Lead> listOfLeads = [SELECT Id, Campaign_Member_Id__c FROM Lead WHERE Campaign_Member_Id__c IN: listOfCampaignMemberIds];
        Map<Id, Id> mapOfCampaignMemberAndLead = new Map<Id, Id>();
        for(Lead eachLead: listOfLeads){
            mapOfCampaignMemberAndLead.put(eachLead.Campaign_Member_Id__c, eachLead.Id);
        }
        System.debug('mapOfCampaignMemberAndLead is '+mapOfCampaignMemberAndLead);
        
        List<Lead> listOfLeadToCreate = new List<Lead>();
        for(et4ae5__IndividualEmailResult__c eachIndividualEmailResult: listOfIndividualEmailResInserted){
            if(mapOfCampaignMemberAndLead.containsKey(eachIndividualEmailResult.et4ae5__CampaignMemberId__c) && mapOfCampaignMemberAndLead.get(eachIndividualEmailResult.et4ae5__CampaignMemberId__c) != Null){
                eachIndividualEmailResult.et4ae5__Lead__c = mapOfCampaignMemberAndLead.get(eachIndividualEmailResult.et4ae5__CampaignMemberId__c);
                eachIndividualEmailResult.Marked_by_Scheduling__c = true;
            } else if (!mapOfCampaignMemberAndLead.containsKey(eachIndividualEmailResult.et4ae5__CampaignMemberId__c) && ((eachIndividualEmailResult.Create_Opportunity_On_Open__c && eachIndividualEmailResult.et4ae5__Lead__c == Null  &&  eachIndividualEmailResult.et4ae5__Opened__c)|| eachIndividualEmailResult.et4ae5__NumberOfTotalClicks__c > 0)){
                system.debug('inside');
                listOfLeadToCreate.add(new Lead(Contact__c = eachIndividualEmailResult.et4ae5__Contact__c,Campaign__c = eachIndividualEmailResult.Campaign__c,
                                                                Campaign_Member_Id__c = eachIndividualEmailResult.et4ae5__CampaignMemberId__c,
                                                                Status = 'Open',
                                                               	Opened__c = eachIndividualEmailResult.et4ae5__Opened__c,
                                                				LastName = eachIndividualEmailResult.et4ae5__Contact__r.Name, Company = eachIndividualEmailResult.et4ae5__Contact__r.Account.name,
																RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('MC_Generated_Lead').getRecordTypeId(),
                                                                Interacted__c = eachIndividualEmailResult.et4ae5__NumberOfTotalClicks__c > 0 ? True : False));
                
                mapOfCampaignMemberAndLead.put(eachIndividualEmailResult.et4ae5__CampaignMemberId__c, Null); //This is to ensure that no new lead is created for the same campaign member.
                eachIndividualEmailResult.Marked_by_Scheduling__c = true;
            }
        }
        system.debug('listOfIndividualEmailResInserted is '+listOfIndividualEmailResInserted);
        system.debug('listOfLeadToCreate is '+listOfLeadToCreate);
		Database.SaveResult[] results = Database.update(listOfIndividualEmailResInserted, false);
        Database.SaveResult[] leadResults = Database.insert(listOfLeadToCreate, false);
        Map<Id, et4ae5__IndividualEmailResult__c> mapOfIndividualEmailResults = new Map<Id, et4ae5__IndividualEmailResult__c>(listOfIndividualEmailResInserted);
        for(integer i = 0 ; i < leadResults.size() ; i++){
            if(!leadResults.get(i).isSuccess()){
                system.debug(leadResults[i]);
                mapOfIndividualEmailResults.get(listOfLeadToCreate.get(i).Individual_Email_Result__c).Marked_by_Scheduling__c = false;
            } /*else if(leadResults.get(i).isSuccess()){
                system.debug(listOfLeadToCreate.get(i).Individual_Email_Result__c);
                system.debug(listOfLeadToCreate.get(i));
                system.debug(system.Json.serializePretty(mapOfIndividualEmailResults));
                system.debug(leadResults.get(i).getId());
                system.debug(mapOfIndividualEmailResults.get(listOfLeadToCreate.get(i).Individual_Email_Result__c));
                mapOfIndividualEmailResults.get(listOfLeadToCreate.get(i).Individual_Email_Result__c).et4ae5__Lead__c = leadResults.get(i).getId();
            }*/
        }
        system.debug('mapOfIndividualEmailResults.values() '+system.json.serializePretty(mapOfIndividualEmailResults.values()));
        
        //Database.SaveResult[] opportunityResults = Database.insert(listOfLeadToCreate, false);
        
    }
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
    
}