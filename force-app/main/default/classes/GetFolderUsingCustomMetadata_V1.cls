global class GetFolderUsingCustomMetadata_V1 implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts {
    
    private String parentCaseId;
    private String metadataFolderName;
    
    public GetFolderUsingCustomMetadata_V1(String parentCaseId) {
        this.parentCaseId = parentCaseId;
        this.metadataFolderName = '';
    }
    
    global Iterable<String> start(Database.BatchableContext context) {
        return new List<String> { parentCaseId };
            }
    
    global void execute(Database.BatchableContext context, List<String> scope) {
        for (String caseId : scope) {
            System.debug('String caseId ===> ' + caseId);
            String caseClosedCompleteDate = '';
            
            List<Case> caseList = [SELECT Id, ClosedDate FROM Case WHERE Id = :caseId];
            for (Case cs : caseList) {
                caseClosedCompleteDate = String.valueOf(cs.ClosedDate.date());
                System.debug('String caseClosedCompleteDate => ' + caseClosedCompleteDate);
            }
            
            List<Share_Point_Folder_Name__mdt> metadataFolderNameList = Share_Point_Folder_Name__mdt.getAll().values();
            for (Share_Point_Folder_Name__mdt fnamemdt : metadataFolderNameList) {
                String metadataStartdate = String.valueOf(fnamemdt.Start_Date__c);
                String metadataEnddate = String.valueOf(fnamemdt.End_Date__c);
                
                if (caseClosedCompleteDate >= metadataStartdate && caseClosedCompleteDate <= metadataEnddate) {
                    metadataFolderName = fnamemdt.Folder_Name__c;
                    System.debug('String mainCaseFolderName => ' + metadataFolderName);
                    break; 
                }         
            }                    
        }
        MetadataFolderCache.getInstance().metadataFolderName = metadataFolderName;
    }
    
    global void finish(Database.BatchableContext context) {
        //MetadataFolderCache.getInstance().metadataFolderName = metadataFolderName;
        System.debug('######### Batch is completed');
    }
    
    
    
}


/*global class GetFolderUsingCustomMetadata_V1 implements Database.Batchable<String>{*//*, Database.allowsCallouts*/ 

/*    private String parentCaseId;

public GetFolderUsingCustomMetadata_V1(String parentCaseId) {
this.parentCaseId = parentCaseId;
}

global Iterable<String> start(Database.BatchableContext context) {
return new List<String> { parentCaseId };
}

global void execute(Database.BatchableContext context, List<String> scope) {
for (String caseId : scope) {
System.debug('String caseId ===> ' + caseId);
String metadataFolderName = '';
String caseClosedCompleteDate = '';

List<Case> caseList = [SELECT Id, ClosedDate FROM Case WHERE Id = :caseId];
for (Case cs : caseList) {
caseClosedCompleteDate = String.valueOf(cs.ClosedDate.date());
System.debug('String caseClosedCompleteDate => ' + caseClosedCompleteDate);
}

List<Share_Point_Folder_Name__mdt> metadataFolderNameList = Share_Point_Folder_Name__mdt.getAll().values();
for (Share_Point_Folder_Name__mdt fnamemdt : metadataFolderNameList) {
String metadataStartdate = String.valueOf(fnamemdt.Start_Date__c);
String metadataEnddate = String.valueOf(fnamemdt.End_Date__c);
metadataFolderName = fnamemdt.Folder_Name__c;

if (caseClosedCompleteDate >= metadataStartdate && caseClosedCompleteDate <= metadataEnddate) {
System.debug('String mainCaseFolderName => ' + metadataFolderName);
break; 
}         
}                    
}
}

global void finish(Database.BatchableContext context) {
System.debug('######### Batch is completed');
}
}

*/

/*global class GetFolderUsingCustomMetadata_V1 implements Database.Batchable<String> {

private String parentCaseId;

public GetFolderUsingCustomMetadata_V1(String parentCaseId) {
this.parentCaseId = parentCaseId;
}

public Iterable<String> start(Database.BatchableContext context) {
return new List<String> { parentCaseId };
}

public void execute(Database.BatchableContext context, List<String> scope) {
for (String caseId : scope) {
System.debug('String caseId ===> ' + caseId);
String metadataFolderName = '';
String caseClosedCompleteDate = '';

List<Case> caseList = [SELECT Id, ClosedDate FROM Case WHERE Id = :caseId];
for (Case cs : caseList) {
caseClosedCompleteDate = String.valueOf(cs.ClosedDate.date());
System.debug('String caseClosedCompleteDate => ' + caseClosedCompleteDate);
}

List<Share_Point_Folder_Name__mdt> metadataFolderNameList = Share_Point_Folder_Name__mdt.getAll().values();
for (Share_Point_Folder_Name__mdt fnamemdt : metadataFolderNameList) {
String metadataStartdate = String.valueOf(fnamemdt.Start_Date__c);
String metadataEnddate = String.valueOf(fnamemdt.End_Date__c);
metadataFolderName = fnamemdt.Folder_Name__c;

if (caseClosedCompleteDate >= metadataStartdate && caseClosedCompleteDate <= metadataEnddate) {
System.debug('String mainCaseFolderName => ' + metadataFolderName);
break; 
}         
}                    
}
}

public void finish(Database.BatchableContext context) {
System.debug('######### Batch is completed');
}
}
*/