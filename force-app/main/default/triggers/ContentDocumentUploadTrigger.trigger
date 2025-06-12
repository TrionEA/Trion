trigger ContentDocumentUploadTrigger on ContentDocument (After insert) {
     List<ContentDocument> contentDocumentList = new List<ContentDocument>();
    for (ContentDocument cd : Trigger.new) {
        //if (cd.LatestPublishedVersion.ParentId.getSObjectType() == Account.SObjectType) {
            contentDocumentList.add(cd);
        //}
    }
    if (!contentDocumentList.isEmpty()) {
       //RealTimeContentDocumentUpload.immediatePushSharepoint(contentDocumentList);
    }

}