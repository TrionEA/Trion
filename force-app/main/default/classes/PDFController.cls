public with sharing class PDFController {
    public String pdfContent { get; set; }
    
    public PDFController() {
        // Retrieve the content passed as a parameter
        pdfContent = ApexPages.currentPage().getParameters().get('pdfContent');
    }
}