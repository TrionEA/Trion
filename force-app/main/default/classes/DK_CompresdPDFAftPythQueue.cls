public class DK_CompresdPDFAftPythQueue implements Queueable, Database.AllowsCallouts  {
    
    public void execute(QueueableContext context) {    
        id documentId = '069VE000003pkdNYAQ'; 
        DK_CompresdPDFAftPyth classdsj = new DK_CompresdPDFAftPyth();
        classdsj.optimizeAndCompressPdf(documentId);
    }
}