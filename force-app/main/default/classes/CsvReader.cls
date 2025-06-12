public class CsvReader {

    public static String getSharePointFileContent(String documentUrl, String access_token) {
        HttpRequest httpRequestToSend = new HttpRequest();
        
        // Replace with the actual SharePoint document URL for your specific scenario
        httpRequestToSend.setEndpoint(documentUrl);
        httpRequestToSend.setMethod('GET');
        httpRequestToSend.setHeader('Authorization', 'Bearer ' + access_token);

        Http http = new Http();

        try {
            HttpResponse httpResponse = http.send(httpRequestToSend);

            if (httpResponse.getStatusCode() == 200) {
                // Successfully retrieved the file content
                return httpResponse.getBody();
            } else {
                // Handle error
                System.debug('***** Error: ' + httpResponse.getBody());
                return null;
            }
        } catch (System.CalloutException e) {
            // Handle callout exception
            System.debug('***** Callout exception: ' + e.getMessage());
            return null;
        }
    }
}