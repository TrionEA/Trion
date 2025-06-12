public class SampleClassDK {
    
    @future(callout=true)
    public static void enqueueFutureJob(Id parentId, Id emailMessageId, Integer attachmentCount) {
        System.enqueueJob(new Arch_SharePointCountMatchQueue(parentId, emailMessageId, attachmentCount));
    }

}