public class GettingDataFromCSV {
       
   // @future(callout=true)
     public static void listGroups() {
     List<String> spo_sitenames = new List<String>();
     spo_sitenames.add('IT');
     String spo_file = 'EmailMessageDetails_02sVE000000GrmjYAC(5).csv';
         try{
     HttpRequest req = new HttpRequest();
     req.setMethod('GET');
     req.setHeader('Accept', 'application/json;odata=verbose');
     req.setEndpoint('callout:Sharepoint/v1.0/drives/b!3RPB15XxtkSn_wJ9OGDxDwymYO9ecrFLrZXuL7fJXMpOcHHo4EI6TZMW56RJH70a/items/01SCG6PXKUOUUP4LHLTRGYS2CD5PVJDYL2/content');
     HTTPResponse res = new Http().send(req);
             try{
       while (res.getStatusCode() == 302) {
          req.setEndpoint(res.getHeader('Location'));
           res = new Http().send(req);
      }
             }catch(exception o){
                       System.debug('Catch exception1'+o.getMessage());

             }
              Blob headerValue= blob.valueOf(res.getBody());
                  System.debug('headerValue is'+headerValue);
     String body = EncodingUtil.base64Encode(headerValue);
     System.debug('body is'+body);
      System.debug('Status code is'+res.getStatusCode());
      System.debug('get body is'+res.getBody());
      List<String> lines = res.getBody().split('\n');
                               System.debug('List<String> lines is'+lines);
                                            System.debug('List<String> lines is size'+lines.size());
         }catch(exception e){
                   System.debug('Catch exception'+e.getMessage());

         }
   
    

   }

}