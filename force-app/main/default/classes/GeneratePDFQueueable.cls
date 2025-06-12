public class GeneratePDFQueueable implements Queueable, Database.AllowsCallouts {
    private String pageUrl;

    public GeneratePDFQueueable(String url) {
        this.pageUrl = url;
    }

    public void execute(QueueableContext context) {
        PageReference pdfPage = new PageReference(pageUrl);
        Blob pdfBlob = pdfPage.getContentAsPDF();
        String pdfFileName = 'EmailMessageDetails.pdf';
        
        // Optionally, you can save the PDF to a record or send it in an email
        // For demonstration purposes, let's send the PDF in an email
        Messaging.EmailFileAttachment pdfAttachment = new Messaging.EmailFileAttachment();
        pdfAttachment.setFileName(pdfFileName);
        pdfAttachment.setBody(pdfBlob);

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { 'your-email@example.com' });
        email.setSubject('Generated PDF');
        email.setPlainTextBody('Please find the attached PDF.');
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { pdfAttachment });

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
}