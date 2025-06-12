public class SendsharepointAscny {
    @future(callout=true)
    public static void sendFile() {
        String accessToken;
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://login.microsoftonline.com/c487bfd5-493f-43f0-b382-8da34b7b213b/oauth2/v2.0/token');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setTimeout(60000);
        
        String requestBody = 'grant_type=client_credentials&client_id=c6534941-5272-4d13-a86d-58a8ae871a72&client_secret=xrO8Q~MhW1tE4axOAvGr6JgicRQjGcXAxQBqbbi_&scope=https://graph.microsoft.com/.default';
        req.setBody(requestBody);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
            TokenResponse tokenResponse = (TokenResponse) JSON.deserialize(res.getBody(), TokenResponse.class);
            accessToken = tokenResponse.access_token;
        }
        
        Http httpCallout = new Http();
        HttpRequest req2 = new HttpRequest();
        req2.setEndpoint('https://graph.microsoft.com/v1.0/sites/b!3RPB15XxtkSn_wJ9OGDxDwymYO9ecrFLrZXuL7fJXMpOcHHo4EI6TZMW56RJH70a/root:/Case/500VE000004nKPvYAM/02sVE000000ppGcYAI/EmailMessageDetails_02sVE000000GrmjDK9.csv:/content');           
        req2.setMethod('PUT');
        req2.setHeader('Content-Type', 'application/json');
        req2.setHeader('Accept', 'application/json');
        req2.setHeader('Authorization', 'Bearer ' + accessToken);
        req2.setHeader('Content-Length', '1200000');
        req2.setTimeout(60000);
        
        HTTPResponse res2 = httpCallout.send(req2);
        
        if(res2.getStatusCode() == 201){
            System.debug('Successful'+ res2.getStatusCode());
        }
        String errorMessage = 'File upload failed. Status Code: ' + res2.getStatusCode() + ', Response: ' + res2.getBody();
        System.debug('String errorMessage==> ' + errorMessage);
    }       

    public class TokenResponse {
        public String access_token { get; set; }
        public String token_type { get; set; }
        public Integer expires_in { get; set; }
        public String scope { get; set; }
        public String soap_instance_url { get; set; }
        public String rest_instance_url { get; set; }
    }
}