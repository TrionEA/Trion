public class DK_CompressPDFDocument{
    
    String API_KEY = 'sweetysuji20017@gmail.com_pLySKuPoBhZ5lWN4HAw13tAOu9dTBTNLeaLIx6g4G7sicjTY3MXmsWX3VcvbOM5W';
    String fileName = 'sample'; // File name "sample.pdf" which is available in Files.
    String DestinationFile = 'result.pdf'; // This is the destination file name.
    Integer CHUNK_SIZE = 4000000; // Chunk size set to 4 MB to ensure each request stays within limits.

    public void startProcessing() {
        ContentVersion cv = [SELECT Title, VersionData FROM ContentVersion WHERE Title = :fileName LIMIT 1];
        Blob sourceFile = cv.VersionData;
        
        try {
            // 1. Prepare URL for "Get Presigned URL" API call
            String url = 'https://api.pdf.co/v1/file/upload/get-presigned-url?contenttype=application/octet-stream&name=' + fileName;
            HttpRequest req = new HttpRequest();
            req.setHeader('x-api-key', API_KEY);
            req.setEndpoint(url);
            req.setMethod('GET');
            req.setTimeout(60000);
            Http http = new Http();
            HTTPResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                System.Debug('Response: ' + res);
                Map<String, Object> deserializedBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                Boolean isError = Boolean.ValueOf(deserializedBody.get('error'));
                if (isError == false) {
                    // Get URL to use for the file upload
                    String uploadUrl = String.ValueOf(deserializedBody.get('presignedUrl'));
                    // Get URL of uploaded file to use with later API calls
                    String uploadedFileUrl = String.ValueOf(deserializedBody.get('url'));
                    
                    // 2. Upload the file in chunks
                    if (uploadFileInChunks(API_KEY, uploadUrl, sourceFile)) {
                        // 3. Compress Uploaded file and download.
                        CompressInputPDF(API_KEY, DestinationFile, uploadedFileUrl);
                    }
                }
            } else {
                System.debug('Error Response: ' + res.getBody());
                System.Debug('Status: ' + res.getStatus());
                System.Debug('Status Code: ' + res.getStatusCode());
                System.Debug('Response String: ' + res.toString());
            }
        } catch (Exception ex) {
            String errorBody = 'Message: ' + ex.getMessage() + ' -- Cause: ' + ex.getCause() + ' -- Stacktrace: ' + ex.getStackTraceString();
            System.Debug(errorBody);
        }
    }
    
    @TestVisible
    public static boolean uploadFileInChunks(String API_KEY, String url, Blob sourceFile) {
        // Convert Blob to base64-encoded string
        String base64Data = EncodingUtil.base64Encode(sourceFile);
        Integer dataSize = base64Data.length();
        Integer offset = 0;

        while (offset < dataSize) {
            Integer chunkSize = Math.min(dataSize - offset, 4000000); // Set chunk size to 4 MB
            String chunkData = base64Data.substring(offset, offset + chunkSize); // Slice the base64 string into chunks
            Blob chunkBlob = EncodingUtil.base64Decode(chunkData); // Convert back to Blob for upload
            offset += chunkSize;
            
            HttpRequest req = new HttpRequest();
            req.setHeader('x-api-key', API_KEY);
            req.setHeader('Content-Type', 'application/octet-stream');
            req.setEndpoint(url);
            req.setMethod('PUT');
            req.setTimeout(60000);
            req.setBodyAsBlob(chunkBlob);
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            if (res.getStatusCode() != 200) {
                System.debug('Error Response: ' + res.getBody());
                System.Debug('Status: ' + res.getStatus());
                System.Debug('Status Code: ' + res.getStatusCode());
                System.Debug('Response String: ' + res.toString());
                return false;
            }
        }
        return true;
    }
    
    public static void CompressInputPDF(String API_KEY, String DestinationFile, String uploadedFileUrl) {
        Map<string, object> parameters = new Map<string, object>();
        parameters.put('name', DestinationFile);
        parameters.put('url', uploadedFileUrl);

        string jsonPayload = Json.serialize(parameters);
        String url = 'https://api.pdf.co/v1/pdf/optimize';
        
        HttpRequest req = new HttpRequest();
        req.setHeader('x-api-key', API_KEY);
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setTimeout(60000);
        req.setBody(jsonPayload);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            System.Debug(res);
            Map<String, Object> deserializedBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            Boolean isError = Boolean.ValueOf(deserializedBody.get('error'));
            if (isError == false) {
                String resultFileUrl = String.ValueOf(deserializedBody.get('url'));
                downloadPDFAndStore(resultFileUrl, DestinationFile);
            }
        } else {
            System.debug('Error Response: ' + res.getBody());
            System.Debug('Status: ' + res.getStatus());
            System.Debug('Status Code: ' + res.getStatusCode());
            System.Debug('Response String: ' + res.toString());
        }
    }
    
    @TestVisible
    private static void downloadPDFAndStore(String extFileUrl, String DestinationFile) {
        Http h = new Http(); 
        HttpRequest req = new HttpRequest(); 
        extFileUrl = extFileUrl.replace(' ', '%20'); 
        req.setEndpoint(extFileUrl); 
        req.setMethod('GET'); 
        req.setHeader('Content-Type', 'application/pdf');
        req.setCompressed(true); 
        req.setTimeout(60000); 
        
        // Now send HTTP request
        HttpResponse res = h.send(req); 
        
        if (res.getStatusCode() == 200) {
            Blob fileContent = res.getBodyAsBlob();
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // Specify this document is in Salesforce
            conVer.PathOnClient = DestinationFile + '.pdf'; // File name with extension
            conVer.Title = DestinationFile; // Display name of the file
            conVer.VersionData = fileContent;
            insert conVer;
            System.Debug('Success');
        } else {
            System.debug('Error Response: ' + res.getBody());
            System.Debug('Status: ' + res.getStatus());
            System.Debug('Status Code: ' + res.getStatusCode());
            System.Debug('Response String: ' + res.toString());
        }
    }
}