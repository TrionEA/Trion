public class Arch_FolderNameMetadataUpdate_V1 {
    
    public static void sharepointmetadata(){
        Metadata.DeployContainer container = new Metadata.DeployContainer();
        String uniqueFullName = 'SharePointFolderName.'+'Folder1';
         Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
        customMetadata.fullName = uniqueFullName;
        String valuefetch = System.Label.SharePointFolderName;
        customMetadata.label = valuefetch.substring(4);
         Metadata.CustomMetadataValue record1 = new Metadata.CustomMetadataValue();
        record1.field = 'StartDate__c';
        record1.value = Date.today();
        customMetadata.values.add(record1);
        container.addMetadata(customMetadata);
        Metadata.CustomMetadataValue record2 = new Metadata.CustomMetadataValue();
        record2.field = 'EndDate__c';
        record2.value = Date.today().addDays(1);
        customMetadata.values.add(record2);
        container.addMetadata(customMetadata);     

        Metadata.CustomMetadataValue record3 = new Metadata.CustomMetadataValue();
        record3.field = 'SPFolderName__c';
        record3.value = valuefetch;
        customMetadata.values.add(record3);
        container.addMetadata(customMetadata);
   	   Id asyncResultId = Metadata.Operations.enqueueDeployment(container,null);
    }

}