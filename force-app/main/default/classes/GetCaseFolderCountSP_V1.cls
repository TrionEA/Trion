public class GetCaseFolderCountSP_V1 {
    
    public static void getCaseCount(String caseParentId){
       /* List<Case> caseList = [Select id from Case where id = :caseParentId];
        System.debug(' List<Case> caseList===> ' + caseList); 
        System.debug(' List<Case> caseList size===> ' + caseList.size()); 
        
        for(Case cs:caseList){
            caseFolderName = cs.Id;
        }
        System.debug(' String caseFolderName===> ' + caseFolderName);   
        System.debug(' String caseParentId===> ' + caseParentId);  
        string sharepointdriveId = Label.SharepointDriveId;
        string sharepointsiteId = Label.SharePoint_Site_Id;
        String objectNameCase2 = GetFolderUsingCustomMetadata.getData(caseFolderName); 
        try{
            Http httpCallout = new Http();
            HttpRequest req1 = new HttpRequest();
            req1.setMethod('GET');
            req1.setHeader('Content-Type', 'application/json');
            req1.setHeader('Accept', 'application/json');
            req1.setTimeout(120000);
            req1.setEndpoint('callout:Sharepoint/v1.0/sites/' + Label.SharePoint_Site_Id + '/drives/' + Label.SharepointDriveId + '/items/root:/' + objectNameCase2  + '/' + caseFolderName + ':/children');             
            
            HTTPResponse res1 = httpCallout.send(req1);
            
        }Catch(Exception e){
            System.debug('Catch Exception=>' +e.getMessage());
        }  
*/
    }
}