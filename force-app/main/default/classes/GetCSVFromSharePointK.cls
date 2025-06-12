public class GetCSVFromSharePointK {
   
    Public static void getTheeIdandName()
    {
        string accessToken = getAccessToken();
        getDataFromSharePoint(accessToken);
    }
    public class TokenResponse {
      public String access_token { get; set; }
       
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
    
    
    
    public static void getDataFromSharePoint(string accessToken) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setTimeout(120000);
        request.setEndpoint('https://graph.microsoft.com/v1.0/sites/d7c113dd-f195-44b6-a7ff-027d3860f10f/drives/b!3RPB15XxtkSn_wJ9OGDxDwymYO9ecrFLrZXuL7fJXMpOcHHo4EI6TZMW56RJH70a/items/root/children');
        
        HttpResponse response = http.send(request);
                        
        if (response.getStatusCode() == 200) {
             
                if (response.getBody() != null) {
                    String jsonString = response.getBody();
                     Overall result = (Overall)JSON.deserialize(jsonString, Overall.class);
                    System.debug('>>> emailResponse ' +result);
                               for(cls_items eachItem : result.value){
                                       system.debug(eachItem.name);
                                     system.debug(eachItem.id);
										system.debug(eachItem.webUrl);
                               }
                    
                } else {
                    System.debug('Response body is empty');
                }
           
        }
    }
       public class Overall {
    public String odataContext;
    public List<cls_items> value;
}
    public class cls_items {
   
    public String id;
    public String name;
    public String webUrl;
    }
          
    }