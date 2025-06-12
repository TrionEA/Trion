public class GetSharePointApi {
  
    @future(callout=true)
    public static void fileMigration(){
        
    
            Blob fileBody;
            String fileName;
            
                        
            try{
                
                String driveId = 'b!v0xUOUDCgkW2tG7BGNgYUZHX-cuS1t9GgWLFfrj1TQVPDE1j7ctmS5-Zx3H-2ZkH';
                String encodedDriveId = EncodingUtil.urlEncode(driveId, 'UTF-8');
                String encodedFileName = EncodingUtil.urlEncode(fileName, 'UTF-8');
                String subFolderName;
                String objectName;
                
                Http httpCallout = new Http();
                HttpRequest req = new HttpRequest();
                
                req.setEndpoint('callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/'+ objectName  +'/'+subFolderName+'/' + encodedFileName.replaceall('\\+', '%20') + ':/content');
                req.setMethod('PUT');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Accept', 'application/json');
                req.setBodyAsBlob(fileBody);
                
                HTTPResponse res = httpCallout.send(req);
                
                if(res.getStatusCode() == 201){
                   // updateSharepointStatus(stagingList[0], 'Completed','null');
                   system.debug(res.getStatusCode());
                }
                else{
                    String errorMessage = 'File upload failed. Status Code: ' + res.getStatusCode() + ', Response: ' + res.getBody();
                    //updateSharepointStatus(stagingList[0], 'Pending', errorMessage);
                }
            }catch(Exception e){
               // updateSharepointStatus(stagingList[0], 'Pending', 'Exception Caught!');
            }
        }
    }