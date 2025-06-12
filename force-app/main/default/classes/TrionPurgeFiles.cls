public with sharing class TrionPurgeFiles {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getRelatedFilesByRecordId(String recordId) {

        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) { 
            fileIDs.add(docLink.ContentDocumentId); 
        } 
 
        List<ContentVersion> docs = [
            SELECT ContentDocumentId, ContentSize, CreatedDate, FileExtension, Title 
            FROM ContentVersion 
            WHERE ContentDocumentId IN :fileIDs
        ]; 

        List<Map<String, String>> fileList = new List<Map<String, String>>();
        for (ContentVersion docLink : docs) { 
            Map<String, String> fileDetails = new Map<String, String>();
            fileDetails.put('ContentDocumentId', docLink.ContentDocumentId);
            fileDetails.put('Title', docLink.Title);
            fileDetails.put('FileExtension', docLink.FileExtension);
            fileDetails.put('CreatedDate', String.valueOf(docLink.CreatedDate));
            fileDetails.put('ContentSize', String.valueOf(docLink.ContentSize));
            fileList.add(fileDetails);
        } 
        return fileList; 
    }
}