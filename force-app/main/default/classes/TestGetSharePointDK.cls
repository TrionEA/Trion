public class TestGetSharePointDK{
    public class customException extends exception{}
    @AuraEnabled
    Public static void createEmailTemplatesAndCtas(){        
        string accessToken = getAccessToken();
        getDataFromSharePoint(accessToken);
    }
    public static String getAccessToken() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://login.microsoftonline.com/c487bfd5-493f-43f0-b382-8da34b7b213b/oauth2/v2.0/token');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setTimeout(120000);
        
        String requestBody = 'grant_type=client_credentials&client_id=c6534941-5272-4d13-a86d-58a8ae871a72&client_secret=xrO8Q~MhW1tE4axOAvGr6JgicRQjGcXAxQBqbbi_&scope=https://graph.microsoft.com/.default';
        req.setBody(requestBody);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            TokenResponse tokenResponse = (TokenResponse) JSON.deserialize(res.getBody(), TokenResponse.class);
            // Do something with the deserialized tokenResponse object
            system.debug(res.getBody());
            return tokenResponse.access_token;
        } else {
            return null;
            // Handle the error response
        }
    }
    
    public static void getDataFromSharePoint(string accessToken){
        string ex = Null;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        //request.setEndpoint('https://login.microsoftonline.com/c487bfd5-493f-43f0-b382-8da34b7b213b/oauth2/v2.0/drives');
        system.debug('getDataFromSharePoint Access Token'+ accessToken);           
        request.setEndpoint('https://graph.microsoft.com/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives');
        request.setMethod('GET');
        //AccessToken-eyJ0eXAiOiJKV1QiLCJub25jZSI6IllLcFhpMXNCeDVCTlAwMHRQanNVaXFQcXFlRkpyUTdaa25ROG05cWdMSTAiLCJhbGciOiJSUzI1NiIsIng1dCI6ImtXYmthYTZxczh3c1RuQndpaU5ZT2hIYm5BdyIsImtpZCI6ImtXYmthYTZxczh3c1RuQndpaU5ZT2hIYm5BdyJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9jNDg3YmZkNS00OTNmLTQzZjAtYjM4Mi04ZGEzNGI3YjIxM2IvIiwiaWF0IjoxNzA2NjAyMjkzLCJuYmYiOjE3MDY2MDIyOTMsImV4cCI6MTcwNjYwNjE5MywiYWlvIjoiRTJWZ1lKRFh5K1M5emZWOWd3UzdPdmNuZ2ZYbkFBPT0iLCJhcHBfZGlzcGxheW5hbWUiOiJUcmlvbiBTYWxlc2ZvcmNlIFN5bmMiLCJhcHBpZCI6ImM2NTM0OTQxLTUyNzItNGQxMy1hODZkLTU4YThhZTg3MWE3MiIsImFwcGlkYWNyIjoiMSIsImlkcCI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0L2M0ODdiZmQ1LTQ5M2YtNDNmMC1iMzgyLThkYTM0YjdiMjEzYi8iLCJpZHR5cCI6ImFwcCIsIm9pZCI6IjFmNGFmZTVlLWU1MjEtNDFiYy1hZDE3LTY3NGMxMmY0YjNkYyIsInJoIjoiMC5BVnNBMWItSHhEOUo4RU96Z28yalMzc2hPd01BQUFBQUFBQUF3QUFBQUFBQUFBQmJBQUEuIiwicm9sZXMiOlsiU2l0ZXMuU2VsZWN0ZWQiLCJEaXJlY3RvcnkuUmVhZFdyaXRlLkFsbCIsIlNpdGVzLlJlYWQuQWxsIiwiU2l0ZXMuUmVhZFdyaXRlLkFsbCIsIlNpdGVzLk1hbmFnZS5BbGwiLCJGaWxlcy5SZWFkV3JpdGUuQWxsIiwiRGlyZWN0b3J5LlJlYWQuQWxsIiwiRmlsZXMuUmVhZC5BbGwiLCJTaXRlcy5GdWxsQ29udHJvbC5BbGwiXSwic3ViIjoiMWY0YWZlNWUtZTUyMS00MWJjLWFkMTctNjc0YzEyZjRiM2RjIiwidGVuYW50X3JlZ2lvbl9zY29wZSI6Ik5BIiwidGlkIjoiYzQ4N2JmZDUtNDkzZi00M2YwLWIzODItOGRhMzRiN2IyMTNiIiwidXRpIjoiMWhsZ19PSDVCVVNOYVJfZVdlSW5BQSIsInZlciI6IjEuMCIsIndpZHMiOlsiMDk5N2ExZDAtMGQxZC00YWNiLWI0MDgtZDVjYTczMTIxZTkwIl0sInhtc190Y2R0IjoxMzU2OTc3OTYwfQ.NoT92yX8NG5siogGoBBfMuYV6pFV6desiDDe_hxsOcRatRzzEw12r2aPNUgK8fjSvTdH62ycJEYM5tXkebzrDiazTyc-p5PfiVy6b0KWtokA5jtno7P5gM9217bTSQIXdH8Q3Tx578HxkwaYoeObWVSJ14qBhXO_IngBciid6NN4pX-RLxBt32afAO3eUX63rIRbOI-ZKpXJmPrZjrAIERgIjmrYxakpseWXimTCBRQTMOj16mSQBsWEAqbuELGiCHLAQap6n-6Lf6rYEwbPMZjUderDOi9XPxS3uWlWOuGJIWudHqdbHnFJcdrZBVxaH5qiQvN9sTArvBjh1QLFig
        request.setHeader('Authorization', 'Bearer '+accessToken);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'image/gif, image/jpeg, */*; q=0.2'); // Set the "Accept" header
        request.setTimeout(120000);
        //request.setBody('{"value": { "name": "Shared Documents","parentReference": {"driveType": "documentLibrary"}}}');
        //system.debug('Body>> '+ request.getBody());
        
        HttpResponse response = http.send(request);
        System.debug('>>> response ' + system.JSON.serializePretty(response.getBody()));
        System.debug('response is '+response);
        System.debug('>>> response without json '+response.getBody());
        
        if (response.getStatusCode() == 200) {
            String responseBody = response.getBody();
            System.debug('Response Body: ' + responseBody);
            
          
            overall valueResponse = (overall) JSON.deserialize(response.getBody(), overall.class);
            System.debug('deserialize(response.getBody(): ' + valueResponse);
            /* for(SharePointValueMap spi:valueResponse.itemsValueMap){

//system.debug(spi.itemsFolderInfoMap.childCount);

if (valueResponse != null && valueResponse.itemsValueMap != null) {
System.debug('valueResponse is ' + valueResponse.itemsValueMap.size());
System.debug('valueResponse body is ' + valueResponse);
system.debug(spi.name);
system.debug(spi.webUrl);
system.debug(spi.createdby);
} else {
System.debug('No data found in response.');
system.debug(spi.name);
system.debug(spi.webUrl);
system.debug(spi.createdby);
}
} */
        } else {
            System.debug('Error Response: ' + response.getBody());
        }
        
        
    }
    
    public class TokenResponse {
        public String access_token { get; set; }
        public String token_type { get; set; }
        public Integer expires_in { get; set; }
        public String scope { get; set; }
        public String soap_instance_url { get; set; }
        public String rest_instance_url { get; set; }
    }
    
    Public class overall {
        Public List<Overall_Inner> inr;
    }
    
    Public class Overall_Inner{
        Public CreatedBy[] obj;
        Public string createdDateTime;
        Public string eTag;
        Public string id;
        Public lastModifiedBy[] last;
        Public string lastModifiedDateTime;
        Public string name;
        Public List<parentReference> parent;
        Public string webUrl;
        Public string cTag;
        Public decorator[] decorate;
        Public List<fileSystemInfo> file;
        Public folder [] fold;
        Public shared[] decorate1;
        Public String size;
    }
    
    Public class CreatedBy{
        public List<User> users;
    }
    
    
    Public class lastModifiedBy{
        public List<User> users;
    }
    
    
    Public class User {
        Public String email;
        Public String id;
        Public String displayName;
        
    }   
        
    Public class parentReference{
        Public string driveType;
        Public string driveId;
        Public string id;
        Public string name;
        Public string path;
        Public string siteId;
    }
    
    Public class decorator {
        Public string iconColor;
    }
    
    
    Public class fileSystemInfo{
        Public string createdDateTime;
        Public string lastModifiedDateTime;
    }
    
    Public class folder{
        Public string childCount;
    }
    
    Public class shared{
        Public string scope;
    }
}