public class DK_CompresdPDFAftPyth {

    public  void optimizeAndCompressPdf(id documentId) {

        List<ContentVersion> contentVersionList = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId = :documentId];
        //ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId = :documentId LIMIT 1];
        //Convert the PDF to Base64 for the API call
        //String contentVersiondata = contentVersionList[0].VersionData;
        System.debug('contentVersionList[0].VersionData ==> ' +contentVersionList[0].VersionData);
        String base64Pdf = EncodingUtil.base64Encode(contentVersionList[0].VersionData);
        system.debug('String base64Pdf==> '+base64Pdf);
        //Call external service (mockup)
        String optimizedPdfBase64 = callPdfOptimizationService(base64Pdf);
        System.debug('String base64Pdf===> ' +base64Pdf);
        System.debug('String optimizedPdfBase64===> ' +optimizedPdfBase64);

        ContentVersion optimizedContent = new ContentVersion(
            Title = 'Optimized PDF',
            PathOnClient = 'optimized_sample.pdf',
            VersionData = EncodingUtil.base64Decode(optimizedPdfBase64)
        );

        insert optimizedContent;
    }

    private String callPdfOptimizationService(String base64Pdf) {
        //Make an HTTP callout to your external PDF optimization service
        String name = 'ABC';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        //request.setEndpoint('https://api.yourpdfservice.com/optimize');
        request.setEndpoint('callout:Sharepoint/optimize');
        request.setMethod('OPTIONS');
        request.setHeader(
            'Authorization',
            'Basic '+EncodingUtil.base64Encode(Blob.valueOf('username:password'))
        );
        
        request.setHeader('Content-Type', 'application/json');
        String body = '{"pdf": "' + base64Pdf + '"}';
        request.setBody(body);
        //System.debug('String body===> ' +body);
        System.debug('request===> ' +request);
        HttpResponse response;
        try {
            response = http.send(request);
            System.debug('Response Status Code: ' + response.getStatusCode());
            System.debug('Response Status: ' + response.getStatus());
            System.debug('Response Body: ' + response.getBody());
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            throw new CalloutException('Failed to connect to API: ' + e.getMessage());
        }
        
        /*  if (response.getStatusCode() == 200) {
PdfOptimizationResponse result = (PdfOptimizationResponse) JSON.deserialize(response.getBody(), PdfOptimizationResponse.class);
return result.optimizedPdf;
} else {
System.debug('Response Status: ' + response.getStatus());
System.debug('Response Body: ' + response.getBody());
throw new CalloutException('Failed to optimize PDF: ' + response.getStatus());
}  */
        return name;
    }

    public class PdfOptimizationResponse {
        public String optimizedPdf;
    }

}