public class GeneratedCsvUploadingToSP_V1 {
    @future(callout=true)
    public static void fileMigration(String encodedParentCaseId, String encodedObjectName, String encodedFileName, Blob csvBlob) {

        try{
        String endpoint = 'callout:Sharepoint/v1.0/drives/' + Label.SharepointDriveId + '/root:/' + Label.SharepointfolderName + '/' + encodedParentCaseId + '/' + encodedObjectName + '/' + encodedFileName.replaceAll('\\+', '%20') + ':/content';
        
        Http httpCallout = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'text/csv'); 
        req.setHeader('Accept', 'application/json');
        
        req.setBodyAsBlob(csvBlob);
        HTTPResponse res = httpCallout.send(req);
        String jsonString = res.getBody();
        Integer statuscode = res.getStatusCode();
        
        System.debug('Response retrieved -> ' + res.getBody());
        System.debug('Status code -> ' + res.getStatusCode());
        System.debug('Status -> ' + res.getStatus());
        
        if (statuscode == 201 || statuscode == 200) {
            System.debug('res.getStatusCode()==> '+res.getStatusCode());
            //processSharePointResponse(jsonString, emRec);
        }
        }catch(Exception e){
            System.debug('GeneratedCsvUploadingToSP_V1 Excepion===>'+e.getMessage());
        }        
    }  
}