public class ChunkPDFGenerator {
    
    public static Id insertPDFContentVersion(List<ContentVersion> chunks, String pdfName) {
        // Generate PDF from chunks
        Blob pdfBlob = generatePDFFromChunks(chunks);
        
        // Insert PDF as ContentVersion
        ContentVersion cv = new ContentVersion();
        cv.Title = pdfName; // Set the title for the PDF
        cv.PathOnClient = pdfName + '.pdf'; // Set the file name
        cv.VersionData = pdfBlob;
        cv.IsMajorVersion = true;
        cv.ContentLocation = 'S'; // Set content location to 'S' for Salesforce
        insert cv;
        
        return cv.Id; // Return the Id of the inserted ContentVersion
    }
    
    private static Blob generatePDFFromChunks(List<ContentVersion> chunks) {
        // Combine data from each chunk
        String combinedData = combineChunks(chunks);
        
        // Render Visualforce page as PDF
        return renderPDF(combinedData);
    }
    
    private static String combineChunks(List<ContentVersion> chunks) {
        String combinedData = '';
        
        // Combine data from each chunk
        for (ContentVersion chunk : chunks) {
            combinedData += EncodingUtil.base64Encode(chunk.VersionData);
        }
        
        return combinedData;
    }
    
    private static Blob renderPDF(String combinedData) {
        // Call the Visualforce page to generate PDF
        PageReference pdfPage = Page.GeneratePDFPage;
        pdfPage.getParameters().put('pdfContent', combinedData);
        Blob pdfBlob;
        if (!Test.isRunningTest()) {
            pdfBlob = pdfPage.getContentAsPDF();
        } else {
            pdfBlob = Blob.valueOf('Test PDF Content'); // For testing purpose
        }
        return pdfBlob;
    }
}