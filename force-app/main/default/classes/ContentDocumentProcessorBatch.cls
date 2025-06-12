global class ContentDocumentProcessorBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    private Map<Id, List<ContentVersion>> chunkMap = new Map<Id, List<ContentVersion>>();
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
    System.debug('Batch start method called.');
    return Database.getQueryLocator([
        SELECT Id, Title, ContentSize, FileType 
        FROM ContentDocument 
        WHERE ContentSize > 12000000
    ]);
}

global void execute(Database.BatchableContext bc, List<ContentDocument> scope) {
    System.debug('Batch execute method called with scope size: ' + scope.size());
    for (ContentDocument cd : scope) {
        System.debug('Processing ContentDocument Id: ' + cd.Id);
        splitContentDocumentIntoChunks(cd.Id, cd.Id);
    }
    
    insertChunkContentVersions();
}

global void finish(Database.BatchableContext bc) {
    System.debug('Batch finish method called.');
    insertChunkContentVersions();
}
    private void splitContentDocumentIntoChunks(Id parentId, Id contentDocumentId) {
    ContentDocument originalContentDocument = [SELECT Id, Title, ContentSize, FileType 
                                                FROM ContentDocument 
                                                WHERE Id = :contentDocumentId 
                                                LIMIT 1];
        
    
    Decimal ab = Math.ceil((originalContentDocument.ContentSize + 12000000 - 1.0) / 12000000.0);
    integer numChunks=ab.intValue();
    
    for (ContentVersion cv : [SELECT VersionData 
                              FROM ContentVersion 
                              WHERE ContentDocumentId = :contentDocumentId 
                              LIMIT 1]) {
        Blob versionData = cv.VersionData;
        Integer dataSize = versionData.size();
        for (Integer i = 0; i < numChunks; i++) {
            Integer startIdx = i * 1200000;
            Integer endIdx = Math.min((i + 1) * 1200000, dataSize);
            
            String chunkDataString = EncodingUtil.base64Encode(versionData).substring(startIdx, endIdx);
            Blob chunkData = EncodingUtil.base64Decode(chunkDataString);
            
            ContentVersion chunkContentVersion = new ContentVersion();
            chunkContentVersion.Title = originalContentDocument.Title + '_part_' + (i + 1);
            chunkContentVersion.PathOnClient = originalContentDocument.Title + '_part_' + (i + 1) + '.' + originalContentDocument.FileType;
            chunkContentVersion.ContentDocumentId = contentDocumentId;
            chunkContentVersion.VersionData = chunkData;
            chunkContentVersion.ContentLocation = 'S'; // Set content location to S to indicate it's stored in Salesforce
            
            if (!chunkMap.containsKey(parentId)) {
                chunkMap.put(parentId, new List<ContentVersion>());
            }
            chunkMap.get(parentId).add(chunkContentVersion);
        }
    }
}
    
    public List<ContentVersion> insertChunkContentVersions() {
        List<ContentVersion> allChunks = new List<ContentVersion>();
        
        for (List<ContentVersion> chunks : chunkMap.values()) {
            allChunks.addAll(chunks);
        }
        
        if (!allChunks.isEmpty()) {
            ChunkPDFGenerator.insertPDFContentVersion(allChunks, 'CombinedPDF');
        }
        
        chunkMap.clear();
        
        return allChunks;
    }
}