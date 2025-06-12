trigger AttachmentUploadTrigger on Attachment (after insert) {
    List<Attachment> attachmentsList = new List<Attachment>();
    for (Attachment att : Trigger.new) {
        if (att.ParentId.getSObjectType() == Submission_Requirement__c.SObjectType) {
            attachmentsList.add(att);
        }
    }
    if (!attachmentsList.isEmpty()) {
       RealTimeFileUploadV1.immediatePushSharepoint(attachmentsList);
    }
    
    
}