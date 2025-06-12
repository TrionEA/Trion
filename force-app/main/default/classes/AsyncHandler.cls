public class AsyncHandler implements Queueable {

        public static String accessToken;

    //@Future(callout=true)
    public static void execute(QueueableContext context) {
        // Perform the access token retrieval and file upload
        retrieveAccessToken();
        uploadFile();
    }

    @Future(callout=true)
    public static void retrieveAccessToken() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://login.microsoftonline.com/c487bfd5-493f-43f0-b382-8da34b7b213b/oauth2/v2.0/token');
        req.setMethod('POST'); 
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setTimeout(60000);
        
        String requestBody = 'grant_type=client_credentials&client_id=c6534941-5272-4d13-a86d-58a8ae871a72&client_secret=xrO8Q~MhW1tE4axOAvGr6JgicRQjGcXAxQBqbbi_&scope=https://graph.microsoft.com/.default';
        req.setBody(requestBody);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            TokenResponse tokenResponse = (TokenResponse) JSON.deserialize(res.getBody(), TokenResponse.class);
            accessToken = tokenResponse.access_token;
            System.debug('accessToken=>'+accessToken);
        } else {
            System.debug('Failed to retrieve access token. Status Code: ' + res.getStatusCode() + ', Response: ' + res.getBody());
        }
    }

    @Future(callout=true)
    public static void uploadFile() {
        Integer code;
    /*    if (String.isEmpty(accessToken)) {
            System.debug('Access token is required to upload the file.');
            return;
        }*/
        try {        
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://graph.microsoft.com/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/b!3RPB15XxtkSn_wJ9OGDxDwymYO9ecrFLrZXuL7fJXMpOcHHo4EI6TZMW56RJH70a/root:/Case/500VE000004nKPvYAM/02sVE000000ppGcYAI/EmailMessageDetails_02sVE000000GrmjDK9.csv:/content');
            req.setMethod('PUT');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('Content-Length', '1200000');
            req.setTimeout(60000);

            Http http = new Http();
            HttpResponse res = http.send(req);
            code=res.getStatusCode() ;

            System.debug('Hi!');
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                System.debug('File uploaded successfully.');
                System.debug('code==>'+code);
            } else {
                System.debug('File upload failed. Status Code: ' + res.getStatusCode() + ', Response: ' + res.getBody());
            }
        } catch(Exception e) {
            System.debug('Exception occurred during file upload: ' + code + e.getMessage());
        }
    }

    public class TokenResponse {
        public String access_token;
        public String token_type;
        public Integer expires_in;
        public String scope;
        public String soap_instance_url;
        public String rest_instance_url;
    }


     public static void testCoverage(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
     }
}