public class AttachmentUploadQueue implements Queueable{
    
    List<Attachment> attList;

    public AttachmentUploadQueue(List<Attachment> attList) {
        this.attList = attList;
    }

    public void execute(QueueableContext context) {
        // Call your SharePoint integration logic here
        RealTimeFileUploadV1.immediatePushSharepoint(attList);
    }

}